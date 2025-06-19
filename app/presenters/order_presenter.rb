class OrderPresenter
  delegate :id, :amount, :ordered_at, :merchant_id, :merchant_reference, :disbursement_id, to: :order

  def initialize(order)
    @order = order
  end

  def as_json(*)
    {
      id: id,
      amount: amount,
      ordered_at: ordered_at&.iso8601,
      merchant_id: merchant_id,
      merchant_reference: merchant_reference,
      disbursement_id: disbursement_id
    }
  end

  private

  attr_reader :order
end
