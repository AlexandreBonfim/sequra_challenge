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
        .sum { |order| calculate_fee(order.amount) }

      total_fees = BigDecimal(total_fees.to_s).round(2)
      min_fee = BigDecimal(merchant.minimum_monthly_fee.to_s).round(2)

      if total_fees < min_fee
        MonthlyFee.create!(
          merchant: merchant,
          year: @year,
          month: @month,
          amount: (min_fee - total_fees).round(2)
        )
      end
    end
  end

  private

  def calculate_fee(amount)
    rate =
      if amount < 50
        0.01
      elsif amount <= 300
        0.0095
      else
        0.0085
      end

    (amount * rate).round(2)
  end
end
