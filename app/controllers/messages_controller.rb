class MessagesController < ApplicationController
  def create
    @conversation = accessible_conversations.find(params[:conversation_id])
    @conversation.messages.create!(author: Current.user, content: params.require(:message)[:content])
    @conversation.touch

    respond_to do |format|
      format.turbo_stream # réinitialise le champ ; le message apparaît via le flux temps réel
      format.html { redirect_to @conversation }
    end
  rescue ActiveRecord::RecordInvalid
    redirect_to @conversation
  end

  private
    def accessible_conversations
      Current.household.conversations
        .joins(:conversation_participants)
        .where(conversation_participants: { user_id: Current.user.id })
        .distinct
    end
end
