require 'rspec'
require_relative '../rental_calculator'

RSpec.describe RentalCalculator do
  describe '.rental_days' do
    it 'calculates rental days correctly' do
      expect(RentalCalculator.rental_days('2017-12-8', '2017-12-10')).to eq(3)
    end

    it 'calculates single day rental' do
      expect(RentalCalculator.rental_days('2017-12-8', '2017-12-8')).to eq(1)
    end

    it 'calculates long rental period' do
      expect(RentalCalculator.rental_days('2017-12-1', '2017-12-31')).to eq(31)
    end

    it 'handles leap year dates' do
      expect(RentalCalculator.rental_days('2020-02-28', '2020-03-01')).to eq(3)
    end

    it 'handles month boundary' do
      expect(RentalCalculator.rental_days('2017-11-30', '2017-12-02')).to eq(3)
    end

    it 'handles year boundary' do
      expect(RentalCalculator.rental_days('2017-12-31', '2018-01-02')).to eq(3)
    end
  end

  describe '.discounted_time_cost' do
    let(:discount_tiers) do
      {
        1 => 0,
        4 => 10,
        10 => 30,
        Float::INFINITY => 50
      }
    end

    it 'calculates cost for 1 day rental' do
      expect(RentalCalculator.discounted_time_cost(1, 2000, discount_tiers)).to eq(2000)
    end

    it 'calculates cost for 3 day rental' do
      expect(RentalCalculator.discounted_time_cost(3, 2000, discount_tiers)).to eq(5600)
    end

    it 'calculates cost for 5 day rental' do
      expect(RentalCalculator.discounted_time_cost(5, 2000, discount_tiers)).to eq(8800)
    end

    it 'calculates cost for 12 day rental' do
      expect(RentalCalculator.discounted_time_cost(12, 2000, discount_tiers)).to eq(17800)
    end

    it 'calculates cost for 15 day rental' do
      expect(RentalCalculator.discounted_time_cost(15, 2000, discount_tiers)).to eq(20800)
    end

    it 'handles zero price per day' do
      expect(RentalCalculator.discounted_time_cost(5, 0, discount_tiers)).to eq(0)
    end

    it 'handles zero days' do
      expect(RentalCalculator.discounted_time_cost(0, 2000, discount_tiers)).to eq(0)
    end

    it 'works with different discount tiers' do
      custom_tiers = { 1 => 0, 3 => 20, Float::INFINITY => 40 }
      expect(RentalCalculator.discounted_time_cost(5, 1000, custom_tiers)).to eq(3800)
    end
  end
end
