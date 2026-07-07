require "test_helper"

class ModuleGatingTest < ActionDispatch::IntegrationTest
  test "a disabled module redirects away from its controller" do
    households(:alpha).update!(disabled_modules: [ "shopping" ])
    sign_in_as(users(:one))

    get shopping_lists_path

    assert_redirected_to root_path
    follow_redirect!
    assert_match I18n.t("modules.disabled_alert"), @response.body
  end

  test "a disabled module redirects away from a nested controller under the same module" do
    households(:alpha).update!(disabled_modules: [ "trips" ])
    sign_in_as(users(:one))
    trip = households(:alpha).trips.create!(name: "Ski")

    assert_no_difference -> { trip.tasks.count } do
      post trip_tasks_path(trip), params: { task: { title: "Pack skis" } }
    end

    assert_redirected_to root_path
  end

  test "an enabled module is reachable as usual" do
    sign_in_as(users(:one))

    get shopping_lists_path

    assert_response :success
  end

  test "the household settings page is never gated, even if every module is disabled" do
    households(:alpha).update!(disabled_modules: Household::MODULE_KEYS)
    sign_in_as(users(:one))

    get household_path(households(:alpha))

    assert_response :success
  end
end
