require "test_helper"

module Recipes
  module Catalog
    class AddToHouseholdTest < ActiveSupport::TestCase
      test "clones a catalog entry into the household's recipe book" do
        entry = recipe_catalog_entries(:carbonara)
        recipe = nil

        assert_difference -> { households(:alpha).recipes.count }, 1 do
          recipe = Recipes::Catalog::AddToHousehold.call(entry: entry, household: households(:alpha))
        end

        assert_equal entry.title, recipe.title
        assert_equal entry.ingredients.size, recipe.recipe_ingredients.count
        assert_equal entry.steps.size, recipe.recipe_steps.count
        assert_equal entry.steps, recipe.recipe_steps.order(:position).map(&:content)
        assert_nil recipe.source_url
      end
    end
  end
end
