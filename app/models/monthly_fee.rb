class MonthlyFee < ApplicationRecord
  belongs_to :merchant

  validates :amount, numericality: { greater_than_or_equal_to: 0 }
end
