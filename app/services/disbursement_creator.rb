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
    when "daily"
      true
    when "weekly"
      merchant.live_on.wday == date.wday
    else
      false
    end
  end

  def process_merchant(merchant)
    orders = eligible_orders(merchant)
    return if orders.empty?

    disbursement = Disbursement.create!(
      merchant: merchant,
      date: disbursement_date(merchant),
      reference: generate_reference(merchant),
      total_amount: 0,
      total_fees: 0
    )

    total_amount = BigDecimal("0")
    total_fees = BigDecimal("0")

    orders.each do |order|
      fee = calculate_fee(order.amount)
      net_amount = (order.amount - fee).round(2)

      total_fees += fee
      total_amount += net_amount

      order.update!(disbursement: disbursement)
    end

    disbursement.update!(
      total_amount: total_amount.round(2),
      total_fees: total_fees.round(2)
    )
  end

  def eligible_orders(merchant)
    case merchant.disbursement_frequency
    when Merchant::DISBURSEMENT_FREQUENCY_DAILY
      merchant.orders.where(disbursement_id: nil, ordered_at: date)
    when Merchant::DISBURSEMENT_FREQUENCY_WEEKLY
      return Order.none unless date.wday == merchant.live_on.wday

      from_date = date - 6.days
      merchant.orders.where(disbursement_id: nil, ordered_at: from_date.beginning_of_day..date.end_of_day)
    else
      Order.none
    end
  end

  def disbursement_date(merchant)
    merchant.disbursement_frequency == Merchant::DISBURSEMENT_FREQUENCY_WEEKLY ? date.end_of_week(:sunday) : date
  end

  def calculate_fee(amount)
    rate =
      if amount < 50
        BigDecimal("0.01")
      elsif amount <= 300
        BigDecimal("0.0095")
      else
        BigDecimal("0.0085")
      end

    (amount * rate).round(2)
  end

  def generate_reference(merchant)
    timestamp = Time.current.utc.strftime("%Y%m%d%H%M%S")
    "DISP-#{merchant.reference}-#{timestamp}"
  end
end
