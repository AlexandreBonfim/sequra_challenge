class Disbursement < ApplicationRecord
  belongs_to :merchant
  has_many :orders
  has_many :refunds
end
