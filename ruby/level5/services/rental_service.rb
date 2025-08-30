class RentalService
  def initialize(data)
    @data = data
  end

  def process_rentals
    cars_by_id = @data['cars'].each_with_object({}) { |car, hash| hash[car['id']] = car }
    
    rentals_with_actions = @data['rentals'].map do |rental_data|
      car_data = cars_by_id[rental_data['car_id']]
      
      rental_days = RentalCalculator.rental_days(rental_data['start_date'], rental_data['end_date'])
      options_manager = OptionManager.new(@data['options'], rental_days)
      
      rental = Rental.new(rental: rental_data, car: car_data, options_manager: options_manager)
      
      {
        'id' => rental_data['id'],
        'options' => rental.option_types,
        'actions' => rental.actions
      }
    end

    { 'rentals' => rentals_with_actions }
  end

end
