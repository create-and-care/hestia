module Api
  module V1
    class GiftIdeasController < BaseController
      before_action :set_gift_list

      def create
        idea = @gift_list.gift_ideas.create!(idea_params)
        render json: serialize(idea), status: :created
      end

      private
        def set_gift_list
          @gift_list = Current.household.gift_lists.find(params[:gift_list_id])
          head :not_found and return unless @gift_list.visible_to?(Current.user)
        end

        def idea_params
          params.permit(:name, :price, :url, :comment, :status)
        end

        def serialize(idea)
          idea.as_json(only: %i[id name price url comment status gift_list_id])
        end
    end
  end
end
