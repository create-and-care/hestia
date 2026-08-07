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
    assert_body_includes I18n.t("external_calendar_connections.connect.not_configured", provider: "Google")
  end

  test "connect redirects to the provider's real authorize URL once configured" do
    with_google_credentials do
      get connect_external_calendar_connections_path(provider: "google")
    end

    assert_response :redirect
    location = URI.parse(@response.location)
    assert_equal "accounts.google.com", location.host
    params = Rack::Utils.parse_query(location.query)
    assert_equal "abc", params["client_id"]
    assert_not_nil session[:external_calendar_oauth_state]
    assert_equal session[:external_calendar_oauth_state], params["state"]
  end

  test "connect renders a manual entry form for CalDAV" do
    get connect_external_calendar_connections_path(provider: "caldav")

    assert_response :success
    assert_includes @response.body, "CalDAV"
  end

  test "callback rejects a missing or mismatched state" do
    get callback_external_calendar_connections_path(provider: "google", code: "x", state: "wrong")

    assert_redirected_to external_calendar_connections_path
    follow_redirect!
    assert_body_includes I18n.t("external_calendar_connections.callback.state_mismatch")
  end

  test "callback exchanges the code, creates a connection, and triggers a first sync" do
    stub_request(:post, "https://oauth2.googleapis.com/token").to_return(
      status: 200, headers: { "Content-Type" => "application/json" },
      body: { access_token: "at", refresh_token: "rt", expires_in: 3600 }.to_json
    )
    stub_request(:get, %r{\Ahttps://www\.googleapis\.com/calendar/v3/calendars/primary/events})
      .to_return(status: 200, headers: { "Content-Type" => "application/json" }, body: { items: [] }.to_json)

    with_google_credentials { get connect_external_calendar_connections_path(provider: "google") }
    state = session[:external_calendar_oauth_state]

    assert_difference -> { users(:one).external_calendar_connections.count }, 1 do
      with_google_credentials { get callback_external_calendar_connections_path(provider: "google", code: "auth-code", state: state) }
    end

    assert_redirected_to external_calendar_connections_path
    connection = users(:one).external_calendar_connections.last
    assert_equal "at", connection.access_token
    assert_not_nil connection.last_synced_at
  end

  test "create adds a CalDAV connection and triggers a first sync" do
    stub_request(:report, "https://caldav.example.com/cal/").to_return(
      status: 207, headers: { "Content-Type" => "application/xml" }, body: "<multistatus xmlns=\"DAV:\"></multistatus>"
    )

    assert_difference -> { users(:one).external_calendar_connections.count }, 1 do
      post external_calendar_connections_path, params: {
        external_calendar_connection: { caldav_url: "https://caldav.example.com/cal/", username: "alice", password: "s3cret" }
      }
    end

    assert_redirected_to external_calendar_connections_path
    connection = users(:one).external_calendar_connections.last
    assert_equal "caldav", connection.provider
    assert_equal "s3cret", connection.access_token
    assert_not_nil connection.last_synced_at
  end

  test "create rejects an incomplete CalDAV form" do
    assert_no_difference -> { users(:one).external_calendar_connections.count } do
      post external_calendar_connections_path, params: { external_calendar_connection: { caldav_url: "" } }
    end

    assert_redirected_to external_calendar_connections_path
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

  private
    def with_google_credentials
      ENV["GOOGLE_CLIENT_ID"] = "abc"
      ENV["GOOGLE_CLIENT_SECRET"] = "secret"
      yield
    ensure
      ENV.delete("GOOGLE_CLIENT_ID")
      ENV.delete("GOOGLE_CLIENT_SECRET")
    end
end
