require "test_helper"

module Api
  module V1
    class TasksControllerTest < ActionDispatch::IntegrationTest
      setup { @token = ApiToken.create!(user: users(:one), name: "Test").plaintext_token }

      test "index scopes to the token's household" do
        get api_v1_tasks_path, headers: auth_headers
        assert_response :success
        titles = JSON.parse(@response.body).map { |task| task["title"] }
        assert_includes titles, tasks(:alpha_dishes).title
      end

      test "create uses Tasks::CreateTask" do
        assert_difference -> { households(:alpha).tasks.count }, 1 do
          post api_v1_tasks_path, params: { title: "Nouvelle tâche" }, headers: auth_headers
        end
        assert_response :created
      end

      test "toggle flips done and cannot reach another household's task" do
        task = tasks(:alpha_dishes)
        patch toggle_api_v1_task_path(task), headers: auth_headers
        assert_response :success
        assert task.reload.done

        patch toggle_api_v1_task_path(tasks(:beta_report)), headers: auth_headers
        assert_response :not_found
      end

      private
        def auth_headers = { "Authorization" => "Bearer #{@token}" }
    end
  end
end
