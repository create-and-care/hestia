require "net/http"
require "json"

# Recherche d'un produit par code-barres auprès d'Open Food Facts (CDC §16),
# base ouverte choisie plutôt qu'un référentiel propriétaire pour le scan
# Courses/Frigo (CDC §9.1, §9.4). Échoue silencieusement (retourne nil) en cas de
# panne réseau ou de produit inconnu : le scan reste une aide, jamais un blocage —
# la saisie manuelle demeure toujours possible.
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
