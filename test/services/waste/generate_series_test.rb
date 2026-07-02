require "test_helper"

module Waste
  class GenerateSeriesTest < ActiveSupport::TestCase
    test "generates events on the given weekday within the period" do
      start = Date.new(2026, 7, 6)
      series = Waste::GenerateSeries.call(
        household: households(:alpha), waste_type: "ordures", weekday: start.wday,
        starts_on: start, ends_on: start + 3.weeks, interval_weeks: 1
      )
      assert_equal 4, series.waste_collection_events.count
      series.waste_collection_events.each { |event| assert_equal start.wday, event.collected_on.wday }
    end

    test "honours the interval in weeks" do
      start = Date.new(2026, 7, 6)
      series = Waste::GenerateSeries.call(
        household: households(:alpha), waste_type: "verre", weekday: start.wday,
        starts_on: start, ends_on: start + 7.weeks, interval_weeks: 2
      )
      assert_equal 4, series.waste_collection_events.count # semaines 0, 2, 4, 6
    end
  end
end
