require 'rspec'
require_relative '../option'

RSpec.describe Option do
  describe 'TYPES constant' do
    it 'ensures all option types have required keys' do
      Option::TYPES.each do |type_name, config|
        expect(config).to have_key(:price_per_day), 
          "Option type '#{type_name}' is missing price_per_day key"
        expect(config).to have_key(:beneficiary), 
          "Option type '#{type_name}' is missing beneficiary key"
      end
    end

    it 'ensures price_per_day values are positive integers' do
      Option::TYPES.each do |type_name, config|
        expect(config[:price_per_day]).to be_a(Integer), 
          "Option type '#{type_name}' price_per_day should be an integer"
        expect(config[:price_per_day]).to be > 0, 
          "Option type '#{type_name}' price_per_day should be positive"
      end
    end

    it 'ensures beneficiary values are valid' do
      valid_beneficiaries = ['owner', 'drivy']
      Option::TYPES.each do |type_name, config|
        expect(valid_beneficiaries).to include(config[:beneficiary]), 
          "Option type '#{type_name}' beneficiary should be one of: #{valid_beneficiaries.join(', ')}"
      end
    end

    it 'ensures no extra keys are present' do
      expected_keys = [:price_per_day, :beneficiary]
      Option::TYPES.each do |type_name, config|
        extra_keys = config.keys - expected_keys
        expect(extra_keys).to be_empty, 
          "Option type '#{type_name}' has unexpected keys: #{extra_keys.join(', ')}"
      end
    end
  end

  describe '#total_price' do
    it 'calculates GPS price correctly' do
      option = Option.new('gps', 3)
      expected_price = Option::TYPES['gps'][:price_per_day] * 3
      expect(option.total_price).to eq(expected_price)
    end

    it 'calculates baby seat price correctly' do
      option = Option.new('baby_seat', 5)
      expected_price = Option::TYPES['baby_seat'][:price_per_day] * 5
      expect(option.total_price).to eq(expected_price)
    end

    it 'calculates additional insurance price correctly' do
      option = Option.new('additional_insurance', 2)
      expected_price = Option::TYPES['additional_insurance'][:price_per_day] * 2
      expect(option.total_price).to eq(expected_price)
    end
  end

  describe '#beneficiary' do
    it 'returns correct beneficiary for GPS' do
      option = Option.new('gps', 3)
      expect(option.beneficiary).to eq('owner')
    end

    it 'returns correct beneficiary for baby seat' do
      option = Option.new('baby_seat', 3)
      expect(option.beneficiary).to eq('owner')
    end

    it 'returns correct beneficiary for additional insurance' do
      option = Option.new('additional_insurance', 3)
      expect(option.beneficiary).to eq('drivy')
    end
  end

  context 'with unknown option types' do
    it 'raises clear error for unknown type in total_price method' do
      option = Option.new('unknown_type', 3)
      expect {
        option.total_price
      }.to raise_error("Unknown option type: 'unknown_type'. Valid types are: gps, baby_seat, additional_insurance")
    end

    it 'handles empty string type' do
      option = Option.new('', 3)
      expect {
        option.total_price
      }.to raise_error("Unknown option type: ''. Valid types are: gps, baby_seat, additional_insurance")
    end
  end
end
