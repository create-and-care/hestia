class CalendarController < ApplicationController
  # Vue mois (par défaut) ou liste, avec filtre par membre. Les occurrences des
  # événements récurrents sont développées côté serveur sur la plage affichée.
  def show
    @view = params[:view] == "list" ? "list" : "month"
    @member_id = params[:member_id].presence
    @members = Current.household.users.order(:name)
    @events = filtered_events

    respond_to do |format|
      format.html { load_html_view }
      format.pdf do
        month = parse_month
        range = month.beginning_of_month.beginning_of_day..month.end_of_month.end_of_day
        send_data Pdf::CalendarMonthDocument.new(month, occurrences_in(range)).render,
          filename: "calendrier-#{month.strftime('%Y-%m')}.pdf", type: "application/pdf", disposition: "inline"
      end
    end
  end

  private
    def load_html_view
      if @view == "list"
        range = Time.current.beginning_of_day..(Time.current + 60.days).end_of_day
        @occurrences = occurrences_in(range)
      else
        @month = parse_month
        @grid_start = @month.beginning_of_week
        @grid_end = @month.end_of_month.end_of_week
        range = @grid_start.beginning_of_day..@grid_end.end_of_day
        @by_day = occurrences_in(range).group_by { |time, _event| time.to_date }
        @holidays = holidays_by_date(@grid_start.to_date, @grid_end.to_date)
      end
    end

    # Jours fériés France/Belgique/Suisse (CDC §9.2, §16), activables au choix par
    # foyer (Household#holiday_country) — indexés par date pour un lookup direct en vue.
    def holidays_by_date(from, to)
      return {} if Current.household.holiday_country.blank?

      (from.year..to.year).flat_map { |year| HolidayReference.for(Current.household.holiday_country, year) }
        .index_by { |holiday| holiday[:date] }
    end

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
