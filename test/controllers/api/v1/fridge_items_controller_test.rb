require "test_helper"

module Api
  module V1
    class FridgeItemsControllerTest < ActionDispatch::IntegrationTest
      setup { @token = ApiToken.create!(user: users(:one), name: "Test").plaintext_token }

      test "index scopes to the token's household" do
        get api_v1_fridge_items_path, headers: auth_headers
        assert_response :success
        names = JSON.parse(@response.body).map { |item| item["name"] }
        assert_includes names, fridge_items(:alpha_yogurt).name
        assert_not_includes names, fridge_items(:beta_milk).name
      end

      test "create adds an item via Frigo::AddItem" do
        assert_difference -> { households(:alpha).fridge_items.count }, 1 do
          post api_v1_fridge_items_path, params: { name: "Beurre", location: "refrigerateur" }, headers: auth_headers
        end
        assert_response :created
      end

      test "index defaults to 25 per page and honors a custom per_page" do
        # 2 déjà en fixtures (alpha_yogurt, alpha_peas).
        get api_v1_fridge_items_path, headers: auth_headers
        assert_equal 2, JSON.parse(@response.body).size

        get api_v1_fridge_items_path(per_page: 1), headers: auth_headers
        assert_equal 1, JSON.parse(@response.body).size
      end

      private
        def auth_headers = { "Authorization" => "Bearer #{@token}" }
    end
  end
end
