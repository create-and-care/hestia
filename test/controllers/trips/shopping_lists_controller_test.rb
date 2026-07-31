require "test_helper"

class Trips::ShoppingListsControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as(users(:one)) }

  test "create responds with a turbo stream" do
    trip = trips(:alpha_trip)
    assert_difference -> { trip.shopping_lists.count }, 1 do
      post trip_shopping_lists_path(trip), params: { shopping_list: { name: "Chalet" } }, as: :turbo_stream
    end
    assert_response :success
  end

  test "create with a blank name flashes an alert" do
    trip = trips(:alpha_trip)
    assert_no_difference -> { trip.shopping_lists.count } do
      post trip_shopping_lists_path(trip), params: { shopping_list: { name: "" } }
    end
    assert_redirected_to trip
  end

  test "destroy responds with a turbo stream" do
    trip = trips(:alpha_trip)
    list = trip.shopping_lists.create!(household: households(:alpha), name: "Chalet")
    delete trip_shopping_list_path(trip, list), as: :turbo_stream
    assert_response :success
    assert_not ShoppingList.exists?(list.id)
  end

  test "cannot destroy a shopping list from another household's trip" do
    trip = trips(:beta_trip)
    list = trip.shopping_lists.create!(household: households(:beta), name: "Chalet")
    delete trip_shopping_list_path(trip, list)
    assert_response :not_found
  end
end
