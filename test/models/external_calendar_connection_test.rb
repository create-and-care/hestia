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

  test "requires a caldav_url and username for CalDAV, but not for OAuth providers" do
    caldav = ExternalCalendarConnection.new(user: users(:one), provider: "caldav")
    assert_not caldav.valid?
    assert_includes caldav.errors[:caldav_url], "can't be blank"
    assert_includes caldav.errors[:username], "can't be blank"

    google = ExternalCalendarConnection.new(user: users(:one), provider: "google")
    assert google.valid?
  end

  test "encrypts access_token and refresh_token at rest" do
    connection = ExternalCalendarConnection.create!(user: users(:one), provider: "google", access_token: "at", refresh_token: "rt")

    raw = ExternalCalendarConnection.connection.select_value(
      "SELECT access_token FROM external_calendar_connections WHERE id = #{connection.id}"
    )

    assert_not_equal "at", raw
    assert_equal "at", connection.reload.access_token
  end

  test "oauth_provider? is true for google/microsoft and false for caldav" do
    assert ExternalCalendarConnection.new(provider: "google").oauth_provider?
    assert ExternalCalendarConnection.new(provider: "microsoft").oauth_provider?
    assert_not ExternalCalendarConnection.new(provider: "caldav").oauth_provider?
  end

  test "token_expired? compares expires_at to the current time" do
    connection = ExternalCalendarConnection.new(expires_at: 1.hour.ago)
    assert connection.token_expired?

    connection.expires_at = 1.hour.from_now
    assert_not connection.token_expired?

    connection.expires_at = nil
    assert_not connection.token_expired?
  end
end
