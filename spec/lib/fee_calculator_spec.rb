require 'rails_helper'

RSpec.describe FeeCalculator do
  describe '.calculate' do
    it 'applies 1% fee for amounts less than 50' do
      expect(FeeCalculator.calculate(10)).to eq(0.10)
      expect(FeeCalculator.calculate(49.99)).to eq(0.50)
    end

    it 'applies 0.95% fee for amounts between 50 and 300 (inclusive)' do
      expect(FeeCalculator.calculate(50)).to eq(0.48)
      expect(FeeCalculator.calculate(200)).to eq(1.90)
      expect(FeeCalculator.calculate(300)).to eq(2.85)
    end

    it 'applies 0.85% fee for amounts greater than 300' do
      expect(FeeCalculator.calculate(301)).to eq(2.56)
      expect(FeeCalculator.calculate(1000)).to eq(8.50)
    end

    it 'rounds the fee to two decimal places' do
      expect(FeeCalculator.calculate(123.456)).to eq(1.17)
    end
  end

  describe '.net_amount' do
    it 'returns amount minus 1% fee for amounts less than 50' do
      expect(FeeCalculator.net_amount(10)).to eq(9.90)
      expect(FeeCalculator.net_amount(49.99)).to eq(49.49)
    end

    it 'returns amount minus 0.95% fee for amounts between 50 and 300 (inclusive)' do
      expect(FeeCalculator.net_amount(50)).to eq(49.52)
      expect(FeeCalculator.net_amount(200)).to eq(198.10)
      expect(FeeCalculator.net_amount(300)).to eq(297.15)
    end

    it 'returns amount minus 0.85% fee for amounts greater than 300' do
      expect(FeeCalculator.net_amount(301)).to eq(298.44)
      expect(FeeCalculator.net_amount(1000)).to eq(991.50)
    end

    it 'rounds the net amount to two decimal places' do
      expect(FeeCalculator.net_amount(123.456)).to eq(122.29)
    end
  end
end
