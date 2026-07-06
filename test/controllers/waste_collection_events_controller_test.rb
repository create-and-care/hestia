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

  test "cannot destroy another household's event" do
    event = waste_collection_events(:beta_event)
    assert_no_difference -> { WasteCollectionEvent.count } do
      delete waste_collection_event_path(event)
    end
    assert_response :not_found
  end
end
