class Commission
  COMMISSION_RATE_PERCENT = 30
  INSURANCE_COMMISSION_RATE_PERCENT = 50
  ASSISTANCE_FEE_PER_DAY = 100

  def initialize(rental_price, rental_days)
    @rental_price = rental_price
    @rental_days = rental_days
  end

  def calculate
    total_commission = (@rental_price * COMMISSION_RATE_PERCENT) / 100
    insurance_fee = (total_commission * INSURANCE_COMMISSION_RATE_PERCENT) / 100
    assistance_fee = @rental_days * ASSISTANCE_FEE_PER_DAY
    drivy_fee = [total_commission - insurance_fee - assistance_fee, 0].max

    {
      'insurance_fee' => insurance_fee,
      'assistance_fee' => assistance_fee,
      'drivy_fee' => drivy_fee
    }
  end
end
