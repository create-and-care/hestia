class CalendarEventsController < ApplicationController
  before_action :set_event, only: %i[edit update destroy]

  def new
    start = params[:starts_at].present? ? (Time.zone.parse(params[:starts_at]) rescue nil) : nil
    start ||= Time.current.change(min: 0) + 1.hour
    @event = Current.household.calendar_events.new(starts_at: start, ends_at: start + 1.hour, color: "blue")
  end

  def create
    Calendar::CreateEvent.call(
      household: Current.household,
      attributes: event_params,
      participant_ids: participant_ids
    )
    redirect_to calendar_path, notice: t(".notice")
  rescue ActiveRecord::RecordInvalid => e
    @event = e.record
    render :new, status: :unprocessable_entity
  end

  def edit
    @occurrence = parse_occurrence
    apply_occurrence_preview(@occurrence) if @occurrence && @event.recurring?
  end

  # A recurring event's edit form can target either "this occurrence only"
  # (splits it off into its own standalone event and excludes the date from
  # the series) or "the whole series" (the plain update, as before) — the
  # business rule from Spec §9.2 that was previously entirely unimplemented.
  def update
    if editing_single_occurrence?
      detach_occurrence
      redirect_to calendar_path, notice: t(".notice")
    else
      @event.assign_attributes(event_params)

      if @event.save
        @event.participants = Current.household.users.where(id: participant_ids)
        redirect_to calendar_path, notice: t(".notice")
      else
        render :edit, status: :unprocessable_entity
      end
    end
  end

  def destroy
    occurrence = parse_occurrence

    if params[:scope] == "occurrence" && @event.recurring? && occurrence
      @event.update!(excluded_occurrences: (@event.excluded_occurrences + [ occurrence.to_date ]).uniq)
    else
      @event.destroy
    end

    redirect_to calendar_path, notice: t(".notice")
  end

  private
    def set_event
      @event = Current.household.calendar_events.find(params[:id])
    end

    def event_params
      params.require(:calendar_event).permit(:title, :starts_at, :ends_at, :all_day,
        :location, :color, :frequency, :recurrence_interval, :recurrence_until, :event_type)
    end

    def participant_ids
      Array(params[:participant_ids]).reject(&:blank?)
    end

    def parse_occurrence
      Time.zone.parse(params[:occurrence]) if params[:occurrence].present?
    rescue ArgumentError
      nil
    end

    def apply_occurrence_preview(occurrence)
      duration = @event.ends_at && @event.starts_at ? @event.ends_at - @event.starts_at : nil
      @event.starts_at = occurrence
      @event.ends_at = duration ? occurrence + duration : nil
    end

    def editing_single_occurrence?
      params[:scope] == "occurrence" && @event.recurring? && parse_occurrence.present?
    end

    def detach_occurrence
      occurrence = parse_occurrence
      @event.update!(excluded_occurrences: (@event.excluded_occurrences + [ occurrence.to_date ]).uniq)

      standalone = Current.household.calendar_events.new(
        event_params.merge(frequency: "none", recurrence_interval: 1, recurrence_until: nil)
      )
      standalone.save!
      standalone.participants = Current.household.users.where(id: participant_ids)
    end
end
