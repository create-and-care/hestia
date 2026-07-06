require "test_helper"

class WasteCollectionSeriesControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as(users(:one)) }

  test "create generates a series and its events" do
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

  test "create with an invalid waste_type does not create a series" do
    assert_no_difference -> { WasteCollectionSeries.count } do
      post waste_collection_series_index_path, params: { waste_collection_series: {
        waste_type: "invalid_type", weekday: 1, interval_weeks: 1,
        starts_on: Date.current, ends_on: Date.current + 4.weeks
      } }
    end
    assert_redirected_to waste_path
  end

  test "destroy removes the series and its events" do
    series = waste_collection_series(:alpha_trash)
    assert_difference -> { WasteCollectionEvent.count }, -series.waste_collection_events.count do
      delete waste_collection_series_path(series)
    end
    assert_redirected_to waste_path
    assert_not WasteCollectionSeries.exists?(series.id)
  end

  test "cannot destroy another household's series" do
    series = waste_collection_series(:beta_series)
    assert_no_difference -> { WasteCollectionSeries.count } do
      delete waste_collection_series_path(series)
    end
    assert_response :not_found
  end
end
