class ConversationsController < ApplicationController
  before_action :set_conversation, only: %i[show edit update]

  def index
    @conversations = accessible_conversations.includes(:participants).ordered
  end

  def show
    @message = @conversation.messages.new
  end

  def new
    @conversation = Current.household.conversations.new
  end

  def create
    @conversation = Current.household.conversations.new(conversation_params)
    if @conversation.save
      @conversation.participant_ids = participant_ids_including_current
      redirect_to @conversation
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @conversation.update(conversation_params)
      @conversation.participant_ids = participant_ids_including_current
      redirect_to @conversation, notice: "Conversation mise à jour."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private
    def set_conversation
      @conversation = accessible_conversations.find(params[:id])
    end

    # Only conversations the user is a participant in are accessible.
    def accessible_conversations
      Current.household.conversations
        .joins(:conversation_participants)
        .where(conversation_participants: { user_id: Current.user.id })
        .distinct
    end

    def conversation_params
      params.require(:conversation).permit(:name)
    end

    def participant_ids_including_current
      scoped = Current.household.users.where(id: Array(params[:participant_ids])).ids
      (scoped + [ Current.user.id ]).uniq
    end
end
