module Api
  module V1
    class ConversationsController < BaseController
      def index
        render json: paginate(accessible_conversations.ordered).map { |conversation| serialize(conversation) }
      end

      private
        # Only conversations the current user participates in are accessible — a household
        # member should not be able to read conversations they aren't part of.
        def accessible_conversations
          Current.household.conversations
            .joins(:conversation_participants)
            .where(conversation_participants: { user_id: Current.user.id })
            .distinct
        end

        def serialize(conversation)
          conversation.as_json(only: %i[id name])
        end
    end
  end
end
