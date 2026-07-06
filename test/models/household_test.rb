require "test_helper"

class HouseholdTest < ActiveSupport::TestCase
  test "generates an invite code on create" do
    household = Household.create!(name: "Test")
    assert_match(/\A[A-Z2-9]{8}\z/, household.invite_code)
  end

  test "invite codes are unique across households" do
    a = Household.create!(name: "A")
    b = Household.create!(name: "B")
    assert_not_equal a.invite_code, b.invite_code
  end

  test "respects an explicitly provided invite code" do
    household = Household.create!(name: "Test", invite_code: "CUSTOM23")
    assert_equal "CUSTOM23", household.invite_code
  end

  test "requires a name" do
    household = Household.new
    assert_not household.valid?
    assert_includes household.errors[:name], "can't be blank"
  end

  test "regenerate_invite_code! changes the code" do
    household = Household.create!(name: "Test")
    old_code = household.invite_code
    household.regenerate_invite_code!
    assert_not_equal old_code, household.invite_code
  end

  test "defaults to UTC" do
    household = Household.create!(name: "Test")
    assert_equal "UTC", household.time_zone
  end

  test "rejects an unknown time zone" do
    household = Household.new(name: "Test", time_zone: "Not/AZone")
    assert_not household.valid?
    assert_includes household.errors[:time_zone], "is not included in the list"
  end

  test "in_time_zone switches Time.zone for the duration of the block, then reverts" do
    household = Household.create!(name: "Test", time_zone: "Paris")

    observed = nil
    household.in_time_zone { observed = Time.zone.name }

    assert_equal "Paris", observed
    assert_equal "UTC", Time.zone.name
  end
end
