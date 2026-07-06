require "test_helper"

class WasteCollectionEventTest < ActiveSupport::TestCase
  test "requires a collected_on" do
    event = households(:alpha).waste_collection_events.build(waste_type: "ordures")
    assert_not event.valid?
    event.collected_on = Date.current
    assert event.valid?
  end

  test "waste_type must be a known type" do
    event = households(:alpha).waste_collection_events.build(collected_on: Date.current)
    event.waste_type = "invalid"
    assert_not event.valid?
    event.waste_type = "ordures"
    assert event.valid?
  end

  test "is scoped to its household" do
    assert_not_includes households(:alpha).waste_collection_events, waste_collection_events(:beta_event)
  end

  test "optionally belongs to a series" do
    event = waste_collection_events(:alpha_event)
    assert_equal waste_collection_series(:alpha_trash), event.waste_collection_series

    standalone = households(:alpha).waste_collection_events.create!(waste_type: "verre", collected_on: Date.current)
    assert_nil standalone.waste_collection_series
  end

  test "ordered orders by collected_on ascending" do
    household = households(:alpha)
    later = household.waste_collection_events.create!(waste_type: "verre", collected_on: Date.current + 2.weeks)
    sooner = household.waste_collection_events.create!(waste_type: "compost", collected_on: Date.current + 1.day)
    scoped = household.waste_collection_events.where(id: [ later.id, sooner.id ]).ordered
    assert_equal [ sooner, later ], scoped.to_a
  end
end
