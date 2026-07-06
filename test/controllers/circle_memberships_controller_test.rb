require "test_helper"

class CircleMembershipsControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as(users(:one)) }

  test "new requires authentication" do
    sign_out
    get new_circle_membership_path
    assert_redirected_to new_session_path
  end

  test "new renders the join form" do
    get new_circle_membership_path
    assert_response :success
  end

  # Joining is by invite code, across households (architecture deviation, Spec §5, point 1).
  test "create joins a circle by invite code" do
    assert_difference -> { circles(:other).members.count }, 1 do
      post circle_membership_path, params: { invite_code: circles(:other).invite_code }
    end
    assert_redirected_to circles(:other)
    membership = CircleMembership.find_by(circle: circles(:other), user: users(:one))
    assert_equal "member", membership.role
  end

  test "create is case-insensitive and trims whitespace" do
    assert_difference -> { circles(:other).members.count }, 1 do
      post circle_membership_path, params: { invite_code: " #{circles(:other).invite_code.downcase} " }
    end
  end

  test "create with an invalid invite code re-renders the form" do
    assert_no_difference -> { CircleMembership.count } do
      post circle_membership_path, params: { invite_code: "NOPE0000" }
    end
    assert_response :unprocessable_entity
  end

  test "create when already a member redirects without duplicating" do
    assert_no_difference -> { CircleMembership.count } do
      post circle_membership_path, params: { invite_code: circles(:family).invite_code }
    end
    assert_redirected_to circles(:family)
  end
end
