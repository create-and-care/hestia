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
end
