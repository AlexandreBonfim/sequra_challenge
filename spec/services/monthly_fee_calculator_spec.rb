require 'rails_helper'

RSpec.describe MonthlyFeeCalculator do
  describe ".call" do
    let(:merchant) { create(:merchant, minimum_monthly_fee: 10.0) }

    before do
      MonthlyFee.destroy_all
    end

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
  end
end
