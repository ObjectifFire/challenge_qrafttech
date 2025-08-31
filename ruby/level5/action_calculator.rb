class ActionCalculator
  def initialize(rental_price, commission_data, options_manager, rental_id)
    @rental_price = rental_price
    @commission_data = commission_data
    @options_manager = options_manager
    @rental_id = rental_id
  end

  def calculate_actions
    options_price = @options_manager.total_options_price(@rental_id)
    additional_amounts = @options_manager.additional_amounts_by_beneficiary(@rental_id)
    
    total_price = @rental_price + options_price
    
    [
      Action.new('driver', Action::DEBIT, total_price),
      Action.new('owner', Action::CREDIT, owner_amount(additional_amounts)),
      Action.new('insurance', Action::CREDIT, @commission_data['insurance_fee']),
      Action.new('assistance', Action::CREDIT, @commission_data['assistance_fee']),
      Action.new('drivy', Action::CREDIT, drivy_amount(additional_amounts))
    ]
  end

  private

  def owner_amount(additional_amounts)
    base_owner_amount = @rental_price - @commission_data['insurance_fee'] - @commission_data['assistance_fee'] - @commission_data['drivy_fee']
    owner_options_amount = additional_amounts['owner'] || 0
    base_owner_amount + owner_options_amount
  end

  def drivy_amount(additional_amounts)
    base_drivy_amount = @commission_data['drivy_fee']
    drivy_options_amount = additional_amounts['drivy'] || 0
    base_drivy_amount + drivy_options_amount
  end
end
