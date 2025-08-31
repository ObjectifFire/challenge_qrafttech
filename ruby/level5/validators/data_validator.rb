require 'set'
require 'date'
require 'json'
require_relative '../option'

class DataValidator
  def self.validate_and_load_data(input_file_path)
    new(input_file_path).validate_and_load_data
  end

  def initialize(input_file_path)
    @input_file_path = input_file_path
  end

  def validate_and_load_data
    validate_file_exists
    data = load_json_data
    validate_data_structure(data)
    validate_cars_data(data['cars'])
    validate_rentals_data(data['rentals'])
    validate_options_data(data['options']) if data['options']
    validate_rental_car_references(data['rentals'], data['cars'])
    validate_option_rental_references(data['options'], data['rentals']) if data['options']
    data
  end

  private

  def validate_file_exists
    unless File.exist?(@input_file_path)
      raise "Input file not found: #{@input_file_path}"
    end
  end

  def load_json_data
    begin
      JSON.parse(File.read(@input_file_path))
    rescue JSON::ParserError => e
      raise "Invalid JSON format in input file: #{e.message}"
    end
  end

  def validate_data_structure(data)
    unless data.is_a?(Hash) && data.key?('cars') && data.key?('rentals')
      raise "Invalid data structure: must contain 'cars' and 'rentals' keys"
    end

    unless data['cars'].is_a?(Array) && data['rentals'].is_a?(Array)
      raise "Invalid data structure: 'cars' and 'rentals' must be arrays"
    end

    if data['options'] && !data['options'].is_a?(Array)
      raise "Invalid data structure: 'options' must be an array"
    end
  end

  def validate_cars_data(cars)
    cars.each_with_index do |car, index|
      validate_car(car, index)
    end
  end

  def validate_car(car, index)
    required_fields = ['id', 'price_per_day', 'price_per_km']
    
    required_fields.each do |field|
      unless car.key?(field)
        raise "Car at index #{index} missing required field: #{field}"
      end
    end

    unless car['id'].is_a?(Integer) && car['id'] > 0
      raise "Car at index #{index} has invalid id: must be positive integer"
    end

    unless car['price_per_day'].is_a?(Integer) && car['price_per_day'] >= 0
      raise "Car at index #{index} has invalid price_per_day: must be non-negative integer"
    end

    unless car['price_per_km'].is_a?(Integer) && car['price_per_km'] >= 0
      raise "Car at index #{index} has invalid price_per_km: must be non-negative integer"
    end
  end

  def validate_rentals_data(rentals)
    rentals.each_with_index do |rental, index|
      validate_rental(rental, index)
    end
  end

  def validate_rental(rental, index)
    required_fields = ['id', 'car_id', 'start_date', 'end_date', 'distance']
    
    required_fields.each do |field|
      unless rental.key?(field)
        raise "Rental at index #{index} missing required field: #{field}"
      end
    end

    unless rental['id'].is_a?(Integer) && rental['id'] > 0
      raise "Rental at index #{index} has invalid id: must be positive integer"
    end

    unless rental['car_id'].is_a?(Integer) && rental['car_id'] > 0
      raise "Rental at index #{index} has invalid car_id: must be positive integer"
    end

    unless rental['distance'].is_a?(Integer) && rental['distance'] >= 0
      raise "Rental at index #{index} has invalid distance: must be non-negative integer"
    end

    validate_dates(rental['start_date'], rental['end_date'], index)
  end

  def validate_options_data(options)
    options.each_with_index do |option, index|
      validate_option(option, index)
    end
  end

  def validate_option(option, index)
    required_fields = ['id', 'rental_id', 'type']
    
    required_fields.each do |field|
      unless option.key?(field)
        raise "Option at index #{index} missing required field: #{field}"
      end
    end

    unless option['id'].is_a?(Integer) && option['id'] > 0
      raise "Option at index #{index} has invalid id: must be positive integer"
    end

    unless option['rental_id'].is_a?(Integer) && option['rental_id'] > 0
      raise "Option at index #{index} has invalid rental_id: must be positive integer"
    end

    valid_types = Option::TYPES.keys
    unless valid_types.include?(option['type'])
      raise "Option at index #{index} has invalid type: must be one of #{valid_types.join(', ')}"
    end
  end

  def validate_dates(start_date, end_date, rental_index)
    begin
      start = Date.parse(start_date)
      end_d = Date.parse(end_date)
      
      if end_d < start
        raise "Rental at index #{rental_index} has invalid dates: end_date cannot be before start_date"
      end
    rescue Date::Error => e
      raise "Rental at index #{rental_index} has invalid date format: #{e.message}"
    end
  end

  def validate_rental_car_references(rentals, cars)
    car_ids = cars.map { |car| car['id'] }.to_set
    
    rentals.each_with_index do |rental, index|
      unless car_ids.include?(rental['car_id'])
        raise "Rental at index #{index} references non-existent car_id: #{rental['car_id']}"
      end
    end
  end

  def validate_option_rental_references(options, rentals)
    rental_ids = rentals.map { |rental| rental['id'] }.to_set
    
    options.each_with_index do |option, index|
      unless rental_ids.include?(option['rental_id'])
        raise "Option at index #{index} references non-existent rental_id: #{option['rental_id']}"
      end
    end
  end
end
