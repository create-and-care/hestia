class MessageReactionsController < ApplicationController
  before_action :set_message

  def create
    reaction = @message.message_reactions.find_or_initialize_by(user: Current.user)
    reaction.update(emoji: params[:emoji])
    respond_to do |format|
      format.turbo_stream { render turbo_stream: replace_message_stream }
      format.html { redirect_to @message.conversation }
    end
  end

  def destroy
    @message.message_reactions.where(user: Current.user).destroy_all
    respond_to do |format|
      format.turbo_stream { render turbo_stream: replace_message_stream }
      format.html { redirect_to @message.conversation }
    end
  end

  private
    # The message must belong to a conversation the user participates in.
    def set_message
      @message = Message.joins(conversation: :conversation_participants)
        .where(conversation_participants: { user_id: Current.user.id })
        .find(params[:id])
    end

    def replace_message_stream
      turbo_stream.replace(@message, partial: "messages/message", locals: { message: @message.reload })
    end
end
