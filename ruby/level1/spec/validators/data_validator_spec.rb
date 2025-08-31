require 'rspec'
require 'json'
require 'date'
require_relative '../../validators/data_validator'
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

    it 'raises error for negative price_per_day' do
      validator = DataValidator.new('dummy')
      invalid_cars = [{ 'id' => 1, 'price_per_day' => -100, 'price_per_km' => 10 }]
      expect {
        validator.send(:validate_cars_data, invalid_cars)
      }.to raise_error(/Car at index 0 has invalid price_per_day: must be non-negative integer/)
    end

    it 'raises error for negative price_per_km' do
      validator = DataValidator.new('dummy')
      invalid_cars = [{ 'id' => 1, 'price_per_day' => 2000, 'price_per_km' => -5 }]
      expect {
        validator.send(:validate_cars_data, invalid_cars)
      }.to raise_error(/Car at index 0 has invalid price_per_km: must be non-negative integer/)
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

    it 'raises error for negative distance' do
      validator = DataValidator.new('dummy')
      invalid_rentals = [{ 'id' => 1, 'car_id' => 1, 'start_date' => '2017-12-8', 'end_date' => '2017-12-10', 'distance' => -50 }]
      expect {
        validator.send(:validate_rentals_data, invalid_rentals)
      }.to raise_error(/Rental at index 0 has invalid distance: must be non-negative integer/)
    end

    it 'raises error for invalid date format' do
      validator = DataValidator.new('dummy')
      invalid_rentals = [{ 'id' => 1, 'car_id' => 1, 'start_date' => '2017-13-01', 'end_date' => '2017-12-10', 'distance' => 100 }]
      expect {
        validator.send(:validate_rentals_data, invalid_rentals)
      }.to raise_error(/Rental at index 0 has invalid date format/)
    end

    it 'raises error for end_date before start_date' do
      validator = DataValidator.new('dummy')
      invalid_rentals = [{ 'id' => 1, 'car_id' => 1, 'start_date' => '2017-12-10', 'end_date' => '2017-12-8', 'distance' => 100 }]
      expect {
        validator.send(:validate_rentals_data, invalid_rentals)
      }.to raise_error(/Rental at index 0 has invalid dates: end_date cannot be before start_date/)
    end

    it 'raises error for invalid date format with non-numeric values' do
      validator = DataValidator.new('dummy')
      invalid_rentals = [{ 'id' => 1, 'car_id' => 1, 'start_date' => '2017-aa-01', 'end_date' => '2017-12-10', 'distance' => 100 }]
      expect {
        validator.send(:validate_rentals_data, invalid_rentals)
      }.to raise_error(/Rental at index 0 has invalid date format/)
    end
  end
end
