require "test_helper"

class ProductsControllerTest < ActionDispatch::IntegrationTest
  test "index requires authentication" do
    get products_path
    assert_redirected_to new_session_path
  end

  test "index shows the household catalogue" do
    sign_in_as(users(:one))
    get products_path
    assert_response :success
    assert_includes @response.body, "Lait"
  end

  test "lookup returns the household's own catalogue entry without any HTTP call" do
    sign_in_as(users(:one))
    products(:alpha_milk).update!(barcode: "1234567890123")

    get lookup_products_path(barcode: "1234567890123")

    assert_response :success
    assert_equal "Lait", JSON.parse(@response.body)["name"]
  end

  test "lookup falls back to Open Food Facts when the barcode is unknown locally" do
    sign_in_as(users(:one))
    stub_request(:get, %r{world\.openfoodfacts\.org})
      .to_return(status: 200, body: { status: 1, product: { product_name: "Nutella", brands: "Ferrero" } }.to_json)

    get lookup_products_path(barcode: "3017620422003")

    assert_response :success
    assert_equal "Nutella", JSON.parse(@response.body)["name"]
  end

  test "lookup returns 404 when nothing is found" do
    sign_in_as(users(:one))
    stub_request(:get, %r{world\.openfoodfacts\.org}).to_return(status: 200, body: { status: 0 }.to_json)

    get lookup_products_path(barcode: "0000000000000")

    assert_response :not_found
  end
end
