require "net/http"
require "json"

# Looks up a product by barcode from Open Food Facts, an open
# database chosen over a proprietary reference for the Shopping/Fridge
# scan. Fails silently (returns nil) in case of
# network failure or unknown product: scanning remains a convenience, never a blocker —
# manual entry always remains possible.
module OpenFoodFacts
  class LookupProduct
    ENDPOINT = "https://world.openfoodfacts.org/api/v2/product/%<barcode>s.json?fields=product_name,brands"
    OPEN_TIMEOUT = 3
    READ_TIMEOUT = 3

    # ── Cache conventions for third-party lookups ─────────────────────────
    # This is the first Rails.cache call site in the app, so it sets the
    # shape the others follow (Geocoding::SearchAddress is the second):
    #
    #   key   "<provider>/<resource>/v<n>/<identifier>"
    #         The provider segment keeps two APIs from colliding on the same
    #         identifier. The v<n> is the shape of *our* parsed hash, not the
    #         upstream API version: bump it and every stale entry is ignored
    #         at once, which beats writing a migration for a cache.
    #   TTL   as long as the underlying fact is stable. A barcode names a
    #         physical product, so 30 days is conservative rather than bold.
    #   nils  never cached (skip_nil). "Unknown product" and "the network was
    #         down" both surface as nil here, and pinning the second one for
    #         30 days would turn a blip into a lasting wrong answer.
    CACHE_TTL = 30.days
    CACHE_KEY = "open_food_facts/product/v1/%<barcode>s"

    def self.call(barcode:) = new(barcode:).call

    def initialize(barcode:)
      @barcode = barcode.to_s.gsub(/\D/, "")
    end

    def call
      return nil if @barcode.blank?

      Rails.cache.fetch(format(CACHE_KEY, barcode: @barcode), expires_in: CACHE_TTL, skip_nil: true) { lookup }
    end

    private
      def lookup
        response = fetch
        return nil unless response.is_a?(Net::HTTPSuccess)

        parse(response.body)
      rescue Timeout::Error, SocketError, Net::HTTPError, JSON::ParserError
        nil
      end

      def fetch
        uri = URI(format(ENDPOINT, barcode: @barcode))
        Net::HTTP.start(uri.host, uri.port, use_ssl: true, open_timeout: OPEN_TIMEOUT, read_timeout: READ_TIMEOUT) do |http|
          request = Net::HTTP::Get.new(uri)
          request["User-Agent"] = "Hestia (self-hosted household app; https://github.com)"
          http.request(request)
        end
      end

      def parse(body)
        data = JSON.parse(body)
        return nil unless data["status"] == 1

        product = data["product"] || {}
        name = product["product_name"].presence
        return nil unless name

        { name: name, brand: product["brands"].to_s.split(",").first&.strip }
      end
  end
end
