require "test_helper"

module OpenFoodFacts
  class LookupProductTest < ActiveSupport::TestCase
    test "returns name and brand for a known barcode" do
      stub_request(:get, %r{world\.openfoodfacts\.org/api/v2/product/3017620422003})
        .to_return(
          status: 200,
          body: { status: 1, product: { product_name: "Nutella", brands: "Ferrero,Nutella" } }.to_json
        )

      result = OpenFoodFacts::LookupProduct.call(barcode: "3017620422003")
      assert_equal "Nutella", result[:name]
      assert_equal "Ferrero", result[:brand]
    end

    test "returns nil when the product is unknown" do
      stub_request(:get, %r{world\.openfoodfacts\.org})
        .to_return(status: 200, body: { status: 0 }.to_json)

      assert_nil OpenFoodFacts::LookupProduct.call(barcode: "0000000000000")
    end

    test "returns nil on network failure instead of raising" do
      stub_request(:get, %r{world\.openfoodfacts\.org}).to_timeout

      assert_nil OpenFoodFacts::LookupProduct.call(barcode: "3017620422003")
    end

    test "returns nil for a blank barcode without any HTTP call" do
      assert_nil OpenFoodFacts::LookupProduct.call(barcode: "")
    end

    test "a second lookup of the same barcode is served from the cache" do
      stub = stub_request(:get, %r{world\.openfoodfacts\.org/api/v2/product/3017620422003})
        .to_return(status: 200, body: { status: 1, product: { product_name: "Nutella", brands: "Ferrero" } }.to_json)

      with_cache do
        first = OpenFoodFacts::LookupProduct.call(barcode: "3017620422003")
        second = OpenFoodFacts::LookupProduct.call(barcode: "3017620422003")

        assert_equal first, second
        assert_requested stub, times: 1
      end
    end

    test "a barcode is normalized before it reaches the cache key" do
      stub = stub_request(:get, %r{world\.openfoodfacts\.org/api/v2/product/3017620422003})
        .to_return(status: 200, body: { status: 1, product: { product_name: "Nutella" } }.to_json)

      with_cache do
        OpenFoodFacts::LookupProduct.call(barcode: "3017620422003")
        OpenFoodFacts::LookupProduct.call(barcode: "3017-6204-22003") # the same barcode, as a scanner may hand it over

        assert_requested stub, times: 1
      end
    end

    # A timeout and an unknown product both come back as nil. Caching that
    # would turn a few seconds of flaky network into 30 days of "this product
    # does not exist" for a barcode that does.
    test "a failed lookup is not cached" do
      stub = stub_request(:get, %r{world\.openfoodfacts\.org}).to_timeout

      with_cache do
        2.times { assert_nil OpenFoodFacts::LookupProduct.call(barcode: "3017620422003") }

        assert_requested stub, times: 2
      end
    end
  end
end
