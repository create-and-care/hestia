require "test_helper"

class RecipeTest < ActiveSupport::TestCase
  test "requires a title" do
    recipe = households(:alpha).recipes.build
    assert_not recipe.valid?
    recipe.title = "Test"
    assert recipe.valid?
  end

  test "text helpers join the children" do
    recipe = recipes(:alpha_pancakes)
    assert_includes recipe.ingredients_text, "farine"
    assert_includes recipe.steps_text, "Mélanger"
  end

  test "total_time_minutes sums prep and cook" do
    assert_equal 25, recipes(:alpha_pancakes).total_time_minutes
    assert_nil Recipe.new.total_time_minutes
  end

  test "is scoped to its household" do
    assert_not_includes households(:alpha).recipes, recipes(:beta_soup)
  end
end
