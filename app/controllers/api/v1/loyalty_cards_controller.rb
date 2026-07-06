module Api
  module V1
    class LoyaltyCardsController < BaseController
      def index
        cards = Current.household.loyalty_cards.ordered
        render json: paginate(cards).map { |card| serialize(card) }
      end

      private
        def serialize(card)
          card.as_json(only: %i[id name number code_format position loyalty_brand_id])
        end
    end
  end
end
