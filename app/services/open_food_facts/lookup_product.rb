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

    def self.call(barcode:) = new(barcode:).call

    def initialize(barcode:)
      @barcode = barcode.to_s.gsub(/\D/, "")
    end

    def call
      return nil if @barcode.blank?

      response = fetch
      return nil unless response.is_a?(Net::HTTPSuccess)

      parse(response.body)
    rescue Timeout::Error, SocketError, Net::HTTPError, JSON::ParserError
      nil
    end

    private
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
