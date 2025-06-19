require 'swagger_helper'

RSpec.describe 'Orders API', type: :request do
  path '/api/v1/orders' do
    post 'Creates a new Order' do
      tags 'Orders'
      consumes 'application/json'
      parameter name: :order, in: :body, schema: {
        type: :object,
        properties: {
          amount: { type: :number, format: :float },
          ordered_at: { type: :string, format: :date_time },
          merchant_id: { type: :string }
        },
        required: %w[amount ordered_at merchant_id]
      }

      response '201', 'Order created' do
        let(:merchant) { create(:merchant) }
        let(:order) do
          {
            amount: 120.50,
            ordered_at: '2025-06-01T10:00:00Z',
            merchant_id: merchant.id
          }
        end

        run_test!
      end

      response '422', 'Invalid request' do
        let(:order) { { amount: nil } }
        run_test!
      end
    end
  end
end
