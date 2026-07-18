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

      test "attaches the catalog entry's cached image when present" do
        entry = recipe_catalog_entries(:carbonara)
        entry.update!(image_url: "https://example.com/carbonara.jpg")
        stub_request(:get, "https://example.com/carbonara.jpg").to_return(status: 200, body: File.binread(Rails.root.join("test/fixtures/files/sample.png")))

        recipe = Recipes::Catalog::AddToHousehold.call(entry: entry, household: households(:alpha))

        assert recipe.photo.attached?
      end
    end
  end
end
