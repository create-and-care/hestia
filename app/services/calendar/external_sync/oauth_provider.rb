module Calendar
  module ExternalSync
    # Google and Microsoft are both standard OAuth2 authorization-code flows
    # returning JSON REST events (Spec §9.2, §16) — one class handles both,
    # differing only in endpoint URLs and response shape.
    class OauthProvider
      def initialize(provider)
        @provider = provider
        @endpoint = OauthConfig::ENDPOINTS.fetch(provider)
      end

      def authorize_url(redirect_uri:, state:)
        extra = @provider == "google" ? { access_type: "offline", prompt: "consent" } : {}
        client(redirect_uri).auth_code.authorize_url(
          redirect_uri: redirect_uri, scope: @endpoint[:scope], state: state, **extra
        )
      end

      def exchange_code(code:, redirect_uri:)
        token = client(redirect_uri).auth_code.get_token(code, redirect_uri: redirect_uri)
        normalize_token(token)
      end

      def refresh(refresh_token:)
        token = OAuth2::AccessToken.new(client(nil), nil, refresh_token: refresh_token)
        normalize_token(token.refresh!)
      end

      # Normalized event hashes (Spec §9.2, §16): uid/title/starts_at/ends_at/all_day/location.
      def fetch_events(access_token:, from:, to:)
        response = access_token_for(access_token).get(@endpoint[:events_url], params: query_params(from, to))
        items(JSON.parse(response.body)).map { |item| normalize_event(item) }
      end

      private
        def client(redirect_uri)
          creds = OauthConfig.credentials(@provider)
          OAuth2::Client.new(
            creds[:client_id], creds[:client_secret],
            authorize_url: @endpoint[:authorize_url], token_url: @endpoint[:token_url],
            redirect_uri: redirect_uri
          )
        end

        def access_token_for(token)
          OAuth2::AccessToken.new(client(nil), token)
        end

        def normalize_token(token)
          { access_token: token.token, refresh_token: token.refresh_token, expires_at: token.expires_at ? Time.zone.at(token.expires_at) : nil }
        end

        def query_params(from, to)
          if @provider == "google"
            { timeMin: from.iso8601, timeMax: to.iso8601, singleEvents: true, orderBy: "startTime" }
          else
            { startDateTime: from.iso8601, endDateTime: to.iso8601 }
          end
        end

        def items(payload)
          @provider == "google" ? payload["items"].to_a : payload["value"].to_a
        end

        def normalize_event(item)
          @provider == "google" ? normalize_google_event(item) : normalize_microsoft_event(item)
        end

        def normalize_google_event(item)
          all_day = item.dig("start", "date").present?
          {
            uid: item["id"],
            title: item["summary"].presence || "(untitled)",
            starts_at: parse_time(item.dig("start", "dateTime") || item.dig("start", "date")),
            ends_at: parse_time(item.dig("end", "dateTime") || item.dig("end", "date")),
            all_day: all_day,
            location: item["location"]
          }
        end

        def normalize_microsoft_event(item)
          {
            uid: item["id"],
            title: item["subject"].presence || "(untitled)",
            starts_at: parse_time(item.dig("start", "dateTime")),
            ends_at: parse_time(item.dig("end", "dateTime")),
            all_day: item["isAllDay"] == true,
            location: item.dig("location", "displayName")
          }
        end

        def parse_time(value)
          value.present? ? Time.zone.parse(value) : nil
        end
    end
  end
end
