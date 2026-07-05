module Api
  module V1
    class CalendarEventsController < BaseController
      # Développe les occurrences (y compris récurrentes) sur une plage [from, to]
      # (par défaut : les 30 prochains jours), cohérent avec la vue Calendrier web.
      def index
        from = parse_time(params[:from]) || Time.current
        to = parse_time(params[:to]) || (from + 30.days)

        occurrences = Current.household.calendar_events.flat_map do |event|
          event.occurrences_between(from, to).map { |starts_at| serialize(event, starts_at) }
        end.sort_by { |occurrence| occurrence["starts_at"] }

        render json: occurrences
      end

      private
        def parse_time(value)
          Time.zone.parse(value.to_s) if value.present?
        rescue ArgumentError
          nil
        end

        def serialize(event, starts_at)
          event.as_json(only: %i[id title location color all_day]).merge("starts_at" => starts_at)
        end
    end
  end
end
