class OrderCreateDto
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :amount, :decimal
  attribute :ordered_at, :datetime
  attribute :merchant_id, :string

  validates :amount, numericality: { greater_than_or_equal_to: 0.01 }
  validates :ordered_at, presence: true
  validates :merchant_id, presence: true

  def attributes
    {
      amount: amount,
      ordered_at: ordered_at,
      merchant_id: merchant_id
    }
  end
end
