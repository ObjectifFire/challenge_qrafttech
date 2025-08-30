require_relative 'rental_calculator'

class Rental
  DISCOUNTS = {
    1 => 0,
    4 => 10,
    10 => 30,
    Float::INFINITY => 50
  }.freeze

  def initialize(rental_data, car_data)
    @rental = rental_data
    @car    = car_data
  end

  def price
    time_cost + distance_cost
  end

  def rental_days(start_date, end_date)
    RentalCalculator.rental_days(start_date, end_date)
  end

  private

  def days
    @days ||= rental_days(@rental['start_date'], @rental['end_date'])
  end

  def time_cost
    RentalCalculator.discounted_time_cost(days, @car['price_per_day'], DISCOUNTS)
  end

  def distance_cost
    @rental['distance'] * @car['price_per_km']
  end
end
