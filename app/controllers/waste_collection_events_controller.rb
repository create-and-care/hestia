class WasteCollectionEventsController < ApplicationController
  # Adding / removing a single occurrence without affecting the series.
  def create
    Current.household.waste_collection_events.create(event_params)
    redirect_to waste_path
  end

  def destroy
    Current.household.waste_collection_events.find(params[:id]).destroy
    redirect_to waste_path
  end

  private
    def event_params
      params.require(:waste_collection_event).permit(:waste_type, :collected_on)
    end
end
