require "test_helper"

class Trips::NotesControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as(users(:one)) }

  test "create responds with a turbo stream" do
    trip = trips(:alpha_trip)
    assert_difference -> { trip.notes.count }, 1 do
      post trip_notes_path(trip), params: { note: { title: "Passeport", content: "à vérifier" } }, as: :turbo_stream
    end
    assert_response :success
  end

  test "create with a blank title flashes an alert instead of failing silently" do
    trip = trips(:alpha_trip)
    assert_no_difference -> { trip.notes.count } do
      post trip_notes_path(trip), params: { note: { title: "" } }
    end
    assert_redirected_to trip
  end

  test "gets the edit form" do
    trip = trips(:alpha_trip)
    note = trip.notes.create!(household: households(:alpha), title: "N", content: "C")
    get edit_trip_note_path(trip, note)
    assert_response :success
  end

  test "update renames a trip note" do
    trip = trips(:alpha_trip)
    note = trip.notes.create!(household: households(:alpha), title: "N", content: "C")
    patch trip_note_path(trip, note), params: { note: { title: "Nouveau titre" } }
    assert_redirected_to trip
    assert_equal "Nouveau titre", note.reload.title
  end

  test "update with a blank title re-renders the edit form" do
    trip = trips(:alpha_trip)
    note = trip.notes.create!(household: households(:alpha), title: "N", content: "C")
    patch trip_note_path(trip, note), params: { note: { title: "" } }
    assert_response :unprocessable_entity
  end

  test "destroy responds with a turbo stream" do
    trip = trips(:alpha_trip)
    note = trip.notes.create!(household: households(:alpha), title: "N", content: "C")
    delete trip_note_path(trip, note), as: :turbo_stream
    assert_response :success
    assert_not Note.exists?(note.id)
  end

  test "cannot edit a note from another household's trip" do
    trip = trips(:beta_trip)
    note = trip.notes.create!(household: households(:beta), title: "N")
    get edit_trip_note_path(trip, note)
    assert_response :not_found
  end
end
