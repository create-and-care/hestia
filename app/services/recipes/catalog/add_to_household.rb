module Recipes
  module Catalog
    # Clones a read-only RecipeCatalogEntry into the household's own editable
    # recipe book — mirrors Recipes::ImportFromUrl#build_recipe.
    # The catalog entry's source_url is intentionally not copied onto the
    # cloned Recipe: that field is reserved for the existing user-driven
    # "import from a URL you provide" flow.
    class AddToHousehold
      def self.call(entry:, household:) = new(entry: entry, household: household).call

      def initialize(entry:, household:)
        @entry = entry
        @household = household
      end

      def call
        recipe = @household.recipes.new(
          title: @entry.title,
          tags: @entry.tags,
          servings: @entry.servings,
          prep_time_minutes: @entry.prep_time_minutes,
          cook_time_minutes: @entry.cook_time_minutes,
          recipe_catalog_entry: @entry
        )
        recipe.recipe_ingredients = @entry.ingredients.each_with_index.map do |name, index|
          RecipeIngredient.new(name: name, position: index)
        end
        recipe.recipe_steps = @entry.steps.each_with_index.map do |content, index|
          RecipeStep.new(content: content, position: index)
        end
        recipe.save!
        Recipes::AttachPhotoFromUrl.call(recipe: recipe, image_url: @entry.image_url)
        recipe
      end
    end
  end
end
