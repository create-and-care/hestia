module Api
  module V1
    class GiftListsController < BaseController
      def index
        render json: paginate(Current.household.gift_lists.ordered).map { |list| serialize(list) }
      end

      private
        def serialize(list)
          list.as_json(only: %i[id name perspective contact_id])
        end
    end
  end
end
