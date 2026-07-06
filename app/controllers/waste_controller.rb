class WasteController < ApplicationController
  # View of upcoming collections (8 weeks) + management of recurring series.
  def show
    @events = Current.household.waste_collection_events
      .where(collected_on: Date.current..(Date.current + 8.weeks))
      .ordered
      .group_by(&:collected_on)
    @series = Current.household.waste_collection_series.order(:weekday)
    @event = Current.household.waste_collection_events.new(collected_on: Date.current)
  end
end
