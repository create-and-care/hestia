class PlantCareTasksController < ApplicationController
  before_action :set_plant
  before_action :set_care_task, only: %i[update destroy complete]

  def create
    care_task = @plant.plant_care_tasks.new(care_task_params)
    if care_task.save
      redirect_to plant_path(@plant)
    else
      redirect_to plant_path(@plant), alert: care_task.errors.full_messages.to_sentence
    end
  end

  def update
    if @care_task.update(care_task_params)
      redirect_to plant_path(@plant)
    else
      redirect_to plant_path(@plant), alert: @care_task.errors.full_messages.to_sentence
    end
  end

  def destroy
    @care_task.destroy
    redirect_to plant_path(@plant)
  end

  def complete
    @care_task.complete!(author: Current.user)
    redirect_to plant_path(@plant)
  end

  private
    def set_plant
      @plant = Current.household.plants.find(params[:plant_id])
    end

    def set_care_task
      @care_task = @plant.plant_care_tasks.find(params[:id])
    end

    def care_task_params
      params.require(:plant_care_task).permit(:care_type, :frequency, :interval, :next_due_on)
    end
end
