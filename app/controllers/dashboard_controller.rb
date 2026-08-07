class DashboardController < ApplicationController
  # Household dashboard: the active household, its members, the
  # invite code, and cross-module widgets built from modules already enabled
  # for the household — each widget stays read-only here, consuming the
  # owning module's own models/services rather than duplicating their logic.
  #
  # Every widget below narrows in SQL before it narrows in Ruby. The predicates
  # are date arithmetic, so no amount of `includes` would have helped: the cost
  # was loading whole unbounded relations to keep five rows, and it grew with
  # the age of the household rather than with what is on screen. Each model
  # owns the scope that expresses its own threshold (Vehicle.inspection_due,
  # Perishable#expiring, Task.overdue, Contact.birthday_within,
  # Plant.needing_care, CalendarEvent.overlapping), so the SQL and the badge
  # shown next to it can never disagree.
  WIDGET_LIMIT = 5

  def show
    @household = Current.household
    @memberships = @household.memberships.includes(:user)
    @other_households = Current.user.households.where.not(id: @household.id)

    # Vehicles/Dashboard interconnection: surfaces the module's central business rule (upcoming
    # technical inspection deadlines) somewhere other than each vehicle's own page.
    @vehicles_needing_attention = @household.vehicles.inspection_due

    if @household.module_enabled?("outdoor")
      # Plants/Dashboard interconnection: surfaces plants whose care is overdue or due soon,
      # instead of requiring the Exterior page to be opened for each plant individually.
      # `needing_care` is a superset (any task due within three days); #care_status
      # is what distinguishes :overdue/:soon from :ok, and it needs the tasks loaded.
      @plants_needing_attention = @household.plants.needing_care.includes(:plant_care_tasks)
                                            .select { |plant| plant.care_status.in?(%i[overdue soon]) }.first(WIDGET_LIMIT)
    end

    if @household.module_enabled?("fridge")
      # expires_on is always present here: `expiring` excludes NULLs, and
      # expiration_status only returns :expired/:urgent/:soon when it is set.
      @fridge_items_expiring = @household.fridge_items.expiring.limit(WIDGET_LIMIT)
    end

    if @household.module_enabled?("birthdays")
      # `birthday_within` is a superset matched on (month, day); #proximity_status
      # is what turns that into :today/:week, and it also gives the sort key —
      # a recurring date cannot be ordered by the database on born_on.
      @upcoming_birthdays = @household.contacts.birthday_within(Contact::WEEK_DAYS)
                                       .select { |contact| contact.proximity_status.in?(%i[today week]) }
                                       .sort_by(&:days_until_birthday).first(WIDGET_LIMIT)
    end

    if @household.module_enabled?("tasks")
      @overdue_tasks = @household.tasks.overdue.limit(WIDGET_LIMIT)
    end

    if @household.module_enabled?("calendar")
      range = Date.current.beginning_of_day..(Date.current + 7.days).end_of_day
      @upcoming_events = @household.calendar_events.overlapping(range.begin, range.end)
                                    .flat_map { |event| event.occurrences_between(range.begin, range.end).map { |time| [ time, event ] } }
                                    .sort_by(&:first).first(WIDGET_LIMIT)
    end

    if @household.module_enabled?("fridge") && @household.module_enabled?("recipes")
      @recipe_suggestions = Frigo::SuggestRecipes.call(household: @household, limit: 3)
    end
  end
end
