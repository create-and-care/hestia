require "test_helper"

module Api
  module V1
    class TripsControllerTest < ActionDispatch::IntegrationTest
      setup { @token = ApiToken.create!(user: users(:one), name: "Test").plaintext_token }

      test "index scopes to the token's household" do
        get api_v1_trips_path, headers: auth_headers
        assert_response :success
        names = JSON.parse(@response.body).map { |trip| trip["name"] }
        assert_includes names, trips(:alpha_trip).name
        assert_not_includes names, trips(:beta_trip).name
      end

      test "show returns the trip and 404s for another household's trip" do
        get api_v1_trip_path(trips(:alpha_trip)), headers: auth_headers
        assert_response :success

        get api_v1_trip_path(trips(:beta_trip)), headers: auth_headers
        assert_response :not_found
      end

      private
        def auth_headers = { "Authorization" => "Bearer #{@token}" }
    end
  end
end
