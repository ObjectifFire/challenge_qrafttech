require 'rspec'
require 'date'
require_relative '../../rental'
require_relative '../../commission'
require_relative '../../action'
require_relative '../../action_calculator'
require_relative '../../option'
require_relative '../../option_manager'
require_relative '../../services/rental_service'

RSpec.describe RentalService do
  let(:data_with_options) do
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
      ],
      'options' => [
        { 'id' => 1, 'rental_id' => 1, 'type' => 'gps' },
        { 'id' => 2, 'rental_id' => 1, 'type' => 'baby_seat' }
      ]
    }
  end

  let(:data_without_options_field) do
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

  describe '#process_rentals with options' do
    let(:service) { RentalService.new(data_with_options) }

    it 'returns rentals with options and actions' do
      result = service.process_rentals
      
      expect(result).to have_key('rentals')
      expect(result['rentals']).to be_an(Array)
      expect(result['rentals'].length).to eq(1)
      
      rental = result['rentals'].first
      expect(rental).to have_key('id')
      expect(rental).to have_key('options')
      expect(rental).to have_key('actions')
      expect(rental['id']).to eq(1)
      expect(rental['options']).to eq(['gps', 'baby_seat'])
      expect(rental['actions']).to be_an(Array)
      expect(rental['actions'].length).to eq(5)
    end
  end

  describe '#process_rentals without options field' do
    let(:service) { RentalService.new(data_without_options_field) }

    it 'handles data without options field gracefully' do
      result = service.process_rentals
      
      expect(result).to have_key('rentals')
      expect(result['rentals']).to be_an(Array)
      expect(result['rentals'].length).to eq(1)
      
      rental = result['rentals'].first
      expect(rental).to have_key('id')
      expect(rental).to have_key('options')
      expect(rental).to have_key('actions')
      expect(rental['id']).to eq(1)
      expect(rental['options']).to eq([])
      expect(rental['actions']).to be_an(Array)
      expect(rental['actions'].length).to eq(5)
    end
  end
end
