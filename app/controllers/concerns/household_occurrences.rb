module HouseholdOccurrences
  extend ActiveSupport::Concern

  private
    # Tasks/Calendar interconnection: surface overdue tasks
    # alongside events instead of them only ever showing on the Tasks board.
    # Same definition of "overdue" as the badge on the task itself and as the
    # dashboard widget — spelled once, on the model.
    def overdue_tasks
      Current.household.tasks.general.overdue
    end

    # Pets/Calendar interconnection: surfaces overdue vaccine boosters across every pet in the
    # household in one place, instead of requiring each pet's page to be opened individually.
    def overdue_vaccinations
      PetVaccination.where(pet_id: Current.household.pet_ids).where("booster_on < ?", Date.current).order(:booster_on)
    end

    # Plants/Calendar interconnection: surfaces overdue plant care tasks across every plant in the
    # household in one place, instead of requiring the Exterior page to be opened individually.
    def overdue_plant_care
      PlantCareTask.joins(:plant).where(plants: { household_id: Current.household.id })
                    .where("next_due_on < ?", Date.current).order(:next_due_on).includes(:plant)
    end

    # Birthdays (Contact#born_on) surfaced alongside real events
    # (interconnection with Birthdays) — represented as [date, contact] pairs
    # so the view can tell them apart from [time, CalendarEvent] pairs.
    # `in_time_zone`, not `to_time`: ApplicationController wraps every request
    # in Time.use_zone(household.time_zone), and `to_time` ignores Time.zone
    # entirely (it anchors at midnight in the server's own system zone) — on a
    # server whose system zone differs from the household's, this would sort
    # a same-day birthday onto the wrong side of events near midnight.
    def birthday_occurrences_in(range)
      return [] if @member_id

      Current.household.contacts.where.not(born_on: nil).flat_map do |contact|
        contact.birthdays_between(range.begin.to_date, range.end.to_date).map { |date| [ date.in_time_zone, contact ] }
      end
    end

    # Waste/Calendar interconnection: surfaces upcoming collections alongside real
    # events instead of them only ever showing on the Waste module's own page.
    def waste_occurrences_in(range)
      return [] if @member_id

      Current.household.waste_collection_events
        .where(collected_on: range.begin.to_date..range.end.to_date)
        .map { |event| [ event.collected_on.in_time_zone, event ] }
    end

    # Trips/Calendar interconnection: surfaces every day of a trip on the calendar (one
    # occurrence per day in range) instead of it only ever showing on the Trips module's own page.
    #
    # Narrowed to trips overlapping range in SQL, then each trip's own span is
    # clamped to range before enumerating dates — a multi-week or multi-year
    # trip otherwise walks every day it covers just to keep the handful inside
    # the window, the same unbounded-relation cost PERF-04/05 fixed elsewhere.
    def trip_occurrences_in(range)
      return [] if @member_id

      Current.household.trips.where.not(starts_on: nil)
        .where(starts_on: ..range.end.to_date)
        .where("COALESCE(ends_on, starts_on) >= ?", range.begin.to_date)
        .flat_map do |trip|
          span_start = [ trip.starts_on, range.begin.to_date ].max
          span_end = [ trip.ends_on || trip.starts_on, range.end.to_date ].min
          (span_start..span_end).map { |date| [ date.in_time_zone, trip ] }
        end
    end

    # CalendarEvent occurrences (real start times) within range, as
    # [time, event] pairs — the same shape the date-only interconnections
    # below produce (anchored at midnight instead of a real time).
    def event_occurrences_in(events, range)
      events.flat_map { |event| event.occurrences_between(range.begin, range.end).map { |time| [ time, event ] } }
    end

    # Concatenates any number of already-computed [time, occurrence] lists
    # and sorts them into the single shape calendar/_occurrences_list renders —
    # the one place that ordering is decided, so every caller reads the same
    # way regardless of which sources it chose to include.
    def merge_occurrences(*occurrence_lists)
      occurrence_lists.flatten(1).sort_by(&:first)
    end
end
