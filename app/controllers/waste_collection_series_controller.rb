class WasteCollectionSeriesController < ApplicationController
  def create
    Waste::GenerateSeries.call(household: Current.household, **series_params.to_h.symbolize_keys)
    redirect_to waste_path, notice: t(".created")
  rescue ActiveRecord::RecordInvalid
    redirect_to waste_path, alert: t(".invalid")
  end

  def destroy
    Current.household.waste_collection_series.find(params[:id]).destroy
    redirect_to waste_path, notice: t(".deleted")
  end

  private
    def series_params
      params.require(:waste_collection_series).permit(:waste_type, :weekday, :interval_weeks, :starts_on, :ends_on)
    end
end
