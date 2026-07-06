module Api
  module V1
    class PlantsController < BaseController
      def index
        render json: paginate(Current.household.plants.ordered).map { |plant| serialize(plant) }
      end

      private
        def serialize(plant)
          plant.as_json(only: %i[id name location notes plant_reference_id])
        end
    end
  end
end
