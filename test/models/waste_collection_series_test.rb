require "test_helper"

class WasteCollectionSeriesTest < ActiveSupport::TestCase
  test "requires starts_on and ends_on" do
    series = households(:alpha).waste_collection_series.build(waste_type: "ordures", weekday: 1)
    assert_not series.valid?
    series.starts_on = Date.current
    series.ends_on = Date.current + 1.month
    assert series.valid?
  end

  test "waste_type must be a known type" do
    series = households(:alpha).waste_collection_series.build(weekday: 1, starts_on: Date.current, ends_on: Date.current + 1.month)
    series.waste_type = "invalid"
    assert_not series.valid?
    series.waste_type = "recyclage"
    assert series.valid?
  end

  test "weekday must be between 0 and 6" do
    series = households(:alpha).waste_collection_series.build(waste_type: "ordures", starts_on: Date.current, ends_on: Date.current + 1.month)
    series.weekday = 7
    assert_not series.valid?
    series.weekday = 0
    assert series.valid?
  end

  test "is scoped to its household" do
    assert_not_includes households(:alpha).waste_collection_series, waste_collection_series(:beta_series)
  end

  test "destroying a series destroys its events" do
    series = waste_collection_series(:alpha_trash)
    assert_difference -> { WasteCollectionEvent.count }, -series.waste_collection_events.count do
      series.destroy
    end
  end
end
