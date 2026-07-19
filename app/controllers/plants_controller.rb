class PlantsController < ApplicationController
  before_action :set_plant, only: %i[edit update destroy]

  def create
    plant = Current.household.plants.new(plant_params)
    if plant.save
      redirect_to exterior_path
    else
      redirect_to exterior_path, alert: plant.errors.full_messages.to_sentence
    end
  end

  def edit
  end

  def update
    if @plant.update(plant_params)
      redirect_to exterior_path, notice: t(".updated")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @plant.destroy
    redirect_to exterior_path, notice: t(".deleted")
  end

  private
    def set_plant
      @plant = Current.household.plants.find(params[:id])
    end

    def plant_params
      params.require(:plant).permit(:name, :location, :notes, :plant_reference_id, :photo)
    end
end
