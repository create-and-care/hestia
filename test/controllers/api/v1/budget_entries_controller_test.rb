require "test_helper"

module Api
  module V1
    class BudgetEntriesControllerTest < ActionDispatch::IntegrationTest
      setup { @token = ApiToken.create!(user: users(:one), name: "Test").plaintext_token }

      test "index scopes to the token's household" do
        beta_entry = BudgetEntry.create!(budget_category: budget_categories(:beta_cat), name: "Charge Beta", amount: 50, periodicity: "monthly")

        get api_v1_budget_entries_path, headers: auth_headers
        assert_response :success
        names = JSON.parse(@response.body).map { |entry| entry["name"] }
        assert_includes names, budget_entries(:salary_entry).name
        assert_not_includes names, beta_entry.name
      end

      test "create adds an entry to the given budget category" do
        assert_difference -> { budget_categories(:alpha_rent).budget_entries.count }, 1 do
          post api_v1_budget_entries_path,
            params: { budget_category_id: budget_categories(:alpha_rent).id, name: "Internet", amount: "40", periodicity: "monthly" },
            headers: auth_headers
        end
        assert_response :created
      end

      test "create rejects a budget category belonging to another household" do
        post api_v1_budget_entries_path,
          params: { budget_category_id: budget_categories(:beta_cat).id, name: "Hack", amount: "1", periodicity: "monthly" },
          headers: auth_headers
        assert_response :not_found
      end

      private
        def auth_headers = { "Authorization" => "Bearer #{@token}" }
    end
  end
end
