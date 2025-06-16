require "rails_helper"

RSpec.describe DisbursementCreator do
  let(:merchant) do
    create(:merchant, disbursement_frequency: Merchant::DISBURSEMENT_FREQUENCY_DAILY, live_on: Date.new(2024, 3, 15))
  end
  let(:date) { Date.new(2024, 3, 15) }

  before do
    allow(Time).to receive(:current).and_return(Time.new(2024, 3, 15, 7, 0, 0, "+00:00")) # Before 8am UTC
  end

  describe ".call" do
    context "when after 8am UTC" do
      before do
        allow(Time).to receive(:current).and_return(Time.new(2024, 3, 15, 9, 0, 0, "+00:00"))
      end

      it "does not process disbursements" do
        expect {
          described_class.call(date)
        }.not_to change(Disbursement, :count)
      end
    end

    context "with daily disbursement frequency" do
      before do
        create_list(:order, 3, merchant: merchant, amount: 100.0, ordered_at: date, disbursement: nil)
      end

      it "creates a disbursement with correct calculations" do
        expect {
          described_class.call(date)
        }.to change(Disbursement, :count).by(1)

        disbursement = Disbursement.last

        expect(disbursement.merchant).to eq(merchant)
        expect(disbursement.date).to eq(date)
        expect(disbursement.total_amount).to eq(297.15)
        expect(disbursement.total_fees).to eq(2.85)
        expect(disbursement.reference).to match(/^DISP-#{merchant.reference}-\d{14}$/)
      end

      it "updates orders with the disbursement reference" do
        orders = merchant.orders.where(ordered_at: date)
        described_class.call(date)
        disbursement = Disbursement.last

        orders.each do |order|
          expect(order.reload.disbursement).to eq(disbursement)
        end
      end

      it "does not create duplicate disbursements for the same merchant and date" do
        described_class.call(date)
        expect {
          described_class.call(date)
        }.not_to change(Disbursement, :count)
      end
    end

    context "with weekly disbursement frequency" do
      let(:merchant) { create(:merchant, disbursement_frequency: Merchant::DISBURSEMENT_FREQUENCY_WEEKLY, live_on: date) }

      before do
        create_list(:order, 4, merchant: merchant, amount: 200.0, ordered_at: date.beginning_of_week(:monday), disbursement: nil)
      end

      it "creates a disbursement for the week" do
        expect {
          described_class.call(date)
        }.to change(Disbursement, :count).by(1)

        disbursement = Disbursement.last
        expect(disbursement.total_amount).to eq(792.40)
        expect(disbursement.total_fees).to eq(7.60)
      end
    end

    context "with different fee tiers" do
      before do
        create(:order, merchant: merchant, amount: 40.0, ordered_at: date, disbursement: nil)  # 1%
        create(:order, merchant: merchant, amount: 200.0, ordered_at: date, disbursement: nil) # 0.95%
        create(:order, merchant: merchant, amount: 400.0, ordered_at: date, disbursement: nil) # 0.85%
      end

      it "applies correct fee rates and totals" do
        described_class.call(date)
        disbursement = Disbursement.last

        expect(disbursement.total_fees).to eq(5.70)
        expect(disbursement.total_amount).to eq(634.30)
      end
    end

    context "with no eligible orders" do
      it "does not create a disbursement" do
        expect {
          described_class.call(date)
        }.not_to change(Disbursement, :count)
      end
    end
  end
end
