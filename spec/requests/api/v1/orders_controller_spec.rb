require 'rails_helper'

RSpec.describe "Orders", type: :request do
  let!(:merchant) { create(:merchant) }

  describe "POST /orders" do
    it "creates a new order with valid attributes" do
      post "/api/v1/orders", params: {
        order: {
          amount: 150.00,
          ordered_at: "2025-05-01T10:00:00Z",
          merchant_id: merchant.id
        }
      }

      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)

      expect(json["amount"]).to eq("150.0") # JSON will serialize decimal as string
      expect(json["merchant_id"]).to eq(merchant.id)
      expect(json["ordered_at"]).to eq("2025-05-01T10:00:00Z")
    end

    it "returns an error with missing fields" do
      post "/api/v1/orders", params: {
        order: {
          amount: nil,
          ordered_at: nil,
          merchant_id: merchant.id
        }
      }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)).to have_key("errors")
    end
  end
end
