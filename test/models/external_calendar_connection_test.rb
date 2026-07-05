require "test_helper"

class ExternalCalendarConnectionTest < ActiveSupport::TestCase
  test "requires a known provider" do
    connection = ExternalCalendarConnection.new(user: users(:one), provider: "unknown")
    assert_not connection.valid?
  end

  test "is active by default" do
    connection = ExternalCalendarConnection.create!(user: users(:one), provider: "google")
    assert connection.active?
    assert connection.google?
    assert_not connection.microsoft?
  end
end
