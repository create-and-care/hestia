class WorkoutTemplatesController < ApplicationController
  before_action :set_template, only: %i[edit update destroy log]

  def index
    @templates = Current.user.workout_templates.order(:name)
  end

  def new
    @template = Current.user.workout_templates.new
  end

  def create
    @template = Current.user.workout_templates.new(template_params)
    if @template.save
      redirect_to edit_workout_template_path(@template), notice: t(".created")
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @exercise = @template.workout_template_exercises.new
  end

  def update
    if @template.update(template_params)
      redirect_to workout_templates_path, notice: t(".updated")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @template.destroy
    redirect_to workout_templates_path, notice: t(".deleted")
  end

  # Logs one WorkoutEntry per exercise in the template for the chosen date.
  def log
    @template.log_session(done_on: params[:done_on].presence || Date.current)
    redirect_to wellbeing_path, notice: t(".logged")
  end

  private
    def set_template
      @template = Current.user.workout_templates.find(params[:id])
    end

    def template_params
      params.require(:workout_template).permit(:name)
    end
end
