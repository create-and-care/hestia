module Frigo
  # "What can I cook with what's on hand?" — a simple text-overlap match
  # between FridgeItem names and a recipe's ingredient lines, no NLP
  # interconnection with Recipes/Menu; smarter ingredient matching is a
  # Hest.AI Phase 3 capability).
  class SuggestRecipes
    def self.call(household:, limit: 5) = new(household: household, limit: limit).call

    def initialize(household:, limit:)
      @household = household
      @limit = limit
    end

    def call
      return [] if fridge_names.empty?

      scored = @household.recipes.includes(:recipe_ingredients).filter_map do |recipe|
        count = match_count(recipe)
        [ recipe, count ] if count.positive?
      end
      scored.sort_by { |_, count| -count }.first(@limit).map(&:first)
    end

    private
      def fridge_names
        @fridge_names ||= @household.fridge_items.pluck(:name).map { |name| name.downcase.strip }.reject(&:blank?)
      end

      def match_count(recipe)
        ingredient_lines = recipe.recipe_ingredients.map { |ingredient| ingredient.name.downcase }
        fridge_names.count { |name| ingredient_lines.any? { |line| line.include?(name) } }
      end
  end
end
