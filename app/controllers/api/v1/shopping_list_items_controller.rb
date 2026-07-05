module Api
  module V1
    class ShoppingListItemsController < BaseController
      before_action :set_shopping_list

      def create
        item = Courses::AddItem.call(
          shopping_list: @shopping_list, name: params[:name], quantity: params[:quantity],
          unit: params[:unit], rayon: params[:rayon]
        )
        render json: serialize(item), status: :created
      end

      def toggle
        item = @shopping_list.items.find(params[:id])
        Courses::ToggleItem.call(item: item)
        render json: serialize(item)
      end

      def destroy
        @shopping_list.items.find(params[:id]).destroy
        head :no_content
      end

      private
        def set_shopping_list
          @shopping_list = Current.household.shopping_lists.find(params[:shopping_list_id])
        end

        def serialize(item)
          item.as_json(only: %i[id name quantity unit rayon checked position])
        end
    end
  end
end
