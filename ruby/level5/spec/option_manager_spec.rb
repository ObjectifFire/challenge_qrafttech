require 'rspec'
require_relative '../option'
require_relative '../option_manager'

RSpec.describe OptionManager do
  let(:options_data) do
    [
      { 'id' => 1, 'rental_id' => 1, 'type' => 'gps' },
      { 'id' => 2, 'rental_id' => 1, 'type' => 'baby_seat' },
      { 'id' => 3, 'rental_id' => 2, 'type' => 'additional_insurance' }
    ]
  end

  let(:rental_days) { 3 }
  let(:manager) { OptionManager.new(options_data, rental_days) }

  describe '#options_for_rental' do
    it 'returns options for specific rental' do
      options = manager.options_for_rental(1)
      expect(options).to be_an(Array)
      expect(options.length).to eq(2)
      expect(options.first).to be_a(Option)
      expect(options.first.type).to eq('gps')
      expect(options.last.type).to eq('baby_seat')
    end

    it 'returns empty array for non-existent rental' do
      options = manager.options_for_rental(999)
      expect(options).to eq([])
    end
  end

  describe '#total_options_price' do
    it 'calculates total price for rental with options' do
      expected_price = (Option::TYPES['gps'][:price_per_day] + Option::TYPES['baby_seat'][:price_per_day]) * 3
      expect(manager.total_options_price(1)).to eq(expected_price)
    end

    it 'returns 0 for rental without options' do
      expect(manager.total_options_price(999)).to eq(0)
    end

    it 'calculates price for rental with single option' do
      expected_price = Option::TYPES['additional_insurance'][:price_per_day] * 3
      expect(manager.total_options_price(2)).to eq(expected_price)
    end
  end

  describe '#option_types_for_rental' do
    it 'returns option types for rental' do
      types = manager.option_types_for_rental(1)
      expect(types).to eq(['gps', 'baby_seat'])
    end

    it 'returns empty array for rental without options' do
      types = manager.option_types_for_rental(999)
      expect(types).to eq([])
    end

    it 'returns single option type' do
      types = manager.option_types_for_rental(2)
      expect(types).to eq(['additional_insurance'])
    end

    it 'enforces one option per type rule correctly' do
      mixed_options_data = [
        { 'id' => 1, 'rental_id' => 1, 'type' => 'gps' },
        { 'id' => 2, 'rental_id' => 1, 'type' => 'gps' },
        { 'id' => 3, 'rental_id' => 1, 'type' => 'baby_seat' },
        { 'id' => 4, 'rental_id' => 1, 'type' => 'baby_seat' },
        { 'id' => 5, 'rental_id' => 1, 'type' => 'baby_seat' },
        { 'id' => 6, 'rental_id' => 1, 'type' => 'additional_insurance' },
        { 'id' => 7, 'rental_id' => 1, 'type' => 'additional_insurance' }
      ]
      mixed_manager = OptionManager.new(mixed_options_data, 3)
      types = mixed_manager.option_types_for_rental(1)
      expect(types).to eq(['gps', 'baby_seat', 'additional_insurance'])
      expected_price = (Option::TYPES['gps'][:price_per_day] + Option::TYPES['baby_seat'][:price_per_day] + Option::TYPES['additional_insurance'][:price_per_day]) * 3
      expect(mixed_manager.total_options_price(1)).to eq(expected_price)
    end
  end

  describe '#options_by_beneficiary' do
    it 'groups options by beneficiary' do
      grouped = manager.options_by_beneficiary(1)
      expect(grouped).to have_key('owner')
      expect(grouped).not_to have_key('drivy')
      expect(grouped['owner'].length).to eq(2)
    end

    it 'groups options correctly for different beneficiaries' do
      grouped = manager.options_by_beneficiary(2)
      expect(grouped).to have_key('drivy')
      expect(grouped).not_to have_key('owner')
      expect(grouped['drivy'].length).to eq(1)
    end
  end

  describe '#additional_amounts_by_beneficiary' do
    it 'calculates additional amounts for rental with owner options' do
      amounts = manager.additional_amounts_by_beneficiary(1)
      expected_owner_amount = (Option::TYPES['gps'][:price_per_day] + Option::TYPES['baby_seat'][:price_per_day]) * 3
      expect(amounts['owner']).to eq(expected_owner_amount)
      expect(amounts).not_to have_key('drivy')
    end

    it 'calculates additional amounts for rental with drivy options' do
      amounts = manager.additional_amounts_by_beneficiary(2)
      expected_drivy_amount = Option::TYPES['additional_insurance'][:price_per_day] * 3
      expect(amounts['drivy']).to eq(expected_drivy_amount)
      expect(amounts).not_to have_key('owner')
    end

    it 'returns empty hash for rental without options' do
      amounts = manager.additional_amounts_by_beneficiary(999)
      expect(amounts).to eq({})
    end
  end

  context 'with invalid option types' do
    let(:invalid_options_data) do
      [
        { 'id' => 1, 'rental_id' => 1, 'type' => 'gps' },
        { 'id' => 2, 'rental_id' => 1, 'type' => 'invalid_option' },
        { 'id' => 3, 'rental_id' => 2, 'type' => 'additional_insurance' }
      ]
    end

    let(:manager_with_invalid) { OptionManager.new(invalid_options_data, rental_days) }

    it 'raises error with rental context when processing invalid option' do
      expect {
        manager_with_invalid.total_options_price(1)
      }.to raise_error("Error processing option for rental 1: Unknown option type: 'invalid_option'. Valid types are: gps, baby_seat, additional_insurance")
    end

    it 'raises error with correct rental ID in error message' do
      invalid_data_for_rental_5 = [
        { 'id' => 1, 'rental_id' => 5, 'type' => 'unknown_type' }
      ]
      manager_rental_5 = OptionManager.new(invalid_data_for_rental_5, rental_days)
      expect {
        manager_rental_5.total_options_price(5)
      }.to raise_error("Error processing option for rental 5: Unknown option type: 'unknown_type'. Valid types are: gps, baby_seat, additional_insurance")
    end
  end
end
