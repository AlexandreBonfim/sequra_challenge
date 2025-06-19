class Order < ApplicationRecord
  belongs_to :merchant
  belongs_to :disbursement, optional: true

  validates :id, presence: true, uniqueness: true
  validates :amount, numericality: { greater_than_or_equal_to: 0.01 }
  validates :ordered_at, presence: true

  before_validation :generate_id, on: :create

  private

  def generate_id
    self.id ||= SecureRandom.hex(6) # => generates 12-character alphanumeric ID
  end
end
