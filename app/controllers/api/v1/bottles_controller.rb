module Api
  module V1
    class BottlesController < BaseController
      before_action :set_wine_cellar, only: :create

      def index
        render json: paginate(Current.household.bottles.ordered).map { |bottle| serialize(bottle) }
      end

      def create
        bottle = @wine_cellar.bottles.create(
          name: params[:name], vintage: params[:vintage],
          region: params[:region], wine_type: params[:wine_type],
          household: Current.household
        )
        render json: serialize(bottle), status: :created
      end

      private
        def set_wine_cellar
          @wine_cellar = Current.household.wine_cellars.find(params[:wine_cellar_id])
        end

        def serialize(bottle)
          bottle.as_json(only: %i[id name vintage region wine_type in_stock wine_cellar_id])
        end
    end
  end
end
