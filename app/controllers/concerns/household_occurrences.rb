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
    def birthday_occurrences_in(range)
      return [] if @member_id

      Current.household.contacts.where.not(born_on: nil).flat_map do |contact|
        contact.birthdays_between(range.begin.to_date, range.end.to_date).map { |date| [ date.to_time, contact ] }
      end
    end

    # Waste/Calendar interconnection: surfaces upcoming collections alongside real
    # events instead of them only ever showing on the Waste module's own page.
    def waste_occurrences_in(range)
      return [] if @member_id

      Current.household.waste_collection_events
        .where(collected_on: range.begin.to_date..range.end.to_date)
        .map { |event| [ event.collected_on.to_time, event ] }
    end

    # Trips/Calendar interconnection: surfaces every day of a trip on the calendar (one
    # occurrence per day in range) instead of it only ever showing on the Trips module's own page.
    def trip_occurrences_in(range)
      return [] if @member_id

      Current.household.trips.where.not(starts_on: nil).flat_map do |trip|
        (trip.starts_on..(trip.ends_on || trip.starts_on)).filter_map do |date|
          date.to_time.between?(range.begin, range.end) ? [ date.to_time, trip ] : nil
        end
      end
    end

    # Merges CalendarEvent occurrences (real start times) with the date-only
    # interconnections above (anchored at midnight, so they sort to the start
    # of their day) into the single [time, occurrence] shape every consumer
    # of this concern renders via calendar/_occurrences_list.
    def merge_occurrences(events, range)
      event_occurrences = events.flat_map { |event| event.occurrences_between(range.begin, range.end).map { |time| [ time, event ] } }
      (event_occurrences + birthday_occurrences_in(range) + waste_occurrences_in(range) + trip_occurrences_in(range)).sort_by(&:first)
    end
end
