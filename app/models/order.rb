class Order < ApplicationRecord
  belongs_to :merchant
  belongs_to :disbursement, optional: true

  validates :id, presence: true, uniqueness: true
  validates :amount, numericality: { greater_than_or_equal_to: 0.01 }
  validates :ordered_at, presence: true

  before_validation :generate_id, on: :create

  # Returns orders eligible for disbursement for a given merchant and date
  def self.eligible_for_disbursement(merchant, date)
    case merchant.disbursement_frequency
    when Merchant::DISBURSEMENT_FREQUENCY_DAILY
      where(disbursement_id: nil, merchant_id: merchant.id, ordered_at: date)
    when Merchant::DISBURSEMENT_FREQUENCY_WEEKLY
      return none unless date.wday == merchant.live_on.wday
      from_date = date - 6.days
      where(disbursement_id: nil, merchant_id: merchant.id, ordered_at: from_date.beginning_of_day..date.end_of_day)
    else
      none
    end
  end

  private

  def generate_id
    self.id ||= SecureRandom.hex(6) # => generates 12-character alphanumeric ID
  end
end
