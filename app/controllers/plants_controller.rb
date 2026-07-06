class PlantsController < ApplicationController
  def create
    Current.household.plants.create(plant_params)
    redirect_to exterior_path
  end

  def destroy
    Current.household.plants.find(params[:id]).destroy
    redirect_to exterior_path, notice: t(".deleted")
  end

  private
    def plant_params
      params.require(:plant).permit(:name, :location, :notes, :plant_reference_id)
    end
end
