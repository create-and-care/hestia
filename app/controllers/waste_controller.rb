class WasteController < ApplicationController
  WINDOW_WEEKS = 8

  # View of upcoming collections (8-week rolling window, navigable) + management of recurring series.
  def show
    @from = parse_from
    @events = Current.household.waste_collection_events
      .where(collected_on: @from..(@from + WINDOW_WEEKS.weeks))
      .ordered
      .group_by(&:collected_on)
    @series = Current.household.waste_collection_series.order(:weekday)
    @event = Current.household.waste_collection_events.new(collected_on: Date.current)
  end

  private
    def parse_from
      Date.parse(params[:from])
    rescue ArgumentError, TypeError
      Date.current
    end
end
