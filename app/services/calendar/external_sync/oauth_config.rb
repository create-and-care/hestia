module Calendar
  module ExternalSync
    # Per-provider OAuth2 endpoints and the host-configured application
    # credentials. A host must register their own OAuth
    # application with each provider (redirect URI:
    # https://<host>/external_calendar_connections/<provider>/callback) — this
    # cannot ship with the repository, the same reasoning already documented on
    # ExternalCalendarConnection before this sync was implemented. Configure via
    # either `GOOGLE_CLIENT_ID`/`GOOGLE_CLIENT_SECRET` (`MICROSOFT_...`) env vars
    # (convenient for a self-hosted Docker deployment) or `bin/rails credentials:edit`
    # -> google/microsoft: client_id/client_secret — env vars take precedence.
    module OauthConfig
      ENDPOINTS = {
        "google" => {
          authorize_url: "https://accounts.google.com/o/oauth2/v2/auth",
          token_url: "https://oauth2.googleapis.com/token",
          scope: "https://www.googleapis.com/auth/calendar.readonly",
          events_url: "https://www.googleapis.com/calendar/v3/calendars/primary/events"
        },
        "microsoft" => {
          authorize_url: "https://login.microsoftonline.com/common/oauth2/v2.0/authorize",
          token_url: "https://login.microsoftonline.com/common/oauth2/v2.0/token",
          scope: "offline_access Calendars.Read",
          events_url: "https://graph.microsoft.com/v1.0/me/calendarview"
        }
      }.freeze

      def self.credentials(provider)
        {
          client_id: ENV["#{provider.upcase}_CLIENT_ID"].presence || Rails.application.credentials.dig(provider.to_sym, :client_id),
          client_secret: ENV["#{provider.upcase}_CLIENT_SECRET"].presence || Rails.application.credentials.dig(provider.to_sym, :client_secret)
        }
      end

      def self.configured?(provider)
        credentials(provider)[:client_id].present?
      end
    end
  end
end
