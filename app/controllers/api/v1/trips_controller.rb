module Api
  module V1
    class TripsController < BaseController
      def index
        render json: paginate(Current.household.trips.ordered).map { |trip| serialize(trip) }
      end

      def show
        render json: serialize(find_trip)
      end

      private
        def find_trip
          Current.household.trips.find(params[:id])
        end

        def serialize(trip)
          trip.as_json(only: %i[id name starts_on ends_on])
        end
    end
  end
end
