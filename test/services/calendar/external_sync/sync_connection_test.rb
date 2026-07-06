require "test_helper"

module Calendar
  module ExternalSync
    class SyncConnectionTest < ActiveSupport::TestCase
      test "refreshes an expired OAuth token before fetching, then imports the events" do
        connection = ExternalCalendarConnection.create!(
          user: users(:one), provider: "google", access_token: "old-at", refresh_token: "rt", expires_at: 1.hour.ago
        )
        stub_request(:post, "https://oauth2.googleapis.com/token").to_return(
          status: 200, headers: { "Content-Type" => "application/json" },
          body: { access_token: "new-at", expires_in: 3600 }.to_json
        )
        stub_request(:get, %r{\Ahttps://www\.googleapis\.com/calendar/v3/calendars/primary/events})
          .with(headers: { "Authorization" => "Bearer new-at" })
          .to_return(status: 200, headers: { "Content-Type" => "application/json" }, body: { items: [] }.to_json)

        SyncConnection.call(connection)

        assert_equal "new-at", connection.reload.access_token
        assert_not_nil connection.last_synced_at
      end

      test "does not refresh a still-valid OAuth token" do
        connection = ExternalCalendarConnection.create!(
          user: users(:one), provider: "google", access_token: "at", refresh_token: "rt", expires_at: 1.hour.from_now
        )
        stub_request(:get, %r{\Ahttps://www\.googleapis\.com/calendar/v3/calendars/primary/events})
          .with(headers: { "Authorization" => "Bearer at" })
          .to_return(status: 200, headers: { "Content-Type" => "application/json" }, body: { items: [] }.to_json)

        SyncConnection.call(connection)

        assert_not_requested :post, "https://oauth2.googleapis.com/token"
      end

      test "deactivates the connection and notifies the user when the token refresh fails" do
        connection = ExternalCalendarConnection.create!(
          user: users(:one), provider: "google", access_token: "old-at", refresh_token: "revoked", expires_at: 1.hour.ago
        )
        stub_request(:post, "https://oauth2.googleapis.com/token").to_return(status: 400, body: "{}")

        assert_difference -> { users(:one).notifications.where(kind: "external_calendar_sync_failed").count }, 1 do
          SyncConnection.call(connection)
        end

        assert_not connection.reload.active?
      end

      test "syncs a CalDAV connection without any token refresh" do
        connection = ExternalCalendarConnection.create!(
          user: users(:one), provider: "caldav", caldav_url: "https://caldav.example.com/cal/", username: "alice", access_token: "s3cret"
        )
        stub_request(:report, "https://caldav.example.com/cal/")
          .to_return(status: 207, headers: { "Content-Type" => "application/xml" }, body: "<multistatus xmlns=\"DAV:\"></multistatus>")

        SyncConnection.call(connection)

        assert_not_nil connection.reload.last_synced_at
      end
    end
  end
end
