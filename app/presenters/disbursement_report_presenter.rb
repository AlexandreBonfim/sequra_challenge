require "csv"

class DisbursementReportPresenter
  def initialize(data)
    @data = data
  end

  def to_csv
    CSV.generate(headers: true) do |csv|
      csv << [
        "Year",
        "Number of disbursements",
        "Amount disbursed to merchants",
        "Amount of order fees",
        "Number of monthly fees charged",
        "Amount of monthly fees charged"
      ]
      @data.each do |row|
        csv << [
          row[:year],
          row[:disbursements_count],
          euro(row[:total_disbursed]),
          euro(row[:total_fees]),
          row[:monthly_fees_count],
          euro(row[:monthly_fees_total])
        ]
      end
    end
  end

  private

  def euro(amount)
    whole, decimal = format("%.2f", amount).split(".")
    whole_with_sep = whole.reverse.gsub(/(\d{3})(?=\d)/, '\1,').reverse
    "#{whole_with_sep}.#{decimal} €"
  end
end
