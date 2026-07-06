module Api
  module V1
    class PetsController < BaseController
      def index
        pets = Current.household.pets.ordered
        render json: paginate(pets).map { |pet| serialize(pet) }
      end

      def show
        render json: serialize(Current.household.pets.find(params[:id]))
      end

      private
        def serialize(pet)
          pet.as_json(only: %i[id name species breed weight identifier born_on])
        end
    end
  end
end
