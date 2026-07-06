require "test_helper"

module Api
  module V1
    class PlantsControllerTest < ActionDispatch::IntegrationTest
      setup { @token = ApiToken.create!(user: users(:one), name: "Test").plaintext_token }

      test "index scopes to the token's household" do
        get api_v1_plants_path, headers: auth_headers
        assert_response :success
        names = JSON.parse(@response.body).map { |plant| plant["name"] }
        assert_includes names, plants(:alpha_rose).name
        assert_not_includes names, plants(:beta_plant).name
      end

      private
        def auth_headers = { "Authorization" => "Bearer #{@token}" }
    end
  end
end
