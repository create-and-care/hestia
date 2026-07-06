require "test_helper"

module Api
  module V1
    class RoutinesControllerTest < ActionDispatch::IntegrationTest
      setup { @token = ApiToken.create!(user: users(:one), name: "Test").plaintext_token }

      test "index scopes to the token's household" do
        get api_v1_routines_path, headers: auth_headers
        assert_response :success
        names = JSON.parse(@response.body).map { |routine| routine["name"] }
        assert_includes names, routines(:alpha_vacuum).name
        assert_not_includes names, routines(:beta_routine).name
      end

      test "complete logs a completion and cannot reach another household's routine" do
        routine = routines(:alpha_vacuum)
        assert_difference -> { routine.routine_completions.count }, 1 do
          post complete_api_v1_routine_path(routine), headers: auth_headers
        end
        assert_response :success

        post complete_api_v1_routine_path(routines(:beta_routine)), headers: auth_headers
        assert_response :not_found
      end

      private
        def auth_headers = { "Authorization" => "Bearer #{@token}" }
    end
  end
end
