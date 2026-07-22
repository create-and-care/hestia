require "net/http"
require "json"

# Looks up places via Nominatim/OpenStreetMap, to pre-fill
# an Address (name, address, GPS coordinates) on creation. Fails silently
# (returns []) in case of network failure: manual entry always remains possible,
# notably for addresses deliberately kept confidential.
#
# Complies with Nominatim's usage policy: User-Agent identifying the application,
# no more than one request at a time (interactive usage, no bulk processing).
module Geocoding
  class SearchAddress
    ENDPOINT = "https://nominatim.openstreetmap.org/search"
    OPEN_TIMEOUT = 3
    READ_TIMEOUT = 3
    LIMIT = 5

    def self.call(query:) = new(query:).call

    def initialize(query:)
      @query = query.to_s.strip
    end

    def call
      return [] if @query.blank?

      response = fetch
      return [] unless response.is_a?(Net::HTTPSuccess)

      parse(response.body)
    rescue Timeout::Error, SocketError, Net::HTTPError, JSON::ParserError
      []
    end

    private
      def fetch
        uri = URI(ENDPOINT)
        uri.query = URI.encode_www_form(q: @query, format: "jsonv2", limit: LIMIT, addressdetails: 1)
        Net::HTTP.start(uri.host, uri.port, use_ssl: true, open_timeout: OPEN_TIMEOUT, read_timeout: READ_TIMEOUT) do |http|
          request = Net::HTTP::Get.new(uri)
          request["User-Agent"] = "Hestia (self-hosted household app; https://github.com)"
          http.request(request)
        end
      end

      def parse(body)
        JSON.parse(body).map do |result|
          {
            name: result["display_name"].to_s.split(",").first,
            full_address: result["display_name"],
            latitude: result["lat"]&.to_f,
            longitude: result["lon"]&.to_f
          }
        end
      end
  end
end
