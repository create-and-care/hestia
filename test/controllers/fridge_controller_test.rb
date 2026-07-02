require "test_helper"

class FridgeControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as(users(:one)) }

  test "requires authentication" do
    sign_out
    get fridge_path
    assert_redirected_to new_session_path
  end

  test "shows the household's fridge and wires the real-time stream" do
    get fridge_path
    assert_response :success
    assert_select "turbo-cable-stream-source"
    assert_includes @response.body, "Yaourts"
    assert_not_includes @response.body, "Lait" # beta's item
  end

  test "search filters the items" do
    get fridge_path(q: "yaourt")
    assert_response :success
    assert_includes @response.body, "Yaourts"
    assert_not_includes @response.body, "Petits pois"
  end
end
