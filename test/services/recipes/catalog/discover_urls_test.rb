require "test_helper"

module Recipes
  module Catalog
    class DiscoverUrlsTest < ActiveSupport::TestCase
      SITEMAP = <<~XML
        <?xml version="1.0" encoding="UTF-8"?>
        <urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
          <url><loc>https://example.com/recipes/older</loc><lastmod>2020-01-01</lastmod></url>
          <url><loc>https://example.com/recipes/newer</loc><lastmod>2025-01-01</lastmod></url>
          <url><loc>https://example.com/recipes/no-date</loc></url>
        </urlset>
      XML

      setup { ENV["RECIPE_CATALOG_SITEMAP_URL"] = "https://example.com/sitemap.xml" }
      teardown { ENV.delete("RECIPE_CATALOG_SITEMAP_URL") }

      test "returns urls ordered by most recent lastmod first" do
        stub_request(:get, "https://example.com/sitemap.xml").to_return(status: 200, body: SITEMAP)

        urls = Recipes::Catalog::DiscoverUrls.call(limit: 10).map(&:url)

        assert_equal "https://example.com/recipes/newer", urls.first
        assert_includes urls, "https://example.com/recipes/no-date"
      end

      test "respects the limit" do
        stub_request(:get, "https://example.com/sitemap.xml").to_return(status: 200, body: SITEMAP)

        assert_equal 1, Recipes::Catalog::DiscoverUrls.call(limit: 1).size
      end

      test "returns an empty array when the sitemap is unreachable" do
        stub_request(:get, "https://example.com/sitemap.xml").to_return(status: 500)

        assert_equal [], Recipes::Catalog::DiscoverUrls.call(limit: 10)
      end
    end
  end
end
