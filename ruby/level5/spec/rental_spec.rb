require 'rspec'
require 'date'
require_relative '../rental'
require_relative '../commission'
require_relative '../action'
require_relative '../action_calculator'
require_relative '../option'
require_relative '../option_manager'

RSpec.describe Rental do
  let(:rental_data) do
    {
      'id' => 1,
      'car_id' => 1,
      'start_date' => '2017-12-8',
      'end_date' => '2017-12-10',
      'distance' => 100
    }
  end

  let(:car_data) do
    {
      'id' => 1,
      'price_per_day' => 2000,
      'price_per_km' => 10
    }
  end

  let(:options_data) do
    [
      { 'id' => 1, 'rental_id' => 1, 'type' => 'gps' },
      { 'id' => 2, 'rental_id' => 1, 'type' => 'baby_seat' }
    ]
  end

  let(:options_manager) { OptionManager.new(options_data, 3) }
  let(:rental) { Rental.new(rental: rental_data, car: car_data, options_manager: options_manager) }

  describe '#price' do
    it 'calculates total price correctly (without options)' do
      expect(rental.price).to eq(6600)
    end
  end

  describe '#commission' do
    it 'calculates commission correctly' do
      result = rental.commission
      
      expect(result).to eq({
        'insurance_fee' => 990,
        'assistance_fee' => 300,
        'drivy_fee' => 690
      })
    end
  end

  describe '#option_types' do
    it 'returns option types for the rental' do
      expect(rental.option_types).to eq(['gps', 'baby_seat'])
    end
  end

  describe '#actions' do
    it 'returns array of action hashes' do
      actions = rental.actions
      
      expect(actions).to be_an(Array)
      expect(actions.length).to eq(5)
      expect(actions.first).to be_a(Hash)
    end

    it 'includes driver debit action with options price' do
      actions = rental.actions
      driver_action = actions.find { |action| action['who'] == 'driver' }
      
      options_price = (Option::TYPES['gps'][:price_per_day] + Option::TYPES['baby_seat'][:price_per_day]) * 3
      expected_amount = 6600 + options_price
      
      expect(driver_action).to eq({
        'who' => 'driver',
        'type' => 'debit',
        'amount' => expected_amount
      })
    end

    it 'includes owner credit action with options' do
      actions = rental.actions
      owner_action = actions.find { |action| action['who'] == 'owner' }
      
      options_price = (Option::TYPES['gps'][:price_per_day] + Option::TYPES['baby_seat'][:price_per_day]) * 3
      expected_amount = 6600 - 990 - 300 - 690 + options_price
      
      expect(owner_action).to eq({
        'who' => 'owner',
        'type' => 'credit',
        'amount' => expected_amount
      })
    end

    it 'includes insurance credit action' do
      actions = rental.actions
      insurance_action = actions.find { |action| action['who'] == 'insurance' }
      
      expect(insurance_action).to eq({
        'who' => 'insurance',
        'type' => 'credit',
        'amount' => 990
      })
    end

    it 'includes assistance credit action' do
      actions = rental.actions
      assistance_action = actions.find { |action| action['who'] == 'assistance' }
      
      expect(assistance_action).to eq({
        'who' => 'assistance',
        'type' => 'credit',
        'amount' => 300
      })
    end

    it 'includes drivy credit action' do
      actions = rental.actions
      drivy_action = actions.find { |action| action['who'] == 'drivy' }
      
      expect(drivy_action).to eq({
        'who' => 'drivy',
        'type' => 'credit',
        'amount' => 690
      })
    end
  end

  describe '#time_cost' do
    it 'calculates time cost correctly' do
      expect(rental.send(:time_cost)).to eq(5600)
    end
  end

  describe '#distance_cost' do
    it 'calculates distance cost correctly' do
      expect(rental.send(:distance_cost)).to eq(1000)
    end
  end

  describe '#rental_days' do
    it 'calculates rental days correctly' do
      expect(rental.rental_days('2017-12-8', '2017-12-10')).to eq(3)
    end
  end

  context 'with different options' do
    let(:drivy_rental_data) do
      {
        'id' => 2,
        'car_id' => 1,
        'start_date' => '2017-12-8',
        'end_date' => '2017-12-10',
        'distance' => 100
      }
    end

    let(:drivy_options_data) do
      [
        { 'id' => 1, 'rental_id' => 2, 'type' => 'additional_insurance' }
      ]
    end

    let(:drivy_options_manager) { OptionManager.new(drivy_options_data, 3) }
    let(:drivy_rental) { Rental.new(rental: drivy_rental_data, car: car_data, options_manager: drivy_options_manager) }

    it 'calculates actions with drivy options' do
      actions = drivy_rental.actions
      
      options_price = Option::TYPES['additional_insurance'][:price_per_day] * 3
      expected_driver_amount = 6600 + options_price
      
      driver_action = actions.find { |action| action['who'] == 'driver' }
      expect(driver_action['amount']).to eq(expected_driver_amount)
      
      expected_drivy_amount = 690 + options_price
      drivy_action = actions.find { |action| action['who'] == 'drivy' }
      expect(drivy_action['amount']).to eq(expected_drivy_amount)
    end
  end

  context 'with longer rental duration' do
    let(:long_rental_data) do
      {
        'id' => 3,
        'car_id' => 1,
        'start_date' => '2017-12-1',
        'end_date' => '2017-12-15',
        'distance' => 1200
      }
    end

    let(:long_options_manager) { OptionManager.new([], 15) }
    let(:long_rental) { Rental.new(rental: long_rental_data, car: car_data, options_manager: long_options_manager) }

    it 'calculates actions for longer rental without options' do
      actions = long_rental.actions
      
      driver_action = actions.find { |action| action['who'] == 'driver' }
      expect(driver_action['amount']).to eq(32800)
      
      expect(long_rental.option_types).to eq([])
    end
  end

  context 'without options' do
    let(:no_options_manager) { OptionManager.new([], 3) }
    let(:no_options_rental) { Rental.new(rental: rental_data, car: car_data, options_manager: no_options_manager) }

    it 'calculates actions without options' do
      actions = no_options_rental.actions
      
      driver_action = actions.find { |action| action['who'] == 'driver' }
      expect(driver_action['amount']).to eq(6600)
      
      expect(no_options_rental.option_types).to eq([])
    end
  end

  context 'location sans options et sans champ options' do
    let(:no_options_manager) { OptionManager.new(nil, 3) }
    let(:no_options_rental) { Rental.new(rental: rental_data, car: car_data, options_manager: no_options_manager) }

    it 'handles rental without options and without options field' do
      actions = no_options_rental.actions
      
      driver_action = actions.find { |action| action['who'] == 'driver' }
      expect(driver_action['amount']).to eq(6600)
      
      expect(no_options_rental.option_types).to eq([])
    end
  end
end
