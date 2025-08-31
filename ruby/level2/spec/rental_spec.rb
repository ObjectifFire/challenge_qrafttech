require 'rspec'
require 'date'
require_relative '../rental'

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

  describe '#days' do
    it 'calculates days using memoization' do
      expect(rental.send(:days)).to eq(3)
    end
  end



  context 'with different rental durations' do
    let(:one_day_rental_data) do
      {
        'id' => 2,
        'car_id' => 1,
        'start_date' => '2017-12-8',
        'end_date' => '2017-12-8',
        'distance' => 100
      }
    end

    let(:five_day_rental_data) do
      {
        'id' => 3,
        'car_id' => 1,
        'start_date' => '2017-12-8',
        'end_date' => '2017-12-12',
        'distance' => 100
      }
    end

    let(:twelve_day_rental_data) do
      {
        'id' => 4,
        'car_id' => 1,
        'start_date' => '2017-12-8',
        'end_date' => '2017-12-19',
        'distance' => 100
      }
    end

    let(:long_rental_data) do
      {
        'id' => 5,
        'car_id' => 1,
        'start_date' => '2017-12-1',
        'end_date' => '2017-12-15',
        'distance' => 1200
      }
    end

    it 'calculates price for 1 day rental (no discount)' do
      rental = Rental.new(one_day_rental_data, car_data)
      expect(rental.price).to eq(3000)
    end

    it 'calculates price for 5 day rental (10% discount after 1 day)' do
      rental = Rental.new(five_day_rental_data, car_data)
      expect(rental.price).to eq(9800)
    end

    it 'calculates price for 12 day rental (30% discount after 4 days)' do
      rental = Rental.new(twelve_day_rental_data, car_data)
      expect(rental.price).to eq(18800)
    end

    it 'calculates price for longer rental' do
      rental = Rental.new(long_rental_data, car_data)
      expect(rental.price).to eq(32800)
    end
  end
end
