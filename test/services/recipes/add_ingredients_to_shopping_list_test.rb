require "test_helper"

module Recipes
  class AddIngredientsToShoppingListTest < ActiveSupport::TestCase
    test "adds each ingredient to the shopping list" do
      recipe = recipes(:alpha_pancakes)
      list = shopping_lists(:alpha_groceries)

      assert_difference -> { list.items.count }, recipe.recipe_ingredients.count do
        Recipes::AddIngredientsToShoppingList.call(recipe: recipe, shopping_list: list)
      end
    end
  end
end
