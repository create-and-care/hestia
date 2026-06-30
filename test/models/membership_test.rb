require "test_helper"

class MembershipTest < ActiveSupport::TestCase
  test "a user cannot join the same household twice" do
    existing = memberships(:one_alpha)
    duplicate = Membership.new(user: existing.user, household: existing.household)
    assert_not duplicate.valid?
  end

  test "defaults to the member role" do
    household = Household.create!(name: "Test")
    membership = household.memberships.create!(user: users(:one))
    assert_predicate membership, :member?
    assert_not membership.admin?
  end

  test "rejects an unknown role" do
    membership = Membership.new(user: users(:one), household: households(:beta), role: "owner")
    assert_not membership.valid?
  end
end
