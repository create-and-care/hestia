require "test_helper"

class SharedExpenseTest < ActiveSupport::TestCase
  test "requires an amount" do
    expense = shared_projects(:alpha_trip).shared_expenses.build(description: "Essence")
    assert_not expense.valid?
    expense.amount = 10
    assert expense.valid?
  end

  test "the payer is optional" do
    expense = shared_projects(:alpha_trip).shared_expenses.build(amount: 10)
    assert expense.valid?
  end

  test "recent orders by spent_on then created_at, most recent first" do
    project = households(:alpha).shared_projects.create!(name: "Test recent")
    older = project.shared_expenses.create!(amount: 10, spent_on: 2.days.ago.to_date)
    newer = project.shared_expenses.create!(amount: 20, spent_on: Date.current)

    assert_equal [ newer, older ], project.shared_expenses.recent.to_a
  end
end
