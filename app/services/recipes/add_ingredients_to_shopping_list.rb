module Recipes
  # Exports a recipe's ingredients to a shopping list. Without
  # duplicate merging or unit conversion (a Hest.AI capability).
  #
  # Ingredients are always entered/imported as a single free-text line (e.g.
  # "200 g de farine") — RecipeIngredient#quantity/#unit are never populated
  # by any code path today, so they're deliberately not passed through here;
  # wiring them up for real means parsing that free text into structured
  # fields first, which belongs with the Hest.AI extraction work above.
  class AddIngredientsToShoppingList
    def self.call(recipe:, shopping_list:)
      recipe.recipe_ingredients.map do |ingredient|
        Courses::AddItem.call(
          shopping_list: shopping_list,
          name: ingredient.name,
          recipe: recipe
        )
      end
    end
  end
end
