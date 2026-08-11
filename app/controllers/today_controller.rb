class TodayController < ApplicationController
  include HouseholdOccurrences

  # One page answering "what's on today?", merged from the same
  # ingredients Dashboard and Calendar already compute separately: overdue
  # tasks/vaccinations/plant care, food expiring, and the day's calendar
  # occurrences (events, birthdays, waste collections, travel days) — sorted
  # by time of day instead of split across module-shaped cards.
  def show
    @household = Current.household
    range = Date.current.beginning_of_day..Date.current.end_of_day

    @overdue_tasks = @household.module_enabled?("tasks") ? overdue_tasks : Task.none
    @overdue_vaccinations = @household.module_enabled?("pets") ? overdue_vaccinations : PetVaccination.none
    @overdue_plant_care = @household.module_enabled?("outdoor") ? overdue_plant_care : PlantCareTask.none
    @fridge_items_expiring = @household.module_enabled?("fridge") ? @household.fridge_items.expiring : FridgeItem.none
    @plants_needing_attention = if @household.module_enabled?("outdoor")
      @household.plants.needing_care.includes(:plant_care_tasks).select { |plant| plant.care_status.in?(%i[overdue soon]) }
    else
      []
    end
    @occurrences = today_occurrences(range)
  end

  private
    # Each source gated on its own module toggle rather than one shared
    # "calendar" check: unlike CalendarController (reachable only when
    # calendar itself is enabled), this page is ungated, so a household
    # that disabled calendar but kept birthdays/waste/trips on would
    # otherwise lose those from the page too.
    def today_occurrences(range)
      occurrences = []
      occurrences += event_occurrences(range) if @household.module_enabled?("calendar")
      occurrences += birthday_occurrences_in(range) if @household.module_enabled?("birthdays")
      occurrences += waste_occurrences_in(range) if @household.module_enabled?("waste")
      occurrences += trip_occurrences_in(range) if @household.module_enabled?("trips")
      occurrences.sort_by(&:first)
    end

    # Narrowed in SQL via CalendarEvent.overlapping before expansion, the same
    # bound Dashboard's own @upcoming_events widget uses — otherwise this loads
    # every event a household has ever created on every visit to this page.
    def event_occurrences(range)
      @household.calendar_events.overlapping(range.begin, range.end).includes(:participants)
                .flat_map { |event| event.occurrences_between(range.begin, range.end).map { |time| [ time, event ] } }
    end
end
