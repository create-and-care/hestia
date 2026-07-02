class WeightEntriesController < ApplicationController
  def create
    Current.user.weight_entries.create(entry_params)
    redirect_to wellbeing_path
  end

  def destroy
    Current.user.weight_entries.find(params[:id]).destroy
    redirect_to wellbeing_path
  end

  private
    def entry_params
      params.require(:weight_entry).permit(:recorded_on, :weight)
    end
end
