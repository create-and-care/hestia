require "test_helper"

class RecipeIngredientTest < ActiveSupport::TestCase
  test "requires a name" do
    ingredient = recipes(:alpha_pancakes).recipe_ingredients.build
    assert_not ingredient.valid?
    ingredient.name = "Sel"
    assert ingredient.valid?
  end

  test "belongs to a recipe" do
    ingredient = RecipeIngredient.new(name: "Sel")
    assert_not ingredient.valid?
    assert_includes ingredient.errors[:recipe], error_message(:required)
  end

  test "is ordered by position on the recipe" do
    assert_equal [ recipe_ingredients(:pancakes_flour), recipe_ingredients(:pancakes_milk) ],
                 recipes(:alpha_pancakes).recipe_ingredients.to_a
  end
end
