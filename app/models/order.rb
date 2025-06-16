class Order < ApplicationRecord
  belongs_to :merchant
  belongs_to :disbursement, optional: true
end
