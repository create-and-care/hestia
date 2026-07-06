require "test_helper"

class ExternalCalendarConnectionsControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as(users(:one)) }

  test "index requires authentication" do
    sign_out
    get external_calendar_connections_path
    assert_redirected_to new_session_path
  end

  test "index lists only the current user's connections" do
    ExternalCalendarConnection.create!(user: users(:one), provider: "google")
    get external_calendar_connections_path
    assert_response :success
    assert_includes @response.body, "Google"
  end

  test "connect rejects an unknown provider" do
    get connect_external_calendar_connections_path(provider: "unknown")
    assert_redirected_to external_calendar_connections_path
  end

  test "connect explains missing credentials rather than failing silently" do
    get connect_external_calendar_connections_path(provider: "google")
    assert_redirected_to external_calendar_connections_path
    follow_redirect!
    assert_match(/not configured/, @response.body)
  end

  test "destroy cannot reach another user's connection" do
    other = ExternalCalendarConnection.create!(user: users(:two), provider: "microsoft")

    delete external_calendar_connection_path(other)

    assert_response :not_found
    assert ExternalCalendarConnection.exists?(other.id)
  end

  test "destroy removes the current user's own connection" do
    mine = ExternalCalendarConnection.create!(user: users(:one), provider: "google")

    delete external_calendar_connection_path(mine)

    assert_redirected_to external_calendar_connections_path
    assert_not ExternalCalendarConnection.exists?(mine.id)
  end
end
