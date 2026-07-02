require "test_helper"

module Recipes
  class RecipeParserTest < ActiveSupport::TestCase
    SAMPLE = <<~HTML
      <html><head>
      <script type="application/ld+json">
      {
        "@context": "https://schema.org",
        "@type": "Recipe",
        "name": "Tarte aux pommes",
        "recipeIngredient": ["3 pommes", "1 pâte brisée", "50 g de sucre"],
        "recipeInstructions": [
          {"@type": "HowToStep", "text": "Éplucher les pommes."},
          {"@type": "HowToStep", "text": "Enfourner 30 minutes."}
        ],
        "recipeYield": "6 parts",
        "prepTime": "PT20M",
        "cookTime": "PT30M"
      }
      </script>
      </head><body></body></html>
    HTML

    test "extracts recipe data from JSON-LD" do
      result = Recipes::RecipeParser.parse(SAMPLE)
      assert_equal "Tarte aux pommes", result.title
      assert_equal 3, result.ingredients.size
      assert_equal [ "Éplucher les pommes.", "Enfourner 30 minutes." ], result.steps
      assert_equal 6, result.servings
      assert_equal 20, result.prep_time_minutes
      assert_equal 30, result.cook_time_minutes
    end

    test "handles a @graph wrapper and string instructions" do
      html = <<~HTML
        <script type="application/ld+json">
        {"@context":"https://schema.org","@graph":[
          {"@type":"WebSite"},
          {"@type":"Recipe","name":"Omelette","recipeIngredient":["3 oeufs"],"recipeInstructions":"Battre.\\nCuire."}
        ]}
        </script>
      HTML
      result = Recipes::RecipeParser.parse(html)
      assert_equal "Omelette", result.title
      assert_equal [ "Battre.", "Cuire." ], result.steps
    end

    test "returns nil when there is no recipe" do
      assert_nil Recipes::RecipeParser.parse("<html><body>rien</body></html>")
    end
  end
end
