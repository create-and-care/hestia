require "test_helper"

module Api
  module V1
    class BottlesControllerTest < ActionDispatch::IntegrationTest
      setup { @token = ApiToken.create!(user: users(:one), name: "Test").plaintext_token }

      test "index scopes to the token's household" do
        get api_v1_bottles_path, headers: auth_headers
        assert_response :success
        names = JSON.parse(@response.body).map { |bottle| bottle["name"] }
        assert_includes names, bottles(:alpha_bordeaux).name
        assert_not_includes names, bottles(:beta_bottle).name
      end

      test "create adds a bottle to the given wine cellar" do
        cellar = wine_cellars(:alpha_reds)
        assert_difference -> { households(:alpha).bottles.count }, 1 do
          post api_v1_wine_cellar_bottles_path(cellar),
            params: { name: "Sancerre", vintage: 2020, region: "Loire", wine_type: "blanc" },
            headers: auth_headers
        end
        assert_response :created
      end

      test "create cannot target another household's wine cellar" do
        post api_v1_wine_cellar_bottles_path(wine_cellars(:beta_cellar)),
          params: { name: "Intrus" }, headers: auth_headers
        assert_response :not_found
      end

      private
        def auth_headers = { "Authorization" => "Bearer #{@token}" }
    end
  end
end
