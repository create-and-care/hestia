class ConversationsController < ApplicationController
  DISCUSSABLE_TYPES = { "Task" => Task, "ShoppingList" => ShoppingList, "CalendarEvent" => CalendarEvent }.freeze

  before_action :set_conversation, only: %i[show edit update destroy]

  def index
    @conversations = accessible_conversations.includes(:conversation_participants, messages: :author).ordered
  end

  def show
    @message = @conversation.messages.new
    @conversation.conversation_participants.find_by(user: Current.user)&.update(last_read_at: Time.current)
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
      @conversation.participant_ids = Current.household.users.where(id: Array(params[:participant_ids])).ids
      if @conversation.participants.reload.include?(Current.user)
        redirect_to @conversation, notice: t(".updated")
      else
        redirect_to conversations_path, notice: t(".left")
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @conversation.destroy
    redirect_to conversations_path, notice: t(".deleted")
  end

  # Finds (or starts) the conversation attached to a task, shopping list or
  # calendar event, so "Discuter de ceci" is a single click rather than the
  # full guided-creation form — the subject already implies name and
  # participants (every household member, since it's a shared context).
  def discuss
    klass = DISCUSSABLE_TYPES.fetch(params[:subject_type])
    subject = klass.where(household: Current.household).find(params[:subject_id])

    conversation = Current.household.conversations.find_by(subject: subject)
    if conversation.nil?
      conversation = Current.household.conversations.create!(name: helpers.conversation_subject_label(subject), subject: subject)
      conversation.participant_ids = Current.household.users.ids
    end
    redirect_to conversation
  rescue KeyError
    head :bad_request
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
