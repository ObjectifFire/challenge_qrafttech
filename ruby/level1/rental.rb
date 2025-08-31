require 'date'

class Rental
  def initialize(rental_data, car_data)
    @rental = rental_data
    @car    = car_data
  end

  def price
    time_cost + distance_cost
  end

  def rental_days(start_date, end_date)
    (Date.parse(end_date) - Date.parse(start_date)).to_i + 1
  end

  private

  def days
    @days ||= rental_days(@rental['start_date'], @rental['end_date'])
  end

  def time_cost
    days * @car['price_per_day']
  end

  def distance_cost
    @rental['distance'] * @car['price_per_km']
  end
end
