class PlantsController < ApplicationController
  before_action :set_plant, only: %i[show edit update destroy]

  def show
    @care_tasks = @plant.plant_care_tasks.ordered.includes(plant_care_completions: :author)
    @plant_care_task = @plant.plant_care_tasks.new(care_type: "watering", frequency: "daily")
    default_interval = @plant.plant_reference&.default_watering_interval_days
    @plant_care_task.interval = default_interval if default_interval.present? && @care_tasks.none? { |task| task.care_type == "watering" }
  end

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
