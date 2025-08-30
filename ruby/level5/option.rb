class Option
  TYPES = {
    'gps' => { price_per_day: 500, beneficiary: 'owner' },
    'baby_seat' => { price_per_day: 200, beneficiary: 'owner' },
    'additional_insurance' => { price_per_day: 1000, beneficiary: 'drivy' }
  }.freeze

  attr_reader :type, :rental_days

  def initialize(type, rental_days)
    @type = type
    @rental_days = rental_days
  end

  def total_price
    config = TYPES[@type]
    unless config
      raise "Unknown option type: '#{@type}'. Valid types are: #{TYPES.keys.join(', ')}"
    end
    config[:price_per_day] * @rental_days
  end

  def beneficiary
    config = TYPES[@type]
    unless config
      raise "Unknown option type: '#{@type}'. Valid types are: #{TYPES.keys.join(', ')}"
    end
    config[:beneficiary]
  end
end
