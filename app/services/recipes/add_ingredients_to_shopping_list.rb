module Recipes
  # Exporte les ingrédients d'une recette vers une liste de courses. En Phase 2, sans
  # fusion des doublons ni conversion d'unités (capacité Hest.IA, Phase 3 — CDC §9.5).
  class AddIngredientsToShoppingList
    def self.call(recipe:, shopping_list:)
      recipe.recipe_ingredients.map do |ingredient|
        Courses::AddItem.call(
          shopping_list: shopping_list,
          name: ingredient.name,
          quantity: ingredient.quantity,
          unit: ingredient.unit
        )
      end
    end
  end
end
