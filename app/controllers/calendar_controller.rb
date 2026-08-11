class CalendarController < ApplicationController
  include HouseholdOccurrences

  VIEWS = %w[month week day list].freeze

  # Month, week, day, or list view, with filter by member. Recurring event
  # occurrences are expanded server-side over the displayed range. The
  # chosen view is remembered per user so returning to the
  # calendar defaults to whatever was last used, not always month.
  def show
    @view = resolve_view
    @member_id = params[:member_id].presence
    @members = Current.household.users.order(:name)
    @events = filtered_events

    respond_to do |format|
      format.html { load_html_view }
      format.pdf do
        month = parse_month
        range = month.beginning_of_month.beginning_of_day..month.end_of_month.end_of_day
        # Birthdays (Contact), waste collections (WasteCollectionEvent) and trips (Trip) aren't
        # CalendarEvent records — the PDF layout assumes the CalendarEvent interface, so only
        # real events go in it.
        event_only_occurrences = occurrences_in(range).reject { |_time, occurrence| occurrence.is_a?(Contact) || occurrence.is_a?(WasteCollectionEvent) || occurrence.is_a?(Trip) }
        send_data Pdf::CalendarMonthDocument.new(month, event_only_occurrences).render,
          filename: "#{t('.pdf_filename_prefix')}-#{month.strftime('%Y-%m')}.pdf", type: "application/pdf", disposition: "inline"
      end
    end
  end

  private
    def resolve_view
      requested = params[:view].presence
      return Current.user.calendar_view.presence || "month" unless requested && VIEWS.include?(requested)

      Current.user.update_column(:calendar_view, requested) if requested != Current.user.calendar_view
      requested
    end

    def load_html_view
      case @view
      when "list" then load_list_view
      when "week" then load_week_view
      when "day" then load_day_view
      else load_month_view
      end
    end

    def load_list_view
      range = Time.current.beginning_of_day..(Time.current + 60.days).end_of_day
      @occurrences = occurrences_in(range)
      @overdue_tasks = overdue_tasks
      @overdue_vaccinations = overdue_vaccinations
      @overdue_plant_care = overdue_plant_care
    end

    def load_month_view
      @month = parse_month
      @grid_start = @month.beginning_of_week
      @grid_end = @month.end_of_month.end_of_week
      range = @grid_start.beginning_of_day..@grid_end.end_of_day
      @by_day = occurrences_in(range).group_by { |time, _event| time.to_date }
      @holidays = holidays_by_date(@grid_start.to_date, @grid_end.to_date)
    end

    def load_week_view
      @date = parse_date
      @grid_start = @date.beginning_of_week
      @grid_end = @date.end_of_week
      range = @grid_start.beginning_of_day..@grid_end.end_of_day
      @by_day = occurrences_in(range).group_by { |time, _event| time.to_date }
      @holidays = holidays_by_date(@grid_start.to_date, @grid_end.to_date)
    end

    def load_day_view
      @date = parse_date
      range = @date.beginning_of_day..@date.end_of_day
      @occurrences = occurrences_in(range)
      @holidays = holidays_by_date(@date, @date)
      if @date == Date.current
        @overdue_tasks = overdue_tasks
        @overdue_vaccinations = overdue_vaccinations
        @overdue_plant_care = overdue_plant_care
      end
    end

    # France/Belgium/Switzerland public holidays, optionally enabled per
    # household (Household#holiday_country) — indexed by date for a direct lookup in the view.
    def holidays_by_date(from, to)
      return {} if Current.household.holiday_country.blank?

      (from.year..to.year).flat_map { |year| HolidayReference.for(Current.household.holiday_country, year) }
        .index_by { |holiday| holiday[:date] }
    end

    # Participants are only rendered by the day/list views (see
    # calendar/_occurrences_list.html.erb) — the month/week grid cells never
    # touch the association, so eager loading it there is flagged as unused.
    def filtered_events
      scope = Current.household.calendar_events
      scope = scope.includes(:participants) if @view.in?(%w[day list])
      if @member_id
        scope = scope.joins(:event_participants).where(event_participants: { user_id: @member_id }).distinct
      end
      scope.to_a
    end

    def parse_month
      Date.parse("#{params[:month]}-01")
    rescue ArgumentError, TypeError
      Date.current.beginning_of_month
    end

    def parse_date
      Date.parse(params[:date])
    rescue ArgumentError, TypeError
      Date.current
    end

    def occurrences_in(range)
      merge_occurrences(event_occurrences_in(@events, range), birthday_occurrences_in(range), waste_occurrences_in(range), trip_occurrences_in(range))
    end
end
