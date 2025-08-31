require 'rspec'
require 'date'
require_relative '../rental'
require_relative '../commission'
require_relative '../action'
require_relative '../action_calculator'

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

  let(:rental) { Rental.new(rental_data, car_data) }

  describe '#price' do
    it 'calculates total price correctly' do
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

  describe '#actions' do
    it 'returns array of action hashes' do
      actions = rental.actions
      
      expect(actions).to be_an(Array)
      expect(actions.length).to eq(5)
      expect(actions.first).to be_a(Hash)
    end

    it 'includes driver debit action' do
      actions = rental.actions
      driver_action = actions.find { |action| action['who'] == 'driver' }
      
      expect(driver_action).to eq({
        'who' => 'driver',
        'type' => 'debit',
        'amount' => 6600
      })
    end

    it 'includes owner credit action' do
      actions = rental.actions
      owner_action = actions.find { |action| action['who'] == 'owner' }
      
      expect(owner_action).to eq({
        'who' => 'owner',
        'type' => 'credit',
        'amount' => 4620
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

  context 'with different rental durations' do
    let(:five_day_rental_data) do
      {
        'id' => 2,
        'car_id' => 1,
        'start_date' => '2017-12-8',
        'end_date' => '2017-12-12',
        'distance' => 100
      }
    end

    let(:five_day_rental) { Rental.new(five_day_rental_data, car_data) }

    let(:long_rental_data) do
      {
        'id' => 3,
        'car_id' => 1,
        'start_date' => '2017-12-1',
        'end_date' => '2017-12-15',
        'distance' => 1200
      }
    end

    let(:long_rental) { Rental.new(long_rental_data, car_data) }

    it 'calculates price, commission and actions for 5 day rental' do
      expect(five_day_rental.price).to eq(9800)
      
      expect(five_day_rental.commission).to eq({
        'insurance_fee' => 1470,
        'assistance_fee' => 500,
        'drivy_fee' => 970
      })

      actions = five_day_rental.actions
      driver_action = actions.find { |action| action['who'] == 'driver' }
      expect(driver_action['amount']).to eq(9800)
    end

    it 'calculates price, commission and actions for longer rental' do
      expect(long_rental.price).to eq(32800)
      
      expect(long_rental.commission).to eq({
        'insurance_fee' => 4920,
        'assistance_fee' => 1500,
        'drivy_fee' => 3420
      })

      actions = long_rental.actions
      driver_action = actions.find { |action| action['who'] == 'driver' }
      expect(driver_action['amount']).to eq(32800)
    end
  end
end
