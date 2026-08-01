class WorkoutTemplateExercisesController < ApplicationController
  before_action :set_template

  def create
    @template.workout_template_exercises.create(exercise_params)
    redirect_to edit_workout_template_path(@template)
  end

  def destroy
    @template.workout_template_exercises.find(params[:id]).destroy
    redirect_to edit_workout_template_path(@template)
  end

  private
    def set_template
      @template = Current.user.workout_templates.find(params[:workout_template_id])
    end

    def exercise_params
      params.require(:workout_template_exercise).permit(:exercise, :duration_minutes)
    end
end
