module Calendar
  module ExternalSync
    # Syncs one ExternalCalendarConnection: refreshes an
    # expired OAuth token first if needed, fetches events over a rolling
    # window, and imports them. On an unrecoverable auth failure (e.g. a
    # revoked refresh token), deactivates the connection and notifies the
    # user rather than retrying forever.
    class SyncConnection
      WINDOW_BEHIND = 7.days
      WINDOW_AHEAD = 90.days

      def self.call(...) = new(...).call

      def initialize(connection)
        @connection = connection
      end

      def call
        refresh_token_if_needed!
        events = fetch_events
        Importer.call(@connection, events)
        @connection.update!(last_synced_at: Time.current)
      rescue OAuth2::Error, CaldavProvider::Error => e
        deactivate_with_notice(e)
      end

      private
        def refresh_token_if_needed!
          return unless @connection.oauth_provider? && @connection.token_expired?

          tokens = OauthProvider.new(@connection.provider).refresh(refresh_token: @connection.refresh_token)
          @connection.update!(
            access_token: tokens[:access_token],
            refresh_token: tokens[:refresh_token] || @connection.refresh_token,
            expires_at: tokens[:expires_at]
          )
        end

        def fetch_events
          from = Time.current - WINDOW_BEHIND
          to = Time.current + WINDOW_AHEAD

          if @connection.oauth_provider?
            OauthProvider.new(@connection.provider).fetch_events(access_token: @connection.access_token, from: from, to: to)
          else
            CaldavProvider.new(@connection.caldav_url, @connection.username, @connection.access_token).fetch_events(from: from, to: to)
          end
        end

        def deactivate_with_notice(error)
          @connection.update!(active: false)
          Notification.create!(
            user: @connection.user, household: @connection.user.households.first,
            kind: "external_calendar_sync_failed",
            title: I18n.t("reminders.external_calendar_sync_failed.title", provider: @connection.provider.capitalize),
            body: error.message
          )
        end
    end
  end
end
