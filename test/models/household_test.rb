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

  test "modules are enabled by default" do
    household = Household.create!(name: "Test")
    assert household.module_enabled?(:shopping)
    assert household.module_enabled?("shopping")
  end

  test "a module listed in disabled_modules is not enabled" do
    household = Household.create!(name: "Test", disabled_modules: [ "shopping" ])
    assert_not household.module_enabled?(:shopping)
    assert household.module_enabled?(:fridge)
  end

  test "rejects unknown module keys" do
    household = Household.new(name: "Test", disabled_modules: [ "not_a_module" ])
    assert_not household.valid?
    assert_includes household.errors[:disabled_modules].join, "not_a_module"
  end

  test "has no required meal types by default" do
    household = Household.create!(name: "Test")
    assert_empty household.required_meal_types
  end

  test "rejects unknown required meal types" do
    household = Household.new(name: "Test", required_meal_types: [ "brunch" ])
    assert_not household.valid?
    assert_includes household.errors[:required_meal_types].join, "brunch"
  end

  test "admin? is true for an admin member and false for a regular member or stranger" do
    household = Household.create!(name: "Test")
    admin = User.create!(name: "Admin", email_address: "admin_x@example.com", password: "secret123")
    member = User.create!(name: "Member", email_address: "member_x@example.com", password: "secret123")
    stranger = User.create!(name: "Stranger", email_address: "stranger_x@example.com", password: "secret123")
    household.memberships.create!(user: admin, role: :admin)
    household.memberships.create!(user: member, role: :member)

    assert household.admin?(admin)
    assert_not household.admin?(member)
    assert_not household.admin?(stranger)
  end

  test "only_admin? is true only for a sole admin" do
    household = Household.create!(name: "Test")
    admin = User.create!(name: "Admin", email_address: "admin_y@example.com", password: "secret123")
    household.memberships.create!(user: admin, role: :admin)
    assert household.only_admin?(admin)

    co_admin = User.create!(name: "Co-admin", email_address: "coadmin_y@example.com", password: "secret123")
    household.memberships.create!(user: co_admin, role: :admin)
    assert_not household.only_admin?(admin)
    assert_not household.only_admin?(co_admin)
  end
end
