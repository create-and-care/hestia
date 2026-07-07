require "nokogiri"

module Recipes
  module Catalog
    # Discovers candidate recipe URLs from the configured source sitemap
    # (RECIPE_CATALOG_SITEMAP_URL — the only place that URL is configured,
    # see Recipes::Catalog::SyncJob). Returns the most recently modified
    # entries first, so a limited pilot batch targets fresh content before
    # the full catalog is ever enabled.
    class DiscoverUrls
      Entry = Struct.new(:url, :lastmod, keyword_init: true)

      def self.call(limit: 300) = new(limit: limit).call

      def initialize(limit:)
        @limit = limit
      end

      def call
        xml = PageFetcher.call(sitemap_url)
        return [] if xml.blank?

        entries = Nokogiri::XML(xml).css("url").filter_map do |node|
          loc = node.at_css("loc")&.text&.strip
          next if loc.blank?

          Entry.new(url: loc, lastmod: parse_lastmod(node.at_css("lastmod")&.text))
        end

        entries.sort_by { |entry| entry.lastmod || Time.at(0) }.reverse.first(@limit)
      end

      private
        def sitemap_url
          ENV["RECIPE_CATALOG_SITEMAP_URL"].presence ||
            Rails.application.credentials.dig(:recipe_catalog, :sitemap_url)
        end

        def parse_lastmod(value)
          Time.zone.parse(value) if value.present?
        rescue ArgumentError
          nil
        end
    end
  end
end
