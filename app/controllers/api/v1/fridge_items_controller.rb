module Api
  module V1
    class FridgeItemsController < BaseController
      def index
        render json: paginate(Current.household.fridge_items.ordered).map { |item| serialize(item) }
      end

      def create
        item = Frigo::AddItem.call(
          household: Current.household, name: params[:name],
          location: params[:location], expires_on: params[:expires_on]
        )
        render json: serialize(item), status: :created
      end

      private
        def serialize(item)
          item.as_json(only: %i[id name location expires_on]).merge(expiration_status: item.expiration_status)
        end
    end
  end
end
