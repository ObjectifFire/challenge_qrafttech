require 'rspec'
require_relative '../commission'

RSpec.describe Commission do
  let(:commission) { Commission.new(7000, 3) }

  describe '#calculate' do
    it 'calculates commission correctly' do
      result = commission.calculate
      total_commission = (7000 * Commission::COMMISSION_RATE_PERCENT) / 100
      expected_insurance = (total_commission * Commission::INSURANCE_COMMISSION_RATE_PERCENT) / 100
      expected_assistance = 3 * Commission::ASSISTANCE_FEE_PER_DAY
      expected_drivy = total_commission - expected_insurance - expected_assistance
      
      expect(result['insurance_fee']).to eq(expected_insurance)
      expect(result['assistance_fee']).to eq(expected_assistance)
      expect(result['drivy_fee']).to eq(expected_drivy)
    end

    it 'calculates commission for different rental price' do
      commission = Commission.new(10000, 5)
      result = commission.calculate
      total_commission = (10000 * Commission::COMMISSION_RATE_PERCENT) / 100
      expected_insurance = (total_commission * Commission::INSURANCE_COMMISSION_RATE_PERCENT) / 100
      expected_assistance = 5 * Commission::ASSISTANCE_FEE_PER_DAY
      expected_drivy = total_commission - expected_insurance - expected_assistance
      
      expect(result['insurance_fee']).to eq(expected_insurance)
      expect(result['assistance_fee']).to eq(expected_assistance)
      expect(result['drivy_fee']).to eq(expected_drivy)
    end

    it 'calculates commission for single day rental' do
      commission = Commission.new(2000, 1)
      result = commission.calculate
      total_commission = (2000 * Commission::COMMISSION_RATE_PERCENT) / 100
      expected_insurance = (total_commission * Commission::INSURANCE_COMMISSION_RATE_PERCENT) / 100
      expected_assistance = 1 * Commission::ASSISTANCE_FEE_PER_DAY
      expected_drivy = total_commission - expected_insurance - expected_assistance
      
      expect(result['insurance_fee']).to eq(expected_insurance)
      expect(result['assistance_fee']).to eq(expected_assistance)
      expect(result['drivy_fee']).to eq(expected_drivy)
    end
  end

  describe 'commission calculation validation' do
    it 'ensures total commission equals sum of all fees' do
      result = commission.calculate
      total_commission = (7000 * Commission::COMMISSION_RATE_PERCENT) / 100
      
      sum_of_fees = result['insurance_fee'] + result['assistance_fee'] + result['drivy_fee']
      
      expect(sum_of_fees).to eq(total_commission)
    end

    it 'handles case where assistance fee exceeds available commission' do
      commission = Commission.new(1000, 10)
      result = commission.calculate
      total_commission = (1000 * Commission::COMMISSION_RATE_PERCENT) / 100
      expected_insurance = (total_commission * Commission::INSURANCE_COMMISSION_RATE_PERCENT) / 100
      expected_assistance = 10 * Commission::ASSISTANCE_FEE_PER_DAY
      
      expect(result['drivy_fee']).to be >= 0
      expect(result['insurance_fee']).to eq(expected_insurance)
      expect(result['assistance_fee']).to eq(expected_assistance)
      expect(result['drivy_fee']).to eq(0)
    end

    it 'handles case where commission barely covers assistance fee' do
      commission = Commission.new(2000, 3)
      result = commission.calculate
      total_commission = (2000 * Commission::COMMISSION_RATE_PERCENT) / 100
      expected_insurance = (total_commission * Commission::INSURANCE_COMMISSION_RATE_PERCENT) / 100
      expected_assistance = 3 * Commission::ASSISTANCE_FEE_PER_DAY
      
      expect(result['drivy_fee']).to eq(0)
      expect(result['insurance_fee']).to eq(expected_insurance)
      expect(result['assistance_fee']).to eq(expected_assistance)
    end

    it 'ensures integer division precision with odd amounts' do
      commission = Commission.new(1001, 1)
      result = commission.calculate
      total_commission = (1001 * Commission::COMMISSION_RATE_PERCENT) / 100
      expected_insurance = (total_commission * Commission::INSURANCE_COMMISSION_RATE_PERCENT) / 100
      expected_assistance = 1 * Commission::ASSISTANCE_FEE_PER_DAY
      expected_drivy = total_commission - expected_insurance - expected_assistance
      
      sum_of_fees = result['insurance_fee'] + result['assistance_fee'] + result['drivy_fee']
      
      expect(sum_of_fees).to eq(total_commission)
      expect(result['insurance_fee']).to eq(expected_insurance)
      expect(result['assistance_fee']).to eq(expected_assistance)
      expect(result['drivy_fee']).to eq(expected_drivy)
    end

    it 'ensures integer division precision with problematic amounts' do
      commission = Commission.new(1007, 1)
      result = commission.calculate
      total_commission = (1007 * Commission::COMMISSION_RATE_PERCENT) / 100
      expected_insurance = (total_commission * Commission::INSURANCE_COMMISSION_RATE_PERCENT) / 100
      expected_assistance = 1 * Commission::ASSISTANCE_FEE_PER_DAY
      expected_drivy = total_commission - expected_insurance - expected_assistance
      
      sum_of_fees = result['insurance_fee'] + result['assistance_fee'] + result['drivy_fee']
      
      expect(sum_of_fees).to eq(total_commission)
      expect(result['insurance_fee']).to eq(expected_insurance)
      expect(result['assistance_fee']).to eq(expected_assistance)
      expect(result['drivy_fee']).to eq(expected_drivy)
    end
  end
end
