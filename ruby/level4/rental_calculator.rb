require 'date'

module RentalCalculator
  def self.rental_days(start_date, end_date)
    (Date.parse(end_date) - Date.parse(start_date)).to_i + 1
  end

  def self.discounted_time_cost(total_days, price_per_day, discount_tiers)
    cost = 0
    covered_days = 0

    discount_tiers.each do |upto_day, discount_percent|
      days_in_tier = [total_days - covered_days, upto_day - covered_days].min
      break if days_in_tier <= 0

      discounted_price = (days_in_tier * price_per_day * (100 - discount_percent)) / 100
      cost += discounted_price
      covered_days += days_in_tier
    end
    cost
  end
end
