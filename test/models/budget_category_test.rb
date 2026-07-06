require "test_helper"

class BudgetCategoryTest < ActiveSupport::TestCase
  test "requires a name" do
    category = households(:alpha).budget_categories.build(kind: "expense")
    assert_not category.valid?
    category.name = "Courses"
    assert category.valid?
  end

  test "requires a valid kind" do
    category = households(:alpha).budget_categories.build(name: "Courses", kind: "invalid")
    assert_not category.valid?
  end

  test "ordered scope orders by kind then name" do
    savings = households(:alpha).budget_categories.create!(name: "Épargne", kind: "savings")
    expense = households(:alpha).budget_categories.create!(name: "Zzz", kind: "expense")

    ordered = households(:alpha).budget_categories.ordered
    assert_operator ordered.index(expense), :<, ordered.index(savings)
  end

  test "destroying a category destroys its entries" do
    category = budget_categories(:alpha_rent)
    assert_difference -> { BudgetEntry.count }, -1 do
      category.destroy
    end
  end

  test "is scoped to its household" do
    assert_not_includes households(:alpha).budget_categories, budget_categories(:beta_cat)
  end
end
