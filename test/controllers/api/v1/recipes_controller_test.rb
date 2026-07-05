require "test_helper"

module Api
  module V1
    class RecipesControllerTest < ActionDispatch::IntegrationTest
      setup { @token = ApiToken.create!(user: users(:one), name: "Test").plaintext_token }

      test "index scopes to the token's household" do
        get api_v1_recipes_path, headers: auth_headers
        assert_response :success
        titles = JSON.parse(@response.body).map { |recipe| recipe["title"] }
        assert_includes titles, recipes(:alpha_pancakes).title
        assert_not_includes titles, recipes(:beta_soup).title
      end

      test "show includes ingredients and steps, and 404s for another household" do
        get api_v1_recipe_path(recipes(:alpha_pancakes)), headers: auth_headers
        assert_response :success
        body = JSON.parse(@response.body)
        assert body.key?("ingredients")
        assert body.key?("steps")

        get api_v1_recipe_path(recipes(:beta_soup)), headers: auth_headers
        assert_response :not_found
      end

      private
        def auth_headers = { "Authorization" => "Bearer #{@token}" }
    end
  end
end
