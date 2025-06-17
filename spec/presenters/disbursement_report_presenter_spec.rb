require "rails_helper"

RSpec.describe DisbursementReportPresenter do
  describe "#to_csv" do
    it "returns a valid CSV string" do
      data = [
        {
          year: 2023,
          disbursements_count: 400,
          total_disbursed: 75000.35,
          total_fees: 950.43,
          monthly_fees_count: 49,
          monthly_fees_total: 750.00
        }
      ]

      csv = described_class.new(data).to_csv
      csv_lines = csv.split("\n")
      headers = csv_lines[0]
      values = csv_lines[1]

      # Check headers
      expect(headers).to eq(
        "Year,Number of disbursements,Amount disbursed to merchants,Amount of order fees,Number of monthly fees charged,Amount of monthly fees charged"
      )

      # Check values with euro formatting
      expect(values).to eq(
        "2023,400,\"75,000.35 €\",950.43 €,49,750.00 €"
      )
    end
  end
end
