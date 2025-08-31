require 'rspec'
require 'date'
require_relative '../../rental'
require_relative '../../services/rental_service'

RSpec.describe RentalService do
  let(:data) do
    {
      'cars' => [
        {
          'id' => 1,
          'price_per_day' => 2000,
          'price_per_km' => 10
        }
      ],
      'rentals' => [
        {
          'id' => 1,
          'car_id' => 1,
          'start_date' => '2017-12-8',
          'end_date' => '2017-12-10',
          'distance' => 100
        }
      ]
    }
  end

  let(:service) { RentalService.new(data) }

  describe '#process_rentals' do
    it 'returns rentals with prices' do
      result = service.process_rentals
      
      expect(result).to have_key('rentals')
      expect(result['rentals']).to be_an(Array)
      expect(result['rentals'].length).to eq(1)
      
      rental = result['rentals'].first
      expect(rental).to have_key('id')
      expect(rental).to have_key('price')
      expect(rental['id']).to eq(1)
      expect(rental['price']).to eq(6600)
    end
  end
end
