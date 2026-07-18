class MessagesController < ApplicationController
  def create
    @conversation = accessible_conversations.find(params[:conversation_id])
    @message = @conversation.messages.new(author: Current.user, content: params.require(:message)[:content])

    if @message.save
      @conversation.touch
      respond_to do |format|
        format.turbo_stream # resets the field; the message appears via the real-time stream
        format.html { redirect_to @conversation }
      end
    else
      respond_to do |format|
        format.turbo_stream { render :create_invalid }
        format.html { redirect_to @conversation, alert: @message.errors.full_messages.to_sentence }
      end
    end
  end

  private
    def accessible_conversations
      Current.household.conversations
        .joins(:conversation_participants)
        .where(conversation_participants: { user_id: Current.user.id })
        .distinct
    end
end
