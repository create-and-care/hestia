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
end
