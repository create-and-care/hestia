class CalendarEventsController < ApplicationController
  before_action :set_event, only: %i[edit update destroy]

  def new
    start = Time.current.change(min: 0) + 1.hour
    @event = Current.household.calendar_events.new(starts_at: start, ends_at: start + 1.hour, color: "blue")
  end

  def create
    Calendar::CreateEvent.call(
      household: Current.household,
      attributes: event_params,
      participant_ids: participant_ids
    )
    redirect_to calendar_path, notice: "Événement créé."
  rescue ActiveRecord::RecordInvalid => e
    @event = e.record
    render :new, status: :unprocessable_entity
  end

  def edit
  end

  def update
    @event.assign_attributes(event_params)

    if @event.save
      @event.participants = Current.household.users.where(id: participant_ids)
      redirect_to calendar_path, notice: "Événement mis à jour."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @event.destroy
    redirect_to calendar_path, notice: "Événement supprimé."
  end

  private
    def set_event
      @event = Current.household.calendar_events.find(params[:id])
    end

    def event_params
      params.require(:calendar_event).permit(:title, :starts_at, :ends_at, :all_day,
        :location, :color, :frequency, :recurrence_interval, :recurrence_until)
    end

    def participant_ids
      Array(params[:participant_ids]).reject(&:blank?)
    end
end
