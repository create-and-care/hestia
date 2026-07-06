require "test_helper"

module Api
  module V1
    class MealPlanEntriesControllerTest < ActionDispatch::IntegrationTest
      setup { @token = ApiToken.create!(user: users(:one), name: "Test").plaintext_token }

      test "index scopes to the token's household" do
        get api_v1_meal_plan_entries_path, headers: auth_headers
        assert_response :success
        ids = JSON.parse(@response.body).map { |entry| entry["id"] }
        assert_includes ids, meal_plan_entries(:alpha_dinner).id
        assert_not_includes ids, meal_plan_entries(:beta_lunch).id
      end

      test "create adds an entry with a free name" do
        assert_difference -> { households(:alpha).meal_plan_entries.count }, 1 do
          post api_v1_meal_plan_entries_path,
            params: { on_date: Date.current, meal_type: "lunch", free_name: "Salade" },
            headers: auth_headers
        end
        assert_response :created
      end

      private
        def auth_headers = { "Authorization" => "Bearer #{@token}" }
    end
  end
end
