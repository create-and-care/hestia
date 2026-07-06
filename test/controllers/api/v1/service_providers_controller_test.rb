require "test_helper"

module Api
  module V1
    class ServiceProvidersControllerTest < ActionDispatch::IntegrationTest
      setup { @token = ApiToken.create!(user: users(:one), name: "Test").plaintext_token }

      test "index scopes to the token's household" do
        get api_v1_service_providers_path, headers: auth_headers
        assert_response :success
        names = JSON.parse(@response.body).map { |provider| provider["name"] }
        assert_includes names, service_providers(:alpha_plombier).name
        assert_not_includes names, service_providers(:beta_provider).name
      end

      private
        def auth_headers = { "Authorization" => "Bearer #{@token}" }
    end
  end
end
