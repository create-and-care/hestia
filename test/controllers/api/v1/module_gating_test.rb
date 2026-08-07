require "test_helper"

module Api
  module V1
    # Before this, the JSON API was gated by nothing: a household could switch
    # Shopping off, watch it disappear from the web UI, and still read and
    # write every one of its lists through an API token. The gate is the same
    # CONTROLLER_MODULES map the web controllers use, so the two surfaces
    # cannot drift apart.
    class ModuleGatingTest < ActionDispatch::IntegrationTest
      setup { @token = ApiToken.create!(user: users(:one), name: "Test").plaintext_token }

      test "a disabled module is refused on read" do
        households(:alpha).update!(disabled_modules: [ "shopping" ])

        get api_v1_shopping_lists_path, headers: auth_headers

        assert_response :forbidden
        assert_equal "module_disabled", JSON.parse(@response.body)["error"]
      end

      test "a disabled module is refused on write, not merely hidden from reads" do
        households(:alpha).update!(disabled_modules: [ "tasks" ])

        assert_no_difference -> { households(:alpha).tasks.count } do
          post api_v1_tasks_path, params: { title: "Nouvelle tâche" }, headers: auth_headers
        end

        assert_response :forbidden
      end

      test "an enabled module is untouched" do
        get api_v1_tasks_path, headers: auth_headers

        assert_response :success
      end

      test "the gate reads the token's household, not a client-supplied one" do
        households(:beta).update!(disabled_modules: [ "tasks" ])

        get api_v1_tasks_path, headers: auth_headers

        assert_response :success, "another household's toggle must not close this one"
      end

      test "the finer Pool switch reaches the API too" do
        households(:alpha).update!(pool_enabled: false)

        get api_v1_plants_path, headers: auth_headers
        assert_response :success, "the garden shares the outdoor module but not the pool switch"
      end

      test "an unauthenticated call is still refused before the gate is consulted" do
        households(:alpha).update!(disabled_modules: [ "tasks" ])

        get api_v1_tasks_path

        assert_response :unauthorized
      end

      private
        def auth_headers = { "Authorization" => "Bearer #{@token}" }
    end
  end
end
