require "rails_helper"

RSpec.describe DisbursementReport do
  describe "#call" do
    it "returns yearly disbursement and monthly fee summaries" do
      merchant = create(:merchant, minimum_monthly_fee: 10)
      create(:disbursement, merchant: merchant, date: Date.new(2023, 6, 1), total_amount: 100.0, total_fees: 2.5)
      create(:monthly_fee, merchant: merchant, year: 2023, month: 6, amount: 7.5)

      result = described_class.new.call

      expect(result).to include(
        a_hash_including(
          year: 2023,
          disbursements_count: 1,
          total_disbursed: 100.0,
          total_fees: 2.5,
          monthly_fees_count: 1,
          monthly_fees_total: 7.5
        )
      )
    end
  end
end
