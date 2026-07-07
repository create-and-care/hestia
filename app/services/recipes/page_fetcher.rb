require "net/http"
require "uri"

module Recipes
  # Fetches a page's raw body over HTTP with a short timeout. Shared by the
  # user-triggered URL import (Recipes::ImportFromUrl) and the catalog
  # crawler (Recipes::Catalog::*) — returns nil rather than raising on any
  # network/protocol failure so callers can simply skip.
  class PageFetcher
    def self.call(url) = new(url).call

    def initialize(url)
      @url = url.to_s.strip
    end

    def call
      return if @url.blank?

      uri = URI.parse(@url)
      return unless uri.is_a?(URI::HTTP)

      response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https",
        open_timeout: 5, read_timeout: 5) do |http|
        http.get(uri.request_uri, "User-Agent" => "Hestia/1.0")
      end
      response.body if response.is_a?(Net::HTTPSuccess)
    rescue StandardError
      nil
    end
  end
end
