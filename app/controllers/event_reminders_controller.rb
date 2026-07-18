class EventRemindersController < ApplicationController
  before_action :set_event

  def create
    reminder = @event.event_reminders.new(minutes_before: reminder_params[:minutes_before], user: recipient)

    if reminder.save
      redirect_to edit_calendar_event_path(@event), notice: t(".notice")
    else
      redirect_to edit_calendar_event_path(@event), alert: reminder.errors.full_messages.to_sentence
    end
  end

  def destroy
    @event.event_reminders.find(params[:id]).destroy
    redirect_to edit_calendar_event_path(@event), notice: t(".notice")
  end

  private
    def set_event
      @event = Current.household.calendar_events.find(params[:calendar_event_id])
    end

    # The recipient must always be a member of the current household (never an
    # id supplied as-is by the client) — see Spec §15.
    def recipient
      Current.household.users.find_by(id: reminder_params[:user_id]) || Current.user
    end

    def reminder_params
      params.require(:event_reminder).permit(:minutes_before, :user_id)
    end
end
