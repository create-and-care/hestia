require "test_helper"

module Budget
  class SummaryTest < ActiveSupport::TestCase
    test "monthly summary aggregates income, expense, savings and remaining" do
      summary = Budget::Summary.call(household: households(:alpha), period: :monthly)
      assert_equal 2000, summary[:income]
      assert_equal 800, summary[:expense]
      assert_equal 200, summary[:savings] # enveloppe Vacances
      assert_equal 1000, summary[:remaining]
      assert_equal 10, summary[:savings_rate]
    end

    test "annual view scales monthly figures by twelve" do
      summary = Budget::Summary.call(household: households(:alpha), period: :annual)
      assert_equal 24000, summary[:income]
      assert_equal 12000, summary[:remaining]
    end
  end
end
