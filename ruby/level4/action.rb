class Action
  DEBIT = 'debit'
  CREDIT = 'credit'

  attr_reader :who, :type, :amount

  def initialize(who, type, amount)
    @who = who
    @type = type
    @amount = amount
  end

  def to_hash
    {
      'who' => who,
      'type' => type,
      'amount' => amount
    }
  end
end
