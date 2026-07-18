require "test_helper"

module Recipes
  class ImportFromUrlTest < ActiveSupport::TestCase
    HTML = <<~HTML
      <script type="application/ld+json">
      {"@context":"https://schema.org","@type":"Recipe","name":"Tarte",
       "recipeIngredient":["3 pommes","1 pâte"],
       "recipeInstructions":[{"@type":"HowToStep","text":"Cuire."}],
       "prepTime":"PT15M"}
      </script>
    HTML

    test "builds a recipe from the provided html" do
      recipe = nil
      assert_difference -> { households(:alpha).recipes.count }, 1 do
        recipe = Recipes::ImportFromUrl.call(household: households(:alpha),
          url: "https://example.com/tarte", html: HTML)
      end

      assert_equal "Tarte", recipe.title
      assert_equal 2, recipe.recipe_ingredients.count
      assert_equal 1, recipe.recipe_steps.count
      assert_equal "https://example.com/tarte", recipe.source_url
      assert_equal 15, recipe.prep_time_minutes
    end

    test "attaches the recipe's image when present" do
      html = <<~HTML
        <script type="application/ld+json">
        {"@context":"https://schema.org","@type":"Recipe","name":"Tarte",
         "recipeIngredient":["3 pommes"],
         "recipeInstructions":[{"@type":"HowToStep","text":"Cuire."}],
         "image":"https://example.com/tarte.jpg"}
        </script>
      HTML
      stub_request(:get, "https://example.com/tarte.jpg").to_return(status: 200, body: File.binread(Rails.root.join("test/fixtures/files/sample.png")))

      recipe = Recipes::ImportFromUrl.call(household: households(:alpha), url: "https://example.com/tarte", html: html)

      assert recipe.photo.attached?
    end

    test "returns nil for a blank url" do
      assert_nil Recipes::ImportFromUrl.call(household: households(:alpha), url: "", html: "<html></html>")
    end

    test "returns nil when the page has no recipe microdata" do
      assert_nil Recipes::ImportFromUrl.call(household: households(:alpha),
        url: "https://example.com/x", html: "<html>rien</html>")
    end
  end
end
