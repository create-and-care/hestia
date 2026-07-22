class DashboardController < ApplicationController
  # Household dashboard: the active household, its members, the
  # invite code, and cross-module widgets built from modules already enabled
  # for the household — each widget stays read-only here, consuming the
  # owning module's own models/services rather than duplicating their logic.
  def show
    @household = Current.household
    @memberships = @household.memberships.includes(:user)
    @other_households = Current.user.households.where.not(id: @household.id)

    # Vehicles/Dashboard interconnection: surfaces the module's central business rule (upcoming
    # technical inspection deadlines) somewhere other than each vehicle's own page.
    @vehicles_needing_attention = @household.vehicles.select { |vehicle| vehicle.inspection_status.in?(%i[urgent expired]) }

    if @household.module_enabled?("fridge")
      # expires_on is always present here: expiration_status only returns
      # :expired/:urgent/:soon when it is (see Perishable#expiration_status).
      @fridge_items_expiring = @household.fridge_items.select { |item| item.expiration_status.in?(%i[expired urgent soon]) }
                                          .sort_by(&:expires_on).first(5)
    end

    if @household.module_enabled?("birthdays")
      # days_until_birthday is always present here: proximity_status only
      # returns :today/:week when it is (see Contact#proximity_status).
      @upcoming_birthdays = @household.contacts.select { |contact| contact.proximity_status.in?(%i[today week]) }
                                       .sort_by(&:days_until_birthday).first(5)
    end

    if @household.module_enabled?("tasks")
      @overdue_tasks = @household.tasks.where(done: false).select { |task| task.due_status == :overdue }
                                  .sort_by(&:due_on).first(5)
    end

    if @household.module_enabled?("calendar")
      range = Date.current.beginning_of_day..(Date.current + 7.days).end_of_day
      @upcoming_events = @household.calendar_events.flat_map { |event| event.occurrences_between(range.begin, range.end).map { |time| [ time, event ] } }
                                    .sort_by(&:first).first(5)
    end

    if @household.module_enabled?("fridge") && @household.module_enabled?("recipes")
      @recipe_suggestions = Frigo::SuggestRecipes.call(household: @household, limit: 3)
    end
  end
end
