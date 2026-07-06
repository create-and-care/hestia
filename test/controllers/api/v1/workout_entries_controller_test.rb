require "test_helper"

module Api
  module V1
    class WorkoutEntriesControllerTest < ActionDispatch::IntegrationTest
      setup do
        @token = ApiToken.create!(user: users(:one), name: "Test").plaintext_token
        @own_entry = WorkoutEntry.create!(user: users(:one), done_on: Date.current, exercise: "Course")
        @other_entry = WorkoutEntry.create!(user: users(:two), done_on: Date.current, exercise: "Velo")
      end

      # Wellbeing data is scoped per user, not per household — proves entries
      # from another user (even in a different household) never leak here.
      test "index scopes to the token's user, not the household" do
        get api_v1_workout_entries_path, headers: auth_headers
        assert_response :success
        ids = JSON.parse(@response.body).map { |entry| entry["id"] }
        assert_includes ids, @own_entry.id
        assert_not_includes ids, @other_entry.id
      end

      test "create adds an entry for the token's user" do
        assert_difference -> { users(:one).workout_entries.count }, 1 do
          post api_v1_workout_entries_path,
            params: { done_on: Date.current.to_s, exercise: "Natation", duration_minutes: "30" }, headers: auth_headers
        end
        assert_response :created
      end

      private
        def auth_headers = { "Authorization" => "Bearer #{@token}" }
    end
  end
end
