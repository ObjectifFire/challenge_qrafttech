require 'json'
require_relative 'rental'
require_relative 'commission'
require_relative 'action'
require_relative 'action_calculator'
require_relative 'option'
require_relative 'option_manager'
require_relative 'validators/data_validator'
require_relative 'services/rental_service'

begin
  input_file = 'data/input.json'
  output_file = 'data/output.json'

  data = DataValidator.validate_and_load_data(input_file)
  rental_service = RentalService.new(data)
  result = rental_service.process_rentals

  File.write(output_file, JSON.pretty_generate(result))
  puts "Successfully generated #{output_file}"

rescue => e
  puts "Error: #{e.message}"
  exit 1
end
