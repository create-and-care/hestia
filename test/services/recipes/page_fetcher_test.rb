require "test_helper"

module Recipes
  class PageFetcherTest < ActiveSupport::TestCase
    test "returns the body on success" do
      stub_request(:get, "https://example.com/page").to_return(status: 200, body: "<html>ok</html>")
      assert_equal "<html>ok</html>", Recipes::PageFetcher.call("https://example.com/page")
    end

    test "returns nil on a non-success response" do
      stub_request(:get, "https://example.com/missing").to_return(status: 404)
      assert_nil Recipes::PageFetcher.call("https://example.com/missing")
    end

    test "returns nil for a blank url" do
      assert_nil Recipes::PageFetcher.call("")
    end

    test "returns nil for a non-http url" do
      assert_nil Recipes::PageFetcher.call("ftp://example.com/x")
    end
  end
end
