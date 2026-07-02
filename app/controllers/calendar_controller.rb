class CalendarController < ApplicationController
  # Vue mois (par défaut) ou liste, avec filtre par membre. Les occurrences des
  # événements récurrents sont développées côté serveur sur la plage affichée.
  def show
    @view = params[:view] == "list" ? "list" : "month"
    @member_id = params[:member_id].presence
    @members = Current.household.users.order(:name)
    @events = filtered_events

    if @view == "list"
      range = Time.current.beginning_of_day..(Time.current + 60.days).end_of_day
      @occurrences = occurrences_in(range)
    else
      @month = parse_month
      @grid_start = @month.beginning_of_week
      @grid_end = @month.end_of_month.end_of_week
      range = @grid_start.beginning_of_day..@grid_end.end_of_day
      @by_day = occurrences_in(range).group_by { |time, _event| time.to_date }
    end
  end

  private
    def filtered_events
      scope = Current.household.calendar_events
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

    def occurrences_in(range)
      @events.flat_map { |event| event.occurrences_between(range.begin, range.end).map { |time| [ time, event ] } }
        .sort_by(&:first)
    end
end
