class MonthlyFeeCalculator
  def self.call(year:, month:)
    new(year, month).call
  end

  def initialize(year, month)
    @year = year
    @month = month
    @start_date = Date.new(year, month, 1)
    @end_date = @start_date.end_of_month
  end

  def call
    Merchant.find_each do |merchant|
      total_fees = merchant.orders
        .where(ordered_at: @start_date..@end_date)
        .sum { |order| FeeCalculator.calculate(order.amount) }

      total_fees = BigDecimal(total_fees.to_s).round(2)
      min_fee = BigDecimal(merchant.minimum_monthly_fee.to_s).round(2)

      if total_fees < min_fee
        monthly_fee_amount = (min_fee - total_fees).round(2)

        # Use find_or_create_by to handle existing records
        monthly_fee = MonthlyFee.find_or_create_by(
          merchant: merchant,
          year: @year,
          month: @month
        ) do |fee|
          fee.amount = monthly_fee_amount
        end

        # Update amount if record already existed
        if monthly_fee.persisted? && monthly_fee.amount != monthly_fee_amount
          monthly_fee.update!(amount: monthly_fee_amount)
        end
      end
    end
  end
end
