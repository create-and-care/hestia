require "test_helper"

module Api
  module V1
    class GiftIdeasControllerTest < ActionDispatch::IntegrationTest
      setup { @token = ApiToken.create!(user: users(:one), name: "Test").plaintext_token }

      test "create adds a gift idea to the household's gift list" do
        assert_difference -> { gift_lists(:alpha_wishlist).gift_ideas.count }, 1 do
          post api_v1_gift_list_gift_ideas_path(gift_lists(:alpha_wishlist)),
            params: { name: "Casque audio", price: "99", status: "wanted" }, headers: auth_headers
        end
        assert_response :created
      end

      test "create returns 404 for another household's gift list" do
        post api_v1_gift_list_gift_ideas_path(gift_lists(:beta_list)),
          params: { name: "Hack", status: "wanted" }, headers: auth_headers
        assert_response :not_found
      end

      private
        def auth_headers = { "Authorization" => "Bearer #{@token}" }
    end
  end
end
