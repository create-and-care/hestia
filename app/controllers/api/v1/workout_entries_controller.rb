module Api
  module V1
    class WorkoutEntriesController < BaseController
      # Wellbeing data is scoped per user, never per household — sensitive health
      # data must remain isolated even between members of the same household.
      def index
        render json: paginate(Current.user.workout_entries.recent).map { |entry| serialize(entry) }
      end

      def create
        entry = Current.user.workout_entries.create!(entry_params)
        render json: serialize(entry), status: :created
      end

      private
        def entry_params
          params.permit(:done_on, :exercise, :duration_minutes)
        end

        def serialize(entry)
          entry.as_json(only: %i[id done_on exercise duration_minutes])
        end
    end
  end
end
