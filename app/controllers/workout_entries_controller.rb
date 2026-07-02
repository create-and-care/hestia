class WorkoutEntriesController < ApplicationController
  def create
    Current.user.workout_entries.create(entry_params)
    redirect_to wellbeing_path
  end

  def destroy
    Current.user.workout_entries.find(params[:id]).destroy
    redirect_to wellbeing_path
  end

  private
    def entry_params
      params.require(:workout_entry).permit(:done_on, :exercise, :duration_minutes)
    end
end
