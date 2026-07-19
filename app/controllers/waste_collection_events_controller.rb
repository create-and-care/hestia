class WasteCollectionEventsController < ApplicationController
  before_action :set_event, only: %i[edit update destroy]

  # Adding / removing a single occurrence without affecting the series.
  def create
    event = Current.household.waste_collection_events.new(event_params)
    if event.save
      redirect_to waste_path, notice: t(".created")
    else
      redirect_to waste_path, alert: event.errors.full_messages.to_sentence
    end
  end

  def edit
  end

  def update
    if @event.update(event_params)
      redirect_to waste_path, notice: t(".updated")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @event.destroy
    redirect_to waste_path, notice: t(".deleted")
  end

  private
    def set_event
      @event = Current.household.waste_collection_events.find(params[:id])
    end

    def event_params
      params.require(:waste_collection_event).permit(:waste_type, :collected_on)
    end
end
