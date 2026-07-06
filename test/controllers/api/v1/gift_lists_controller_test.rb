require "test_helper"

module Api
  module V1
    class GiftListsControllerTest < ActionDispatch::IntegrationTest
      setup { @token = ApiToken.create!(user: users(:one), name: "Test").plaintext_token }

      test "index scopes to the token's household" do
        get api_v1_gift_lists_path, headers: auth_headers
        assert_response :success
        names = JSON.parse(@response.body).map { |list| list["name"] }
        assert_includes names, gift_lists(:alpha_wishlist).name
        assert_not_includes names, gift_lists(:beta_list).name
      end

      private
        def auth_headers = { "Authorization" => "Bearer #{@token}" }
    end
  end
end
