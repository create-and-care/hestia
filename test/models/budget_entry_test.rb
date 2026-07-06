require "test_helper"

class BudgetEntryTest < ActiveSupport::TestCase
  test "requires an amount" do
    entry = budget_categories(:alpha_rent).budget_entries.build(periodicity: "monthly")
    assert_not entry.valid?
  end

  test "requires a valid periodicity" do
    entry = budget_categories(:alpha_rent).budget_entries.build(amount: 10, periodicity: "weekly")
    assert_not entry.valid?
  end

  test "monthly_amount returns the amount as-is for a monthly entry" do
    entry = BudgetEntry.new(amount: 100, periodicity: "monthly")
    assert_equal 100, entry.monthly_amount
  end

  test "monthly_amount divides a yearly amount by 12" do
    entry = BudgetEntry.new(amount: 1200, periodicity: "yearly")
    assert_equal 100, entry.monthly_amount
  end
end
