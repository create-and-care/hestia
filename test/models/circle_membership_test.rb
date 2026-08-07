require "test_helper"

class CircleMembershipTest < ActiveSupport::TestCase
  test "requires a role from the allowed list" do
    membership = CircleMembership.new(circle: circles(:family), user: users(:one), role: "owner")
    assert_not membership.valid?
    assert_includes membership.errors[:role], error_message(:inclusion)
  end

  test "accepts each allowed role" do
    CircleMembership::ROLES.each do |role|
      membership = CircleMembership.new(circle: circles(:other), user: users(:one), role: role)
      assert membership.valid?, "expected #{role} to be valid, got #{membership.errors.full_messages}"
    end
  end

  test "belongs to a circle and a user" do
    membership = CircleMembership.new(role: "member")
    assert_not membership.valid?
    assert_includes membership.errors[:circle], error_message(:required)
    assert_includes membership.errors[:user], error_message(:required)
  end

  test "a user cannot join the same circle twice" do
    duplicate = CircleMembership.new(circle: circles(:family), user: users(:one), role: "member")
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:user_id], error_message(:taken)
  end

  test "the same user can belong to different circles" do
    membership = CircleMembership.new(circle: circles(:other), user: users(:one), role: "member")
    assert membership.valid?
  end
end
