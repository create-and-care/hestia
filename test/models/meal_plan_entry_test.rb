require "test_helper"

class MealPlanEntryTest < ActiveSupport::TestCase
  test "requires a recipe or a free name" do
    entry = households(:alpha).meal_plan_entries.build(on_date: Date.current, meal_type: "dinner")
    assert_not entry.valid?
    entry.free_name = "Pizza"
    assert entry.valid?
  end

  test "display_name prefers the recipe title" do
    assert_equal recipes(:alpha_pancakes).title, meal_plan_entries(:alpha_dinner).display_name
    assert_equal "Salade", meal_plan_entries(:beta_lunch).display_name
  end

  test "deleting a recipe keeps the meal as a free name" do
    entry = meal_plan_entries(:alpha_dinner)
    title = entry.recipe.title
    entry.recipe.destroy
    entry.reload
    assert_nil entry.recipe_id
    assert_equal title, entry.free_name
    assert_equal title, entry.display_name
  end

  test "is scoped to its household" do
    assert_not_includes households(:alpha).meal_plan_entries, meal_plan_entries(:beta_lunch)
  end
end
