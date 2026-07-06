require "test_helper"

module Api
  module V1
    class AddressesControllerTest < ActionDispatch::IntegrationTest
      setup { @token = ApiToken.create!(user: users(:one), name: "Test").plaintext_token }

      test "index scopes to the token's household" do
        get api_v1_addresses_path, headers: auth_headers
        assert_response :success
        names = JSON.parse(@response.body).map { |address| address["name"] }
        assert_includes names, addresses(:alpha_resto).name
        assert_includes names, addresses(:alpha_park).name
        assert_not_includes names, addresses(:beta_place).name
      end

      private
        def auth_headers = { "Authorization" => "Bearer #{@token}" }
    end
  end
end
