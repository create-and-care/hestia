module Api
  module V1
    class MessagesController < BaseController
      def create
        conversation = accessible_conversations.find(params[:conversation_id])
        message = conversation.messages.create!(author: Current.user, content: params[:content])
        conversation.touch
        render json: serialize(message), status: :created
      end

      private
        # Only conversations the current user participates in are accessible — a household
        # member should not be able to post into conversations they aren't part of.
        def accessible_conversations
          Current.household.conversations
            .joins(:conversation_participants)
            .where(conversation_participants: { user_id: Current.user.id })
            .distinct
        end

        def serialize(message)
          message.as_json(only: %i[id content author_id conversation_id created_at])
        end
    end
  end
end
