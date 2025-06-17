class DisbursementReport
  def call
    Disbursement
      .select("EXTRACT(YEAR FROM date) AS year")
      .group("year")
      .map do |record|
        year = record.year.to_i

        disbursements = Disbursement.where("EXTRACT(YEAR FROM date) = ?", year)
        monthly_fees = MonthlyFee.where(year: year)

        {
          year: year,
          disbursements_count: disbursements.count,
          total_disbursed: disbursements.sum(:total_amount).round(2),
          total_fees: disbursements.sum(:total_fees).round(2),
          monthly_fees_count: monthly_fees.count,
          monthly_fees_total: monthly_fees.sum(:amount).round(2)
        }
      end
  end
end
