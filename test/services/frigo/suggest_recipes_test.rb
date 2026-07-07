require "test_helper"

module Frigo
  class SuggestRecipesTest < ActiveSupport::TestCase
    test "ranks recipes by how many fridge items match their ingredients" do
      household = households(:alpha)
      household.fridge_items.create!(name: "Farine", location: "garde_manger")
      household.fridge_items.create!(name: "Lait", location: "refrigerateur")

      assert_includes Frigo::SuggestRecipes.call(household: household), recipes(:alpha_pancakes)
    end

    test "excludes recipes with no matching ingredients" do
      household = households(:alpha)
      household.fridge_items.create!(name: "Ananas", location: "garde_manger")

      assert_not_includes Frigo::SuggestRecipes.call(household: household), recipes(:alpha_pancakes)
    end

    test "returns an empty array when the fridge is empty" do
      household = households(:alpha)
      household.fridge_items.destroy_all
      assert_equal [], Frigo::SuggestRecipes.call(household: household)
    end
  end
end
