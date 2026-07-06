module Api
  module V1
    class WeightEntriesController < BaseController
      # Wellbeing data is scoped per user, never per household — sensitive health
      # data must remain isolated even between members of the same household.
      def index
        render json: paginate(Current.user.weight_entries.chronological).map { |entry| serialize(entry) }
      end

      def create
        entry = Current.user.weight_entries.create!(entry_params)
        render json: serialize(entry), status: :created
      end

      private
        def entry_params
          params.permit(:recorded_on, :weight)
        end

        def serialize(entry)
          entry.as_json(only: %i[id recorded_on weight])
        end
    end
  end
end
