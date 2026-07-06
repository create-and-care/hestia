require "test_helper"

module Api
  module V1
    class VehiclesControllerTest < ActionDispatch::IntegrationTest
      setup { @token = ApiToken.create!(user: users(:one), name: "Test").plaintext_token }

      test "index scopes to the token's household" do
        get api_v1_vehicles_path, headers: auth_headers
        assert_response :success
        names = JSON.parse(@response.body).map { |vehicle| vehicle["name"] }
        assert_includes names, vehicles(:alpha_car).name
        assert_not_includes names, vehicles(:beta_car).name
      end

      test "show returns a household vehicle" do
        get api_v1_vehicle_path(vehicles(:alpha_car)), headers: auth_headers
        assert_response :success
        assert_equal vehicles(:alpha_car).name, JSON.parse(@response.body)["name"]
      end

      test "show does not leak another household's vehicle" do
        get api_v1_vehicle_path(vehicles(:beta_car)), headers: auth_headers
        assert_response :not_found
      end

      private
        def auth_headers = { "Authorization" => "Bearer #{@token}" }
    end
  end
end
