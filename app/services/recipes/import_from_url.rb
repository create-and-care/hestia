module Recipes
  # Imports a recipe from an external URL (schema.org/Recipe). Returns the
  # created recipe, or nil if the page is unreachable or lacks usable microdata.
  class ImportFromUrl
    def self.call(household:, url:, html: nil) = new(household: household, url: url, html: html).call

    def initialize(household:, url:, html: nil)
      @household = household
      @url = url.to_s.strip
      @html = html
    end

    def call
      return if @url.blank?

      html = @html || PageFetcher.call(@url)
      return if html.blank?

      result = RecipeParser.parse(html)
      return if result.nil? || result.title.blank?

      build_recipe(result)
    end

    private
      def build_recipe(result)
        recipe = @household.recipes.new(
          title: result.title,
          servings: result.servings,
          prep_time_minutes: result.prep_time_minutes,
          cook_time_minutes: result.cook_time_minutes,
          source_url: @url
        )
        recipe.recipe_ingredients = result.ingredients.each_with_index.map do |name, index|
          RecipeIngredient.new(name: name, position: index)
        end
        recipe.recipe_steps = result.steps.each_with_index.map do |content, index|
          RecipeStep.new(content: content, position: index)
        end
        recipe.save!
        recipe
      end
  end
end
