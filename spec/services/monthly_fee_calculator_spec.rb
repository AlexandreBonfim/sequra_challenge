require 'rails_helper'

RSpec.describe MonthlyFeeCalculator do
  describe ".call" do
    let(:merchant) { create(:merchant, minimum_monthly_fee: 10.0) }

    context "when total generated fees are below the minimum" do
      before do
        create(:order, merchant: merchant, amount: 50.0, ordered_at: Date.new(2024, 5, 10))
        create(:order, merchant: merchant, amount: 100.0, ordered_at: Date.new(2024, 5, 15))
      end

      it "creates a monthly fee with the correct missing amount" do
        described_class.call(year: 2024, month: 5)

        expect(MonthlyFee.count).to eq(1)
        fee = MonthlyFee.last
        expect(fee.merchant).to eq(merchant)
        expect(fee.year).to eq(2024)
        expect(fee.month).to eq(5)
        expect(fee.amount).to eq(8.57) # 10.00 - (0.475 + 0.95)
      end

      it "updates existing monthly fee when called again" do
        # First call creates the fee
        described_class.call(year: 2024, month: 5)
        original_fee = MonthlyFee.last

        # Add more orders to change the calculation
        create(:order, merchant: merchant, amount: 200.0, ordered_at: Date.new(2024, 5, 20))

        # Second call should update the existing fee
        described_class.call(year: 2024, month: 5)

        expect(MonthlyFee.count).to eq(1) # Still only one record
        updated_fee = MonthlyFee.last
        expect(updated_fee.id).to eq(original_fee.id) # Same record
        expect(updated_fee.amount).to eq(6.67) # 10.00 - (0.475 + 0.95 + 1.90)
      end
    end

    context "when total generated fees exceed the minimum" do
      before do
        create(:order, merchant: merchant, amount: 400.0, ordered_at: Date.new(2024, 5, 20)) # fee = 3.40
        create(:order, merchant: merchant, amount: 300.0, ordered_at: Date.new(2024, 5, 25)) # fee = 2.85
        create(:order, merchant: merchant, amount: 300.0, ordered_at: Date.new(2024, 5, 26)) # fee = 2.85
        # total fees = 9.10
        create(:order, merchant: merchant, amount: 100.0, ordered_at: Date.new(2024, 5, 27)) # fee = 0.95
      end

      it "does not create a monthly fee" do
        expect {
          described_class.call(year: 2024, month: 5)
        }.not_to change(MonthlyFee, :count)
      end
    end

    context "when monthly fee already exists" do
      before do
        create(:order, merchant: merchant, amount: 50.0, ordered_at: Date.new(2024, 5, 10))
        # Create an existing monthly fee with different amount
        create(:monthly_fee, merchant: merchant, year: 2024, month: 5, amount: 5.0)
      end

      it "finds and updates the existing monthly fee" do
        expect {
          described_class.call(year: 2024, month: 5)
        }.not_to change(MonthlyFee, :count) # No new record created

        fee = MonthlyFee.last
        expect(fee.amount).to eq(9.52) # Updated to correct amount
        expect(fee.merchant).to eq(merchant)
        expect(fee.year).to eq(2024)
        expect(fee.month).to eq(5)
      end
    end
  end
end
