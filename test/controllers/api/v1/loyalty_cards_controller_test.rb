require "test_helper"

module Api
  module V1
    class LoyaltyCardsControllerTest < ActionDispatch::IntegrationTest
      setup { @token = ApiToken.create!(user: users(:one), name: "Test").plaintext_token }

      test "index scopes to the token's household" do
        get api_v1_loyalty_cards_path, headers: auth_headers
        assert_response :success
        names = JSON.parse(@response.body).map { |card| card["name"] }
        assert_includes names, loyalty_cards(:alpha_supermarket).name
        assert_not_includes names, loyalty_cards(:beta_card).name
      end

      private
        def auth_headers = { "Authorization" => "Bearer #{@token}" }
    end
  end
end
