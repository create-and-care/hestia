require "test_helper"

class TripsControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as(users(:one)) }

  test "index requires authentication" do
    sign_out
    get trips_path
    assert_redirected_to new_session_path
  end

  test "index shows the household's trips only" do
    get trips_path
    assert_response :success
    assert_includes @response.body, "Week-end à la mer"
    assert_not_includes @response.body, "Voyage Beta"
  end

  test "create a trip" do
    assert_difference -> { households(:alpha).trips.count }, 1 do
      post trips_path, params: { trip: { name: "Montagne" } }
    end
    assert_redirected_to Trip.find_by(name: "Montagne")
  end

  test "records added to a trip are isolated from the general views" do
    trip = trips(:alpha_trip)
    post trip_notes_path(trip), params: { note: { title: "Passeport", content: "à vérifier" } }
    assert_redirected_to trip

    get notes_path
    assert_not_includes @response.body, "Passeport" # excluded from the general view

    get trip_path(trip)
    assert_includes @response.body, "Passeport" # present in the trip
  end

  test "add a shopping list, a task and an address to the trip" do
    trip = trips(:alpha_trip)
    post trip_shopping_lists_path(trip), params: { shopping_list: { name: "Chalet" } }
    post trip_tasks_path(trip), params: { task: { title: "Réserver" } }
    post trip_addresses_path(trip), params: { address: { name: "Hôtel", address_type: "hotel", phone: "0102030405" } }
    assert_equal 1, trip.shopping_lists.count
    assert_equal 1, trip.tasks.count
    assert_equal 1, trip.addresses.count
    address = trip.addresses.sole
    assert_equal "hotel", address.address_type
    assert_equal "0102030405", address.phone
  end

  test "trip address subform offers a type select, a phone field, and online search" do
    get trip_path(trips(:alpha_trip))
    assert_select "select#address_address_type"
    assert_select "input#address_phone"
    assert_select "[data-controller='geocode-lookup']"
  end

  test "track_expenses creates a linked shared project on first use" do
    trip = trips(:alpha_trip)
    assert_difference -> { SharedProject.count }, 1 do
      post track_expenses_trip_path(trip)
    end
    project = trip.reload.shared_project
    assert_equal trip.name, project.name
    assert_redirected_to project
  end

  test "track_expenses reuses the existing linked project on later calls" do
    trip = trips(:alpha_trip)
    post track_expenses_trip_path(trip)
    existing = trip.reload.shared_project

    assert_no_difference -> { SharedProject.count } do
      post track_expenses_trip_path(trip)
    end
    assert_redirected_to existing
  end

  test "cannot track expenses for another household's trip" do
    post track_expenses_trip_path(trips(:beta_trip))
    assert_response :not_found
  end

  test "delete a trip" do
    trip = trips(:alpha_trip)
    delete trip_path(trip)
    assert_redirected_to trips_path
    assert_not Trip.exists?(trip.id)
  end

  test "cannot access another household's trip" do
    get trip_path(trips(:beta_trip))
    assert_response :not_found
  end
end
