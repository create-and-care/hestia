require "net/http"
require "uri"
require "ipaddr"
require "resolv"

module Recipes
  # Fetches a page's raw body over HTTP with a short timeout. Shared by the
  # user-triggered URL import (Recipes::ImportFromUrl) and the catalog
  # crawler (Recipes::Catalog::*) — returns nil rather than raising on any
  # network/protocol failure so callers can simply skip.
  class PageFetcher
    # Blocks SSRF to internal network targets: @url is user-submitted (recipe
    # import) and fetched server-side, so a host resolving to loopback, RFC1918,
    # or link-local (incl. cloud metadata endpoints) must be refused.
    BLOCKED_RANGES = %w[
      0.0.0.0/8 10.0.0.0/8 100.64.0.0/10 127.0.0.0/8 169.254.0.0/16
      172.16.0.0/12 192.0.0.0/24 192.0.2.0/24 192.168.0.0/16
      198.18.0.0/15 198.51.100.0/24 203.0.113.0/24 224.0.0.0/4 240.0.0.0/4
      ::1/128 fc00::/7 fe80::/10
    ].map { |range| IPAddr.new(range) }.freeze

    # How a hostname becomes a list of addresses. Swappable because it is the
    # one part of this class that reaches outside the process *before* the HTTP
    # call, and so the one part WebMock cannot stand in for: a test that stubs
    # the request still fails here, on a machine with no DNS, with the request
    # never attempted. Six tests were failing that way — the guard doing
    # exactly its job, on a question the test had not meant to ask.
    #
    # Not a general seam for the sake of it: production has exactly one
    # resolver, and this default is it.
    DEFAULT_RESOLVER = ->(host) { Resolv.getaddresses(host) }

    class << self
      attr_writer :resolver

      def resolver = @resolver ||= DEFAULT_RESOLVER

      def call(url, resolver: nil) = new(url, resolver: resolver).call
    end

    def initialize(url, resolver: nil)
      @url = url.to_s.strip
      @resolver = resolver || self.class.resolver
    end

    def call
      return if @url.blank?

      uri = URI.parse(@url)
      return unless uri.is_a?(URI::HTTP)
      return unless public_host?(uri.host)

      response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https",
        open_timeout: 5, read_timeout: 5) do |http|
        http.get(uri.request_uri, "User-Agent" => "Hestia/1.0")
      end
      response.body if response.is_a?(Net::HTTPSuccess)
    rescue StandardError
      nil
    end

    private
      def public_host?(host)
        addresses = @resolver.call(host)
        addresses.present? && addresses.all? { |address| BLOCKED_RANGES.none? { |range| range.include?(IPAddr.new(address)) } }
      end
  end
end
