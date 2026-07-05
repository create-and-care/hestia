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
  end
end
