class ActionCalculator
  def initialize(rental_price, commission_data)
    @rental_price = rental_price
    @commission_data = commission_data
  end

  def calculate_actions
    [
      Action.new('driver', Action::DEBIT, @rental_price),
      Action.new('owner', Action::CREDIT, owner_amount),
      Action.new('insurance', Action::CREDIT, @commission_data['insurance_fee']),
      Action.new('assistance', Action::CREDIT, @commission_data['assistance_fee']),
      Action.new('drivy', Action::CREDIT, @commission_data['drivy_fee'])
    ]
  end

  private

  def owner_amount
    insurance_fee = @commission_data['insurance_fee']
    assistance_fee = @commission_data['assistance_fee']
    drivy_fee = @commission_data['drivy_fee']
    
    calculated_amount = @rental_price - insurance_fee - assistance_fee - drivy_fee
    [calculated_amount, 0].max
  end
end
