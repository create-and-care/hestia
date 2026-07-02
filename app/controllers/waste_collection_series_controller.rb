class WasteCollectionSeriesController < ApplicationController
  def create
    Waste::GenerateSeries.call(household: Current.household, **series_params.to_h.symbolize_keys)
    redirect_to waste_path, notice: "Série de collectes générée."
  rescue ActiveRecord::RecordInvalid
    redirect_to waste_path, alert: "Série invalide."
  end

  def destroy
    Current.household.waste_collection_series.find(params[:id]).destroy
    redirect_to waste_path, notice: "Série supprimée."
  end

  private
    def series_params
      params.require(:waste_collection_series).permit(:waste_type, :weekday, :interval_weeks, :starts_on, :ends_on)
    end
end
