require 'rails_helper'

RSpec.describe ServiceResult do
  describe '.success' do
    it 'returns a successful result' do
      result = ServiceResult.success('payload')
      expect(result.success?).to be true
      expect(result.failure?).to be false
      expect(result.payload).to eq('payload')
      expect(result.errors).to eq([])
    end
  end

  describe '.failure' do
    it 'returns a failure result with errors' do
      errors = [ 'error1', 'error2' ]
      result = ServiceResult.failure(errors, 'payload')
      expect(result.success?).to be false
      expect(result.failure?).to be true
      expect(result.payload).to eq('payload')
      expect(result.errors).to eq(errors)
    end

    it 'returns a failure result with a single error as string' do
      result = ServiceResult.failure('error1')
      expect(result.success?).to be false
      expect(result.errors).to eq([ 'error1' ])
    end
  end
end
