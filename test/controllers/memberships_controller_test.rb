require "test_helper"

class MembershipsControllerTest < ActionDispatch::IntegrationTest
  test "new requires authentication" do
    get new_membership_path
    assert_redirected_to new_session_path
  end

  test "join with a valid code adds the user and switches household" do
    user = users(:one)
    sign_in_as(user)
    target = households(:beta)

    assert_difference -> { target.memberships.count }, 1 do
      post membership_path, params: { invite_code: target.invite_code.downcase }
    end

    assert_redirected_to root_path
    assert_includes user.households.reload, target
    assert_equal target.id, user.sessions.last.reload.active_household_id
  end

  test "join with an invalid code re-renders" do
    sign_in_as(users(:one))

    assert_no_difference -> { Membership.count } do
      post membership_path, params: { invite_code: "NOPENOPE" }
    end

    assert_response :unprocessable_entity
  end

  test "joining a household the user is already in does not duplicate the membership" do
    user = users(:one)
    sign_in_as(user)
    own = households(:alpha)

    assert_no_difference -> { Membership.count } do
      post membership_path, params: { invite_code: own.invite_code }
    end

    assert_redirected_to root_path
  end
end
