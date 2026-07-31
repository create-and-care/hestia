require "test_helper"

module Api
  module V1
    class ShoppingListsControllerTest < ActionDispatch::IntegrationTest
      setup do
        @token = ApiToken.create!(user: users(:one), name: "Test").plaintext_token
      end

      test "index requires a valid bearer token" do
        get api_v1_shopping_lists_path
        assert_response :unauthorized
      end

      test "index rejects an invalid token" do
        get api_v1_shopping_lists_path, headers: { "Authorization" => "Bearer wrong" }
        assert_response :unauthorized
      end

      test "index returns the household's shopping lists" do
        get api_v1_shopping_lists_path, headers: auth_headers
        assert_response :success
        names = JSON.parse(@response.body).map { |list| list["name"] }
        assert_includes names, shopping_lists(:alpha_groceries).name
      end

      test "show includes items and scopes to the token's household" do
        list = shopping_lists(:alpha_groceries)
        get api_v1_shopping_list_path(list), headers: auth_headers
        assert_response :success
        assert JSON.parse(@response.body).key?("items")
      end

      test "show returns 404 for another household's list" do
        get api_v1_shopping_list_path(shopping_lists(:beta_groceries)), headers: auth_headers
        assert_response :not_found
      end

      test "create item uses the Courses::AddItem service and broadcasts as usual" do
        list = shopping_lists(:alpha_groceries)
        assert_difference -> { list.items.count }, 1 do
          post api_v1_shopping_list_items_path(list), params: { name: "Lait" }, headers: auth_headers
        end
        assert_response :created
      end

      test "toggle flips the checked state" do
        item = shopping_list_items(:alpha_apples)
        patch toggle_api_v1_shopping_list_item_path(item.shopping_list, item), headers: auth_headers
        assert_response :success
        assert item.reload.checked
      end

      test "destroy removes the item" do
        item = shopping_list_items(:alpha_apples)
        assert_difference -> { item.shopping_list.items.count }, -1 do
          delete api_v1_shopping_list_item_path(item.shopping_list, item), headers: auth_headers
        end
        assert_response :no_content
      end

      test "destroy returns 404 for another household's list" do
        item = shopping_list_items(:alpha_apples)
        delete api_v1_shopping_list_item_path(shopping_lists(:beta_groceries), item), headers: auth_headers
        assert_response :not_found
      end

      test "rejects a token belonging to a user with no household" do
        homeless = User.create!(name: "Sans foyer", email_address: "homeless@example.com", password: "password")
        token = ApiToken.create!(user: homeless, name: "Test").plaintext_token

        get api_v1_shopping_lists_path, headers: { "Authorization" => "Bearer #{token}" }
        assert_response :unprocessable_entity
      end

      private
        def auth_headers = { "Authorization" => "Bearer #{@token}" }
    end
  end
end
