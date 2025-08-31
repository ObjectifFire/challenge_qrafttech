require 'rspec'
require_relative '../action'

RSpec.describe Action do
  describe '#to_hash' do
    it 'returns correct hash structure for driver debit' do
      action = Action.new('driver', Action::DEBIT, 1000)
      
      expect(action.to_hash).to eq({
        'who' => 'driver',
        'type' => 'debit',
        'amount' => 1000
      })
    end

    it 'returns correct hash structure for owner credit' do
      action = Action.new('owner', Action::CREDIT, 500)
      
      expect(action.to_hash).to eq({
        'who' => 'owner',
        'type' => 'credit',
        'amount' => 500
      })
    end

    it 'returns correct hash structure for insurance action' do
      action = Action.new('insurance', Action::CREDIT, 300)
      
      expect(action.to_hash).to eq({
        'who' => 'insurance',
        'type' => 'credit',
        'amount' => 300
      })
    end

    it 'returns correct hash structure for assistance action' do
      action = Action.new('assistance', Action::CREDIT, 100)
      
      expect(action.to_hash).to eq({
        'who' => 'assistance',
        'type' => 'credit',
        'amount' => 100
      })
    end

    it 'returns correct hash structure for drivy action' do
      action = Action.new('drivy', Action::CREDIT, 200)
      
      expect(action.to_hash).to eq({
        'who' => 'drivy',
        'type' => 'credit',
        'amount' => 200
      })
    end
  end
end
