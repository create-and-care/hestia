require "test_helper"

class WasteControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as(users(:one)) }

  test "requires authentication" do
    sign_out
    get waste_path
    assert_redirected_to new_session_path
  end

  test "show renders" do
    get waste_path
    assert_response :success
  end

  test "generate a series creates its events" do
    assert_difference -> { households(:alpha).waste_collection_series.count }, 1 do
      assert_difference -> { WasteCollectionEvent.count }, 5 do
        post waste_collection_series_index_path, params: { waste_collection_series: {
          waste_type: "recyclage", weekday: Date.current.wday,
          interval_weeks: 1, starts_on: Date.current, ends_on: Date.current + 4.weeks
        } }
      end
    end
    assert_redirected_to waste_path
  end

  test "add a single collection event" do
    assert_difference -> { households(:alpha).waste_collection_events.count }, 1 do
      post waste_collection_events_path, params: { waste_collection_event: { waste_type: "encombrants", collected_on: Date.current + 1.week } }
    end
    assert_redirected_to waste_path
  end

  test "destroy a series removes its events" do
    series = waste_collection_series(:alpha_trash)
    assert_difference -> { WasteCollectionEvent.count }, -series.waste_collection_events.count do
      delete waste_collection_series_path(series)
    end
    assert_redirected_to waste_path
  end

  test "destroy a single event" do
    event = waste_collection_events(:alpha_event)
    delete waste_collection_event_path(event)
    assert_not WasteCollectionEvent.exists?(event.id)
  end

  test "cannot destroy another household's series" do
    delete waste_collection_series_path(waste_collection_series(:beta_series))
    assert_response :not_found
  end
end
