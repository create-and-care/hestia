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

  test "gets the edit form" do
    get edit_trip_path(trips(:alpha_trip))
    assert_response :success
  end

  test "cannot edit another household's trip" do
    get edit_trip_path(trips(:beta_trip))
    assert_response :not_found
  end

  test "update renames a trip" do
    trip = trips(:alpha_trip)
    patch trip_path(trip), params: { trip: { name: "Nouveau nom" } }
    assert_redirected_to trip
    assert_equal "Nouveau nom", trip.reload.name
  end

  test "update with a blank name re-renders the edit form" do
    trip = trips(:alpha_trip)
    patch trip_path(trip), params: { trip: { name: "" } }
    assert_response :unprocessable_entity
    assert_not_equal "", trip.reload.name
  end

  test "show only renders enabled sections" do
    trip = trips(:alpha_trip)
    trip.update!(disabled_sections: [ "menu" ])

    get trip_path(trip)

    assert_response :success
    assert_select "button[role=tab][data-value=menu]", 0
    assert_select "button[role=tab][data-value=settings]", 1
  end

  test "update_sections disables the unchecked sections" do
    trip = trips(:alpha_trip)
    patch update_sections_trip_path(trip), params: { trip: { enabled_sections: %w[notes tasks] } }
    assert_redirected_to trip
    trip.reload
    assert trip.section_enabled?("notes")
    assert trip.section_enabled?("tasks")
    assert_not trip.section_enabled?("shopping_lists")
    assert_not trip.section_enabled?("addresses")
    assert_not trip.section_enabled?("menu")
  end

  test "update_sections with nothing checked disables every section" do
    trip = trips(:alpha_trip)
    patch update_sections_trip_path(trip), params: { trip: {} }
    trip.reload
    Trip::SECTIONS.each { |key| assert_not trip.section_enabled?(key) }
  end

  test "show has a destructive delete button and empty states" do
    trip = trips(:alpha_trip)
    trip.notes.destroy_all
    trip.tasks.destroy_all
    trip.addresses.destroy_all
    trip.shopping_lists.destroy_all

    get trip_path(trip)

    assert_response :success
    assert_select "form[action=?][data-turbo-confirm]", trip_path(trip)
  end
end
