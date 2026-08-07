require "test_helper"

class SessionTest < ActiveSupport::TestCase
  test "belongs to a user" do
    session = Session.new
    assert_not session.valid?
    assert_includes session.errors[:user], error_message(:required)
  end

  test "active_household is optional" do
    session = users(:one).sessions.build
    assert session.valid?
    assert_nil session.active_household
  end

  test "can track the household most recently switched to" do
    session = users(:one).sessions.create!(active_household: households(:alpha))
    assert_equal households(:alpha), session.active_household
  end

  test "destroying a user destroys its sessions" do
    user = User.create!(name: "Temp", email_address: "temp@example.com", password: "password")
    user.sessions.create!

    assert_difference -> { Session.count }, -1 do
      user.destroy
    end
  end
end
