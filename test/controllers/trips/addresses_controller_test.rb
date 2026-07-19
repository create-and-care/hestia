require "test_helper"

class Trips::AddressesControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as(users(:one)) }

  test "create responds with a turbo stream" do
    trip = trips(:alpha_trip)
    assert_difference -> { trip.addresses.count }, 1 do
      post trip_addresses_path(trip), params: { address: { name: "Hôtel", address_type: "hotel" } }, as: :turbo_stream
    end
    assert_response :success
  end

  test "create with a blank name flashes an alert" do
    trip = trips(:alpha_trip)
    assert_no_difference -> { trip.addresses.count } do
      post trip_addresses_path(trip), params: { address: { name: "" } }
    end
    assert_redirected_to trip
  end

  test "gets the edit form" do
    trip = trips(:alpha_trip)
    address = trip.addresses.create!(household: households(:alpha), name: "A", address_type: "autre")
    get edit_trip_address_path(trip, address)
    assert_response :success
  end

  test "update renames a trip address" do
    trip = trips(:alpha_trip)
    address = trip.addresses.create!(household: households(:alpha), name: "A", address_type: "autre")
    patch trip_address_path(trip, address), params: { address: { name: "Nouveau nom", address_type: "restaurant" } }
    assert_redirected_to trip
    address.reload
    assert_equal "Nouveau nom", address.name
    assert_equal "restaurant", address.address_type
  end

  test "update with a blank name re-renders the edit form" do
    trip = trips(:alpha_trip)
    address = trip.addresses.create!(household: households(:alpha), name: "A", address_type: "autre")
    patch trip_address_path(trip, address), params: { address: { name: "" } }
    assert_response :unprocessable_entity
  end

  test "destroy responds with a turbo stream" do
    trip = trips(:alpha_trip)
    address = trip.addresses.create!(household: households(:alpha), name: "A", address_type: "autre")
    delete trip_address_path(trip, address), as: :turbo_stream
    assert_response :success
    assert_not Address.exists?(address.id)
  end

  test "cannot edit an address from another household's trip" do
    trip = trips(:beta_trip)
    address = trip.addresses.create!(household: households(:beta), name: "A", address_type: "autre")
    get edit_trip_address_path(trip, address)
    assert_response :not_found
  end
end
