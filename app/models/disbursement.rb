class Disbursement < ApplicationRecord
  belongs_to :merchant
  has_many :orders
end
