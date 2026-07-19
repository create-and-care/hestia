require "test_helper"

class WasteCollectionEventsControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as(users(:one)) }

  test "create adds a one-time collection event" do
    assert_difference -> { households(:alpha).waste_collection_events.count }, 1 do
      post waste_collection_events_path, params: { waste_collection_event: { waste_type: "encombrants", collected_on: Date.current + 1.week } }
    end
    assert_redirected_to waste_path
  end

  test "destroy" do
    event = waste_collection_events(:alpha_event)
    delete waste_collection_event_path(event)
    assert_redirected_to waste_path
    assert_not WasteCollectionEvent.exists?(event.id)
  end

  test "destroy gives a success flash notice" do
    event = waste_collection_events(:alpha_event)
    delete waste_collection_event_path(event)
    follow_redirect!
    assert_includes @response.body, "Collection deleted."
  end

  test "cannot destroy another household's event" do
    event = waste_collection_events(:beta_event)
    assert_no_difference -> { WasteCollectionEvent.count } do
      delete waste_collection_event_path(event)
    end
    assert_response :not_found
  end

  test "create gives a success flash notice" do
    post waste_collection_events_path, params: { waste_collection_event: { waste_type: "verre", collected_on: Date.current + 1.week } }
    assert_redirected_to waste_path
    follow_redirect!
    assert_includes @response.body, "Collection added."
  end

  test "create with a blank collected_on does not persist and surfaces an error" do
    assert_no_difference -> { WasteCollectionEvent.count } do
      post waste_collection_events_path, params: { waste_collection_event: { waste_type: "verre", collected_on: "" } }
    end
    assert_redirected_to waste_path
    assert_equal "Collected on can't be blank", flash[:alert]
  end

  test "edit and update an event's type and date" do
    event = waste_collection_events(:alpha_event)
    get edit_waste_collection_event_path(event)
    assert_response :success

    patch waste_collection_event_path(event), params: { waste_collection_event: { waste_type: "compost", collected_on: Date.current + 3.days } }
    assert_redirected_to waste_path
    event.reload
    assert_equal "compost", event.waste_type
  end

  test "cannot edit another household's event" do
    get edit_waste_collection_event_path(waste_collection_events(:beta_event))
    assert_response :not_found
  end
end
