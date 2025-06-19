require "rails_helper"

RSpec.describe OrderPresenter do
  let(:order) { create(:order, ordered_at: Time.utc(2025, 5, 1, 10)) }

  it "formats order as JSON correctly" do
    presenter = described_class.new(order)
    json = presenter.as_json

    expect(json).to include(
      id: order.id,
      amount: order.amount,
      ordered_at: order.ordered_at.iso8601,
      merchant_id: order.merchant_id,
      merchant_reference: order.merchant_reference,
      disbursement_id: order.disbursement_id
    )
  end
end
