require 'rails_helper'

RSpec.describe OrderService do
  let(:merchant) { create(:merchant, reference: "MERCH123") }
  let(:valid_params) do
    {
      amount: 150.00,
      ordered_at: "2025-01-01T10:00:00Z",
      merchant_id: merchant.id
    }
  end

  def build_dto(params)
    OrderCreateDto.new(params)
  end

  describe '.call' do
    context 'with valid parameters' do
      it 'creates an order successfully and sets merchant_reference' do
        result = described_class.call(build_dto(valid_params))

        expect(result.success?).to be true
        expect(result.payload).to be_persisted
        expect(result.payload.amount).to eq(150.00)
        expect(result.payload.merchant_id).to eq(merchant.id)
        expect(result.payload.merchant_reference).to eq("MERCH123")
        expect(result.errors).to be_empty
      end

      it 'generates an ID if not provided' do
        params_without_id = valid_params.except(:id)
        result = described_class.call(build_dto(params_without_id))

        expect(result.success?).to be true
        expect(result.payload.id).to be_present
        expect(result.payload.id.length).to eq(12) # SecureRandom.hex(6) generates 12 chars
      end
    end

    context 'with invalid parameters' do
      it 'returns failure when merchant_id is missing' do
        params = valid_params.except(:merchant_id)
        result = described_class.call(build_dto(params))

        expect(result.failure?).to be true
        expect(result.errors).to include('merchant not found')
      end

      it 'returns failure when merchant does not exist' do
        params = valid_params.merge(merchant_id: '99999')
        result = described_class.call(build_dto(params))

        expect(result.failure?).to be true
        expect(result.errors).to include('merchant not found')
      end

      it 'returns model validation errors for missing amount' do
        params = valid_params.except(:amount)
        result = described_class.call(build_dto(params))

        expect(result.failure?).to be true
        expect(result.errors).to include("Amount is not a number")
      end

      it 'returns model validation errors for zero amount' do
        params = valid_params.merge(amount: 0)
        result = described_class.call(build_dto(params))

        expect(result.failure?).to be true
        expect(result.errors).to include("Amount must be greater than or equal to 0.01")
      end

      it 'returns model validation errors for negative amount' do
        params = valid_params.merge(amount: -10)
        result = described_class.call(build_dto(params))

        expect(result.failure?).to be true
        expect(result.errors).to include("Amount must be greater than or equal to 0.01")
      end
    end

    context 'with multiple validation errors' do
      it 'returns all relevant errors' do
        params = { amount: nil, ordered_at: nil, merchant_id: nil }
        result = described_class.call(build_dto(params))

        expect(result.failure?).to be true
        expect(result.errors).to include('merchant not found')
      end
    end
  end
end
