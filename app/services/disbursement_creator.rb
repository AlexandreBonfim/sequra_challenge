class DisbursementCreator
  def self.call(date = Date.current)
    new(date).call
  end

  def initialize(date)
    @date = date
  end

  def call
    return unless before_8am_utc?

    Merchant.find_each do |merchant|
      next unless eligible_for_disbursement?(merchant)

      process_merchant(merchant)
    end
  end

  private

  attr_reader :date

  def before_8am_utc?
    Time.current.utc.hour < 8
  end

  def eligible_for_disbursement?(merchant)
    case merchant.disbursement_frequency
    when Merchant::DISBURSEMENT_FREQUENCY_DAILY
      true
    when Merchant::DISBURSEMENT_FREQUENCY_WEEKLY
      merchant.live_on.wday == date.wday  # Process on the same weekday as live_on
    else
      false
    end
  end

  def process_merchant(merchant)
    orders = eligible_orders(merchant)
    return if orders.empty?

    # Check if disbursement already exists for this merchant and date
    existing_disbursement = Disbursement.find_by(merchant: merchant, date: date)
    return if existing_disbursement

    disbursement = Disbursement.create!(
      merchant: merchant,
      date: date,
      reference: ReferenceGenerator.disbursement_reference(merchant.reference),
      total_amount: 0,
      total_fees: 0
    )

    total_amount = BigDecimal("0")
    total_fees = BigDecimal("0")

    orders.each do |order|
      fee = FeeCalculator.calculate(order.amount)
      net = FeeCalculator.net_amount(order.amount)

      total_fees += fee
      total_amount += net

      order.update!(disbursement: disbursement)
    end

    disbursement.update!(
      total_amount: total_amount.round(2),
      total_fees: total_fees.round(2)
    )
  end

  def eligible_orders(merchant)
    Order.eligible_for_disbursement(merchant, date)
  end
end
