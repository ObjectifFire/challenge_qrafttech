require 'rspec'
require_relative '../action'
require_relative '../action_calculator'
require_relative '../option_manager'
require_relative '../option'

RSpec.describe ActionCalculator do
  let(:rental_price) { 7000 }
  let(:commission_data) do
    {
      'insurance_fee' => 1050,
      'assistance_fee' => 300,
      'drivy_fee' => 750
    }
  end

  let(:options_manager) { OptionManager.new([], 3) }
  let(:rental_id) { 1 }
  let(:calculator) { ActionCalculator.new(rental_price, commission_data, options_manager, rental_id) }

  describe '#calculate_actions' do
    it 'returns array of actions' do
      actions = calculator.calculate_actions
      
      expect(actions).to be_an(Array)
      expect(actions.length).to eq(5)
    end

    it 'creates correct driver action without options' do
      actions = calculator.calculate_actions
      driver_action = actions.find { |action| action.to_hash['who'] == 'driver' }
      
      expect(driver_action.to_hash).to eq({
        'who' => 'driver',
        'type' => 'debit',
        'amount' => 7000
      })
    end

    it 'creates correct owner action without options' do
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

    it 'creates correct drivy action without options' do
      actions = calculator.calculate_actions
      drivy_action = actions.find { |action| action.to_hash['who'] == 'drivy' }
      
      expect(drivy_action.to_hash).to eq({
        'who' => 'drivy',
        'type' => 'credit',
        'amount' => 750
      })
    end

    context 'with options' do
      let(:options_data) do
        [
          { 'id' => 1, 'rental_id' => 1, 'type' => 'gps' },
          { 'id' => 2, 'rental_id' => 1, 'type' => 'baby_seat' }
        ]
      end

      let(:options_manager_with_options) { OptionManager.new(options_data, 3) }
      let(:calculator_with_options) { ActionCalculator.new(rental_price, commission_data, options_manager_with_options, rental_id) }

      it 'creates correct driver action with options' do
        actions = calculator_with_options.calculate_actions
        driver_action = actions.find { |action| action.to_hash['who'] == 'driver' }
        
        options_price = (Option::TYPES['gps'][:price_per_day] + Option::TYPES['baby_seat'][:price_per_day]) * 3
        expected_amount = rental_price + options_price
        
        expect(driver_action.to_hash).to eq({
          'who' => 'driver',
          'type' => 'debit',
          'amount' => expected_amount
        })
      end

      it 'creates correct owner action with options' do
        actions = calculator_with_options.calculate_actions
        owner_action = actions.find { |action| action.to_hash['who'] == 'owner' }
        
        options_price = (Option::TYPES['gps'][:price_per_day] + Option::TYPES['baby_seat'][:price_per_day]) * 3
        expected_amount = rental_price - commission_data['insurance_fee'] - commission_data['assistance_fee'] - commission_data['drivy_fee'] + options_price
        
        expect(owner_action.to_hash).to eq({
          'who' => 'owner',
          'type' => 'credit',
          'amount' => expected_amount
        })
      end

      it 'creates correct drivy action with options' do
        actions = calculator_with_options.calculate_actions
        drivy_action = actions.find { |action| action.to_hash['who'] == 'drivy' }
        
        expect(drivy_action.to_hash).to eq({
          'who' => 'drivy',
          'type' => 'credit',
          'amount' => 750
        })
      end
    end
  end

  describe '#owner_amount' do
    it 'calculates owner amount correctly without options' do
      expect(calculator.send(:owner_amount, {})).to eq(4900)
    end

    it 'calculates owner amount with owner options' do
      additional_amounts = { 'owner' => 1500 }
      expect(calculator.send(:owner_amount, additional_amounts)).to eq(6400)
    end

    it 'calculates owner amount for different commission data' do
      different_commission = {
        'insurance_fee' => 500,
        'assistance_fee' => 200,
        'drivy_fee' => 300
      }
      calculator = ActionCalculator.new(5000, different_commission, options_manager, rental_id)
      
      expect(calculator.send(:owner_amount, {})).to eq(4000)
    end
  end

  describe '#drivy_amount' do
    it 'calculates drivy amount correctly without options' do
      expect(calculator.send(:drivy_amount, {})).to eq(750)
    end

    it 'calculates drivy amount with drivy options' do
      additional_amounts = { 'drivy' => 500 }
      expect(calculator.send(:drivy_amount, additional_amounts)).to eq(1250)
    end
  end

  describe 'action validation' do
    it 'ensures total debits equal total credits without options' do
      actions = calculator.calculate_actions
      
      total_debits = actions.select { |action| action.to_hash['type'] == 'debit' }
                           .sum { |action| action.to_hash['amount'] }
      
      total_credits = actions.select { |action| action.to_hash['type'] == 'credit' }
                            .sum { |action| action.to_hash['amount'] }
      
      expect(total_debits).to eq(total_credits)
    end

    it 'ensures total debits equal total credits with options' do
      options_data = [
        { 'id' => 1, 'rental_id' => 1, 'type' => 'gps' },
        { 'id' => 2, 'rental_id' => 1, 'type' => 'baby_seat' }
      ]
      options_manager_with_options = OptionManager.new(options_data, 3)
      calculator_with_options = ActionCalculator.new(rental_price, commission_data, options_manager_with_options, rental_id)
      
      actions = calculator_with_options.calculate_actions
      
      total_debits = actions.select { |action| action.to_hash['type'] == 'debit' }
                           .sum { |action| action.to_hash['amount'] }
      
      total_credits = actions.select { |action| action.to_hash['type'] == 'credit' }
                            .sum { |action| action.to_hash['amount'] }
      
      expect(total_debits).to eq(total_credits)
    end
  end
end
