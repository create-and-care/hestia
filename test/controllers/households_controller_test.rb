require "test_helper"

class HouseholdsControllerTest < ActionDispatch::IntegrationTest
  test "new requires authentication" do
    get new_household_path
    assert_redirected_to new_session_path
  end

  test "create makes the creator an admin and sets the active household" do
    user = users(:one)
    sign_in_as(user)

    assert_difference -> { Household.count }, 1 do
      post households_path, params: { household: { name: "Nouveau Foyer" } }
    end

    household = Household.find_by!(name: "Nouveau Foyer")
    assert household.memberships.exists?(user: user, role: "admin")
    assert_redirected_to root_path
    assert_equal household.id, user.sessions.last.reload.active_household_id
  end

  test "create provisions a default shopping list so the household isn't empty" do
    sign_in_as(users(:one))
    post households_path, params: { household: { name: "Nouveau Foyer" } }

    household = Household.find_by!(name: "Nouveau Foyer")
    assert_equal 1, household.shopping_lists.count
  end

  test "create with a blank name re-renders" do
    sign_in_as(users(:one))

    assert_no_difference -> { Household.count } do
      post households_path, params: { household: { name: "" } }
    end

    assert_response :unprocessable_entity
  end

  test "activate switches the active household" do
    user = users(:one)
    sign_in_as(user)
    other = Household.create!(name: "Second")
    other.memberships.create!(user: user, role: :member)

    patch activate_household_path(other)

    assert_redirected_to root_path
    assert_equal other.id, user.sessions.last.reload.active_household_id
  end

  test "activate refuses a household the user does not belong to" do
    sign_in_as(users(:one))

    patch activate_household_path(households(:beta))

    assert_redirected_to root_path
    assert_nil users(:one).sessions.last.reload.active_household_id
  end

  test "show renders the household, notification preferences, API tokens, and roadmap sections" do
    sign_in_as(users(:one))
    ApiToken.create!(user: users(:one), name: "iPhone")

    get household_path(households(:alpha))

    assert_response :success
    assert_select "h1", text: households(:alpha).name
    assert_select "code", text: households(:alpha).invite_code
    assert_includes @response.body, "iPhone"
    assert_includes @response.body, "Progress by area"
  end

  test "update sets the household's time zone" do
    sign_in_as(users(:one))

    patch household_path(households(:alpha)), params: { household: { time_zone: "Paris" } }

    assert_redirected_to household_path(households(:alpha))
    assert_equal "Paris", households(:alpha).reload.time_zone
  end

  test "update rejects an unknown time zone" do
    sign_in_as(users(:one))

    patch household_path(households(:alpha)), params: { household: { time_zone: "Not/AZone" } }

    assert_redirected_to household_path(households(:alpha))
    assert_equal "UTC", households(:alpha).reload.time_zone
  end

  test "update_modules lets an admin disable a module" do
    sign_in_as(users(:one)) # admin of :alpha

    patch update_modules_household_path(households(:alpha)), params: {
      household: { enabled_modules: Household::MODULE_KEYS - [ "shopping" ] }
    }

    assert_redirected_to household_path(households(:alpha))
    assert_equal [ "shopping" ], households(:alpha).reload.disabled_modules
  end

  test "update sets the household's required meal types" do
    sign_in_as(users(:one))

    # The settings form always submits a trailing "" alongside the checked
    # boxes (a hidden fallback field so unchecking everything still sends an
    # array instead of omitting the param).
    patch household_path(households(:alpha)), params: { household: { required_meal_types: [ "lunch", "dinner", "" ] } }

    assert_redirected_to household_path(households(:alpha))
    assert_equal %w[lunch dinner], households(:alpha).reload.required_meal_types
  end

  test "update clears required meal types when every box is unchecked" do
    sign_in_as(users(:one))
    households(:alpha).update!(required_meal_types: %w[lunch dinner])

    patch household_path(households(:alpha)), params: { household: { required_meal_types: [ "" ] } }

    assert_redirected_to household_path(households(:alpha))
    assert_empty households(:alpha).reload.required_meal_types
  end

  test "update_modules refuses a non-admin member" do
    sign_in_as(users(:two)) # admin of :beta, not a member of :alpha
    households(:alpha).memberships.create!(user: users(:two), role: :member)
    users(:two).sessions.last.update!(active_household: households(:alpha))

    patch update_modules_household_path(households(:alpha)), params: {
      household: { enabled_modules: Household::MODULE_KEYS - [ "shopping" ] }
    }

    assert_redirected_to household_path(households(:alpha))
    assert_empty households(:alpha).reload.disabled_modules
  end

  test "switch_time_zone does not leak Time.zone into the next request" do
    households(:alpha).update!(time_zone: "Paris")
    sign_in_as(users(:one))

    get household_path(households(:alpha))

    assert_response :success
    assert_equal "UTC", Time.zone.name
  end
end
