class OptionManager
  def initialize(options_data, rental_days)
    @options_data = options_data || []
    @rental_days = rental_days
  end

  def options_for_rental(rental_id)
    rental_options = @options_data.select { |option| option['rental_id'] == rental_id }
    unique_options = rental_options.uniq { |option| option['type'] }
    unique_options.map { |option| Option.new(option['type'], @rental_days) }
  end

  def total_options_price(rental_id)
    options = options_for_rental(rental_id)
    options.sum do |option|
      begin
        option.total_price
      rescue => e
        raise "Error processing option for rental #{rental_id}: #{e.message}"
      end
    end
  end

  def option_types_for_rental(rental_id)
    options_for_rental(rental_id).map(&:type)
  end

  def options_by_beneficiary(rental_id)
    options_for_rental(rental_id).group_by(&:beneficiary)
  end

  def additional_amounts_by_beneficiary(rental_id)
    options_by_beneficiary(rental_id).transform_values do |options|
      options.sum(&:total_price)
    end
  end
end
