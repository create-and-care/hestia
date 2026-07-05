module Api
  module V1
    class ShoppingListsController < BaseController
      def index
        render json: paginate(Current.household.shopping_lists.order(:name)).map { |list| serialize(list) }
      end

      def show
        render json: serialize(find_list, with_items: true)
      end

      private
        def find_list
          Current.household.shopping_lists.find(params[:id])
        end

        def serialize(list, with_items: false)
          data = list.as_json(only: %i[id name icon])
          data["items"] = list.items.map { |item| item.as_json(only: %i[id name quantity unit rayon checked position]) } if with_items
          data
        end
    end
  end
end
