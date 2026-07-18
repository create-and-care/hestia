module Api
  module V1
    class GiftListsController < BaseController
      def index
        visible_ids = Current.household.gift_lists.select { |list| list.visible_to?(Current.user) }.map(&:id)
        render json: paginate(Current.household.gift_lists.where(id: visible_ids).ordered).map { |list| serialize(list) }
      end

      private
        def serialize(list)
          list.as_json(only: %i[id name perspective contact_id])
        end
    end
  end
end
