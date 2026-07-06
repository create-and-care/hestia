require "test_helper"

module Calendar
  module ExternalSync
    class OauthProviderTest < ActiveSupport::TestCase
      test "google authorize_url points at Google's consent screen with state and offline access" do
        provider = OauthProvider.new("google")
        url = provider.authorize_url(redirect_uri: "https://hestia.example.com/external_calendar_connections/google/callback", state: "xyz")

        uri = URI.parse(url)
        assert_equal "accounts.google.com", uri.host
        params = Rack::Utils.parse_query(uri.query)
        assert_equal "xyz", params["state"]
        assert_equal "offline", params["access_type"]
      end

      test "microsoft authorize_url points at Microsoft's consent screen" do
        provider = OauthProvider.new("microsoft")
        url = provider.authorize_url(redirect_uri: "https://hestia.example.com/external_calendar_connections/microsoft/callback", state: "xyz")

        assert_equal "login.microsoftonline.com", URI.parse(url).host
      end

      test "exchange_code returns normalized tokens" do
        stub_request(:post, "https://oauth2.googleapis.com/token").to_return(
          status: 200, headers: { "Content-Type" => "application/json" },
          body: { access_token: "at", refresh_token: "rt", expires_in: 3600 }.to_json
        )

        tokens = OauthProvider.new("google").exchange_code(code: "code", redirect_uri: "https://hestia.example.com/callback")

        assert_equal "at", tokens[:access_token]
        assert_equal "rt", tokens[:refresh_token]
        assert tokens[:expires_at] > Time.current
      end

      test "refresh exchanges a refresh_token for a new access token" do
        stub_request(:post, "https://oauth2.googleapis.com/token").to_return(
          status: 200, headers: { "Content-Type" => "application/json" },
          body: { access_token: "new-at", expires_in: 3600 }.to_json
        )

        tokens = OauthProvider.new("google").refresh(refresh_token: "old-rt")

        assert_equal "new-at", tokens[:access_token]
      end

      test "fetch_events normalizes a Google timed event and an all-day event" do
        stub_request(:get, %r{\Ahttps://www\.googleapis\.com/calendar/v3/calendars/primary/events}).to_return(
          status: 200, headers: { "Content-Type" => "application/json" },
          body: {
            items: [
              { id: "evt1", summary: "Standup", location: "Room A", start: { dateTime: "2026-08-01T10:00:00Z" }, end: { dateTime: "2026-08-01T10:30:00Z" } },
              { id: "evt2", summary: "Vacation", start: { date: "2026-08-10" }, end: { date: "2026-08-15" } }
            ]
          }.to_json
        )

        events = OauthProvider.new("google").fetch_events(access_token: "at", from: Time.current, to: 1.month.from_now)

        timed = events.find { |e| e[:uid] == "evt1" }
        all_day = events.find { |e| e[:uid] == "evt2" }
        assert_equal "Standup", timed[:title]
        assert_equal "Room A", timed[:location]
        assert_not timed[:all_day]
        assert all_day[:all_day]
      end

      test "fetch_events normalizes a Microsoft event" do
        stub_request(:get, %r{\Ahttps://graph\.microsoft\.com/v1\.0/me/calendarview}).to_return(
          status: 200, headers: { "Content-Type" => "application/json" },
          body: {
            value: [
              { id: "evt1", subject: "Sync", isAllDay: false, location: { displayName: "Office" },
                start: { dateTime: "2026-08-01T10:00:00" }, end: { dateTime: "2026-08-01T11:00:00" } }
            ]
          }.to_json
        )

        events = OauthProvider.new("microsoft").fetch_events(access_token: "at", from: Time.current, to: 1.month.from_now)

        assert_equal 1, events.size
        assert_equal "Sync", events.first[:title]
        assert_equal "Office", events.first[:location]
      end
    end
  end
end
