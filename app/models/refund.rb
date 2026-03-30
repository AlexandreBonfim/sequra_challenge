class Refund < ApplicationRecord  
  belongs_to :order
  has_one :merchant

  def self.eligible_for_disbursement(merchant, date)
    case merchant.disbursement_frequency
    when Merchant::DISBURSEMENT_FREQUENCY_DAILY
      joins(:order).
      where(disbursement_id: nil, order: { merchant_id: merchant.id }, refund_at: date)
    when Merchant::DISBURSEMENT_FREQUENCY_WEEKLY
      return none unless date.wday == merchant.live_on.wday
      from_date = date - 6.days
      where(disbursement_id: nil, merchant_id: merchant.id, refund_at: from_date.beginning_of_day..date.end_of_day)
    else
      none
    end
  end
end
