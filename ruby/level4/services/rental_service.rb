class RentalService
  def initialize(data)
    @data = data
  end

  def process_rentals
    cars_by_id = @data['cars'].each_with_object({}) { |car, hash| hash[car['id']] = car }
    
    rentals_with_actions = @data['rentals'].map do |rental_data|
      car_data = cars_by_id[rental_data['car_id']]
      rental = Rental.new(rental_data, car_data)
      
      {
        'id' => rental_data['id'],
        'actions' => rental.actions
      }
    end

    { 'rentals' => rentals_with_actions }
  end
end
