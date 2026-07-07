module Recipes
  # Exports a recipe's ingredients to a shopping list. In Phase 2, without
  # duplicate merging or unit conversion (a Hest.AI capability, Phase 3 — Spec §9.5).
  class AddIngredientsToShoppingList
    def self.call(recipe:, shopping_list:)
      recipe.recipe_ingredients.map do |ingredient|
        Courses::AddItem.call(
          shopping_list: shopping_list,
          name: ingredient.name,
          quantity: ingredient.quantity,
          unit: ingredient.unit,
          recipe: recipe
        )
      end
    end
  end
end
