require 'rspec'
require 'json'
require 'date'
require_relative '../../validators/data_validator'
require_relative '../../option'
require 'tempfile'

RSpec.describe DataValidator do
  let(:valid_data) do
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
        {
          'id' => 1,
          'rental_id' => 1,
          'type' => 'gps'
        }
      ]
    }
  end

  describe '.validate_and_load_data' do
    context 'with valid file' do
      let(:temp_file) do
        file = Tempfile.new(['input', '.json'])
        file.write(valid_data.to_json)
        file.close
        file.path
      end

      after { File.delete(temp_file) }

      it 'loads and validates data successfully' do
        result = DataValidator.validate_and_load_data(temp_file)
        expect(result).to eq(valid_data)
      end
    end

    context 'with missing file' do
      it 'raises an error' do
        expect {
          DataValidator.validate_and_load_data('nonexistent.json')
        }.to raise_error(/Input file not found/)
      end
    end

    context 'with invalid JSON' do
      let(:temp_file) do
        file = Tempfile.new(['input', '.json'])
        file.write('invalid json content')
        file.close
        file.path
      end

      after { File.delete(temp_file) }

      it 'raises an error' do
        expect {
          DataValidator.validate_and_load_data(temp_file)
        }.to raise_error(/Invalid JSON format/)
      end
    end

    context 'with missing required keys' do
      let(:temp_file) do
        file = Tempfile.new(['input', '.json'])
        file.write({ 'cars' => [] }.to_json)
        file.close
        file.path
      end

      after { File.delete(temp_file) }

      it 'raises an error' do
        expect {
          DataValidator.validate_and_load_data(temp_file)
        }.to raise_error(/Invalid data structure/)
      end
    end
  end

  describe '#validate_data_structure' do
    it 'accepts valid data structure' do
      validator = DataValidator.new('dummy')
      expect { validator.send(:validate_data_structure, valid_data) }.not_to raise_error
    end

    it 'rejects data missing cars key' do
      validator = DataValidator.new('dummy')
      data_without_cars = valid_data.reject { |k, _| k == 'cars' }
      expect {
        validator.send(:validate_data_structure, data_without_cars)
      }.to raise_error(/Invalid data structure/)
    end

    it 'rejects data missing rentals key' do
      validator = DataValidator.new('dummy')
      data_without_rentals = valid_data.reject { |k, _| k == 'rentals' }
      expect {
        validator.send(:validate_data_structure, data_without_rentals)
      }.to raise_error(/Invalid data structure/)
    end

    it 'rejects data where cars is not an array' do
      validator = DataValidator.new('dummy')
      invalid_data = valid_data.merge('cars' => 'not_an_array')
      expect {
        validator.send(:validate_data_structure, invalid_data)
      }.to raise_error(/Invalid data structure/)
    end

    it 'rejects data where rentals is not an array' do
      validator = DataValidator.new('dummy')
      invalid_data = valid_data.merge('rentals' => 'not_an_array')
      expect {
        validator.send(:validate_data_structure, invalid_data)
      }.to raise_error(/Invalid data structure/)
    end

    it 'rejects data where options is not an array' do
      validator = DataValidator.new('dummy')
      invalid_data = valid_data.merge('options' => 'not_an_array')
      expect {
        validator.send(:validate_data_structure, invalid_data)
      }.to raise_error(/Invalid data structure/)
    end

    it 'accepts data without options' do
      validator = DataValidator.new('dummy')
      data_without_options = valid_data.reject { |k, _| k == 'options' }
      expect { validator.send(:validate_data_structure, data_without_options) }.not_to raise_error
    end
  end

  describe '#validate_cars_data' do
    it 'validates correct car data' do
      validator = DataValidator.new('dummy')
      expect { validator.send(:validate_cars_data, valid_data['cars']) }.not_to raise_error
    end

    it 'raises error for missing car id' do
      validator = DataValidator.new('dummy')
      invalid_cars = [{ 'price_per_day' => 2000, 'price_per_km' => 10 }]
      expect {
        validator.send(:validate_cars_data, invalid_cars)
      }.to raise_error(/Car at index 0 missing required field: id/)
    end

    it 'raises error for missing price_per_day' do
      validator = DataValidator.new('dummy')
      invalid_cars = [{ 'id' => 1, 'price_per_km' => 10 }]
      expect {
        validator.send(:validate_cars_data, invalid_cars)
      }.to raise_error(/Car at index 0 missing required field: price_per_day/)
    end

    it 'raises error for missing price_per_km' do
      validator = DataValidator.new('dummy')
      invalid_cars = [{ 'id' => 1, 'price_per_day' => 2000 }]
      expect {
        validator.send(:validate_cars_data, invalid_cars)
      }.to raise_error(/Car at index 0 missing required field: price_per_km/)
    end

    it 'raises error for invalid car id' do
      validator = DataValidator.new('dummy')
      invalid_cars = [{ 'id' => 0, 'price_per_day' => 2000, 'price_per_km' => 10 }]
      expect {
        validator.send(:validate_cars_data, invalid_cars)
      }.to raise_error(/Car at index 0 has invalid id/)
    end

    it 'raises error for negative price_per_day' do
      validator = DataValidator.new('dummy')
      invalid_cars = [{ 'id' => 1, 'price_per_day' => -100, 'price_per_km' => 10 }]
      expect {
        validator.send(:validate_cars_data, invalid_cars)
      }.to raise_error(/Car at index 0 has invalid price_per_day/)
    end

    it 'raises error for negative price_per_km' do
      validator = DataValidator.new('dummy')
      invalid_cars = [{ 'id' => 1, 'price_per_day' => 2000, 'price_per_km' => -5 }]
      expect {
        validator.send(:validate_cars_data, invalid_cars)
      }.to raise_error(/Car at index 0 has invalid price_per_km/)
    end
  end

  describe '#validate_rentals_data' do
    it 'validates correct rental data' do
      validator = DataValidator.new('dummy')
      expect { validator.send(:validate_rentals_data, valid_data['rentals']) }.not_to raise_error
    end

    it 'raises error for missing rental id' do
      validator = DataValidator.new('dummy')
      invalid_rentals = [{ 'car_id' => 1, 'start_date' => '2017-12-8', 'end_date' => '2017-12-10', 'distance' => 100 }]
      expect {
        validator.send(:validate_rentals_data, invalid_rentals)
      }.to raise_error(/Rental at index 0 missing required field: id/)
    end

    it 'raises error for missing car_id' do
      validator = DataValidator.new('dummy')
      invalid_rentals = [{ 'id' => 1, 'start_date' => '2017-12-8', 'end_date' => '2017-12-10', 'distance' => 100 }]
      expect {
        validator.send(:validate_rentals_data, invalid_rentals)
      }.to raise_error(/Rental at index 0 missing required field: car_id/)
    end

    it 'raises error for missing start_date' do
      validator = DataValidator.new('dummy')
      invalid_rentals = [{ 'id' => 1, 'car_id' => 1, 'end_date' => '2017-12-10', 'distance' => 100 }]
      expect {
        validator.send(:validate_rentals_data, invalid_rentals)
      }.to raise_error(/Rental at index 0 missing required field: start_date/)
    end

    it 'raises error for missing end_date' do
      validator = DataValidator.new('dummy')
      invalid_rentals = [{ 'id' => 1, 'car_id' => 1, 'start_date' => '2017-12-8', 'distance' => 100 }]
      expect {
        validator.send(:validate_rentals_data, invalid_rentals)
      }.to raise_error(/Rental at index 0 missing required field: end_date/)
    end

    it 'raises error for missing distance' do
      validator = DataValidator.new('dummy')
      invalid_rentals = [{ 'id' => 1, 'car_id' => 1, 'start_date' => '2017-12-8', 'end_date' => '2017-12-10' }]
      expect {
        validator.send(:validate_rentals_data, invalid_rentals)
      }.to raise_error(/Rental at index 0 missing required field: distance/)
    end

    it 'raises error for invalid rental id' do
      validator = DataValidator.new('dummy')
      invalid_rentals = [{ 'id' => 0, 'car_id' => 1, 'start_date' => '2017-12-8', 'end_date' => '2017-12-10', 'distance' => 100 }]
      expect {
        validator.send(:validate_rentals_data, invalid_rentals)
      }.to raise_error(/Rental at index 0 has invalid id/)
    end

    it 'raises error for invalid car_id' do
      validator = DataValidator.new('dummy')
      invalid_rentals = [{ 'id' => 1, 'car_id' => 0, 'start_date' => '2017-12-8', 'end_date' => '2017-12-10', 'distance' => 100 }]
      expect {
        validator.send(:validate_rentals_data, invalid_rentals)
      }.to raise_error(/Rental at index 0 has invalid car_id/)
    end

    it 'raises error for negative distance' do
      validator = DataValidator.new('dummy')
      invalid_rentals = [{ 'id' => 1, 'car_id' => 1, 'start_date' => '2017-12-8', 'end_date' => '2017-12-10', 'distance' => -50 }]
      expect {
        validator.send(:validate_rentals_data, invalid_rentals)
      }.to raise_error(/Rental at index 0 has invalid distance/)
    end
  end

  describe '#validate_options_data' do
    it 'validates correct option data' do
      validator = DataValidator.new('dummy')
      expect { validator.send(:validate_options_data, valid_data['options']) }.not_to raise_error
    end

    it 'raises error for missing option id' do
      validator = DataValidator.new('dummy')
      invalid_options = [{ 'rental_id' => 1, 'type' => 'gps' }]
      expect {
        validator.send(:validate_options_data, invalid_options)
      }.to raise_error(/Option at index 0 missing required field: id/)
    end

    it 'raises error for missing rental_id' do
      validator = DataValidator.new('dummy')
      invalid_options = [{ 'id' => 1, 'type' => 'gps' }]
      expect {
        validator.send(:validate_options_data, invalid_options)
      }.to raise_error(/Option at index 0 missing required field: rental_id/)
    end

    it 'raises error for missing type' do
      validator = DataValidator.new('dummy')
      invalid_options = [{ 'id' => 1, 'rental_id' => 1 }]
      expect {
        validator.send(:validate_options_data, invalid_options)
      }.to raise_error(/Option at index 0 missing required field: type/)
    end

    it 'raises error for invalid option id' do
      validator = DataValidator.new('dummy')
      invalid_options = [{ 'id' => 0, 'rental_id' => 1, 'type' => 'gps' }]
      expect {
        validator.send(:validate_options_data, invalid_options)
      }.to raise_error(/Option at index 0 has invalid id/)
    end

    it 'raises error for invalid rental_id' do
      validator = DataValidator.new('dummy')
      invalid_options = [{ 'id' => 1, 'rental_id' => 0, 'type' => 'gps' }]
      expect {
        validator.send(:validate_options_data, invalid_options)
      }.to raise_error(/Option at index 0 has invalid rental_id/)
    end

    it 'raises error for invalid option type' do
      validator = DataValidator.new('dummy')
      invalid_options = [{ 'id' => 1, 'rental_id' => 1, 'type' => 'invalid_type' }]
      expect {
        validator.send(:validate_options_data, invalid_options)
      }.to raise_error(/Option at index 0 has invalid type/)
    end

    it 'accepts valid option types' do
      validator = DataValidator.new('dummy')
      valid_option_types = [
        { 'id' => 1, 'rental_id' => 1, 'type' => 'gps' },
        { 'id' => 2, 'rental_id' => 1, 'type' => 'baby_seat' },
        { 'id' => 3, 'rental_id' => 1, 'type' => 'additional_insurance' }
      ]
      expect { validator.send(:validate_options_data, valid_option_types) }.not_to raise_error
    end
  end

  describe '#validate_dates' do
    it 'validates correct dates' do
      validator = DataValidator.new('dummy')
      expect { validator.send(:validate_dates, '2017-12-8', '2017-12-10', 0) }.not_to raise_error
    end

    it 'raises error for end_date before start_date' do
      validator = DataValidator.new('dummy')
      expect {
        validator.send(:validate_dates, '2017-12-10', '2017-12-8', 0)
      }.to raise_error(/Rental at index 0 has invalid dates/)
    end

    it 'raises error for invalid date format' do
      validator = DataValidator.new('dummy')
      expect {
        validator.send(:validate_dates, 'invalid-date', '2017-12-10', 0)
      }.to raise_error(/Rental at index 0 has invalid date format/)
    end
  end

  describe '#validate_rental_car_references' do
    it 'validates correct references' do
      validator = DataValidator.new('dummy')
      expect { validator.send(:validate_rental_car_references, valid_data['rentals'], valid_data['cars']) }.not_to raise_error
    end

    it 'raises error for non-existent car_id' do
      validator = DataValidator.new('dummy')
      invalid_rentals = [{ 'id' => 1, 'car_id' => 999, 'start_date' => '2017-12-8', 'end_date' => '2017-12-10', 'distance' => 100 }]
      expect {
        validator.send(:validate_rental_car_references, invalid_rentals, valid_data['cars'])
      }.to raise_error(/Rental at index 0 references non-existent car_id/)
    end
  end

  describe '#validate_option_rental_references' do
    it 'validates correct references' do
      validator = DataValidator.new('dummy')
      expect { validator.send(:validate_option_rental_references, valid_data['options'], valid_data['rentals']) }.not_to raise_error
    end

    it 'raises error for non-existent rental_id' do
      validator = DataValidator.new('dummy')
      invalid_options = [{ 'id' => 1, 'rental_id' => 999, 'type' => 'gps' }]
      expect {
        validator.send(:validate_option_rental_references, invalid_options, valid_data['rentals'])
      }.to raise_error(/Option at index 0 references non-existent rental_id/)
    end
  end
end
