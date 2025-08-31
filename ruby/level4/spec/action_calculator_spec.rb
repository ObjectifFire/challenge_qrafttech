require 'rspec'
require_relative '../action'
require_relative '../action_calculator'

RSpec.describe ActionCalculator do
  let(:rental_price) { 7000 }
  let(:commission_data) do
    {
      'insurance_fee' => 1050,
      'assistance_fee' => 300,
      'drivy_fee' => 750
    }
  end

  let(:calculator) { ActionCalculator.new(rental_price, commission_data) }

  describe '#calculate_actions' do
    it 'returns array of actions' do
      actions = calculator.calculate_actions
      
      expect(actions).to be_an(Array)
      expect(actions.length).to eq(5)
    end

    it 'creates correct driver action' do
      actions = calculator.calculate_actions
      driver_action = actions.find { |action| action.to_hash['who'] == 'driver' }
      
      expect(driver_action.to_hash).to eq({
        'who' => 'driver',
        'type' => 'debit',
        'amount' => 7000
      })
    end

    it 'creates correct owner action' do
      actions = calculator.calculate_actions
      owner_action = actions.find { |action| action.to_hash['who'] == 'owner' }
      
      expect(owner_action.to_hash).to eq({
        'who' => 'owner',
        'type' => 'credit',
        'amount' => 4900
      })
    end

    it 'creates correct insurance action' do
      actions = calculator.calculate_actions
      insurance_action = actions.find { |action| action.to_hash['who'] == 'insurance' }
      
      expect(insurance_action.to_hash).to eq({
        'who' => 'insurance',
        'type' => 'credit',
        'amount' => 1050
      })
    end

    it 'creates correct assistance action' do
      actions = calculator.calculate_actions
      assistance_action = actions.find { |action| action.to_hash['who'] == 'assistance' }
      
      expect(assistance_action.to_hash).to eq({
        'who' => 'assistance',
        'type' => 'credit',
        'amount' => 300
      })
    end

    it 'creates correct drivy action' do
      actions = calculator.calculate_actions
      drivy_action = actions.find { |action| action.to_hash['who'] == 'drivy' }
      
      expect(drivy_action.to_hash).to eq({
        'who' => 'drivy',
        'type' => 'credit',
        'amount' => 750
      })
    end
  end

  describe '#owner_amount' do
    it 'calculates owner amount correctly' do
      expect(calculator.send(:owner_amount)).to eq(4900)
    end

    it 'calculates owner amount for different commission data' do
      different_commission = {
        'insurance_fee' => 500,
        'assistance_fee' => 200,
        'drivy_fee' => 300
      }
      calculator = ActionCalculator.new(5000, different_commission)
      
      expect(calculator.send(:owner_amount)).to eq(4000)
    end

    it 'ensures owner amount is never negative when commission exceeds rental price' do
      high_commission = {
        'insurance_fee' => 4000,
        'assistance_fee' => 2000,
        'drivy_fee' => 1500
      }
      calculator = ActionCalculator.new(5000, high_commission)
      
      owner_amount = calculator.send(:owner_amount)
      expect(owner_amount).to be >= 0
    end

    it 'handles case where commission exactly equals rental price' do
      exact_commission = {
        'insurance_fee' => 3000,
        'assistance_fee' => 1000,
        'drivy_fee' => 1000
      }
      calculator = ActionCalculator.new(5000, exact_commission)
      
      expect(calculator.send(:owner_amount)).to eq(0)
    end
  end

  describe 'action validation' do
    it 'ensures total debits equal total credits' do
      actions = calculator.calculate_actions
      
      total_debits = actions.select { |action| action.to_hash['type'] == 'debit' }
                           .sum { |action| action.to_hash['amount'] }
      
      total_credits = actions.select { |action| action.to_hash['type'] == 'credit' }
                            .sum { |action| action.to_hash['amount'] }
      
      expect(total_debits).to eq(total_credits)
    end
  end
end
