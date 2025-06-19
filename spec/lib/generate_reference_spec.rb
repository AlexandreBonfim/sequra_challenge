require 'rails_helper'

RSpec.describe ReferenceGenerator do
  describe '.disbursement_reference' do
    let(:merchant) { double('Merchant', reference: 'MERCH123') }
    let(:today) { Date.current }

    it 'generates the correct reference string using today\'s date' do
      expected = "DISP-#{merchant.reference}-#{today.strftime('%Y%m%d')}"

      expect(ReferenceGenerator.disbursement_reference(merchant)).to eq(expected)
    end
  end
end
