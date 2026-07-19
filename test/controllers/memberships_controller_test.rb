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

  # --- Managing existing memberships (update role / leave / remove) ---

  test "an admin can promote a member to admin" do
    member = households(:alpha).memberships.create!(user: users(:two), role: :member)
    sign_in_as(users(:one)) # admin of :alpha

    patch household_member_path(households(:alpha), member), params: { role: "admin" }

    assert member.reload.admin?
  end

  test "an admin can demote another admin to member" do
    other_admin = User.create!(name: "Co-admin", email_address: "coadmin@example.com", password: "secret123")
    membership = households(:alpha).memberships.create!(user: other_admin, role: :admin)
    sign_in_as(users(:one))

    patch household_member_path(households(:alpha), membership), params: { role: "member" }

    assert membership.reload.member?
  end

  test "demoting the household's last admin is blocked" do
    sign_in_as(users(:one)) # sole admin of :alpha
    membership = households(:alpha).memberships.find_by!(user: users(:one))

    patch household_member_path(households(:alpha), membership), params: { role: "member" }

    assert membership.reload.admin?
  end

  test "a non-admin member cannot change roles" do
    households(:alpha).memberships.create!(user: users(:two), role: :member)
    other_member = User.create!(name: "Coloc", email_address: "coloc@example.com", password: "secret123")
    other_membership = households(:alpha).memberships.create!(user: other_member, role: :member)
    sign_in_as(users(:two))
    users(:two).sessions.last.update!(active_household: households(:alpha))

    patch household_member_path(households(:alpha), other_membership), params: { role: "admin" }

    assert_not other_membership.reload.admin?
  end

  test "a member can leave the household" do
    member = households(:alpha).memberships.create!(user: users(:two), role: :member)
    sign_in_as(users(:two))
    users(:two).sessions.last.update!(active_household: households(:alpha))

    assert_difference -> { Membership.count }, -1 do
      delete household_member_path(households(:alpha), member)
    end

    assert_redirected_to root_path
  end

  test "leaving redirects to onboarding when it was the user's only household" do
    other_member = User.create!(name: "Solo", email_address: "solo@example.com", password: "secret123")
    membership = households(:alpha).memberships.create!(user: other_member, role: :member)
    sign_in_as(other_member)

    delete household_member_path(households(:alpha), membership)

    assert_redirected_to onboarding_path
  end

  test "the last admin cannot leave" do
    sign_in_as(users(:one)) # sole admin of :alpha
    membership = households(:alpha).memberships.find_by!(user: users(:one))

    assert_no_difference -> { Membership.count } do
      delete household_member_path(households(:alpha), membership)
    end
  end

  test "an admin can remove another member" do
    member = households(:alpha).memberships.create!(user: users(:two), role: :member)
    sign_in_as(users(:one))

    assert_difference -> { Membership.count }, -1 do
      delete household_member_path(households(:alpha), member)
    end

    assert_redirected_to household_path(households(:alpha))
  end

  test "a non-admin member cannot remove another member" do
    other_member = User.create!(name: "Coloc", email_address: "coloc@example.com", password: "secret123")
    other_membership = households(:alpha).memberships.create!(user: other_member, role: :member)
    households(:alpha).memberships.create!(user: users(:two), role: :member)
    sign_in_as(users(:two))
    users(:two).sessions.last.update!(active_household: households(:alpha))

    assert_no_difference -> { Membership.count } do
      delete household_member_path(households(:alpha), other_membership)
    end
  end

  test "cannot manage a membership from another household" do
    sign_in_as(users(:one)) # not a member of :beta

    membership = households(:beta).memberships.find_by!(user: users(:two))
    delete household_member_path(households(:beta), membership)

    assert_response :not_found
  end
end
