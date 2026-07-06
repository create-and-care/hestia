module Api
  module V1
    class VehiclesController < BaseController
      def index
        vehicles = Current.household.vehicles.ordered
        render json: paginate(vehicles).map { |vehicle| serialize(vehicle) }
      end

      def show
        render json: serialize(Current.household.vehicles.find(params[:id]))
      end

      private
        def serialize(vehicle)
          vehicle.as_json(only: %i[id name vehicle_type manufacturer plate year energy inspection_expires_on])
        end
    end
  end
end
