class WorkoutEntriesController < ApplicationController
  before_action :set_entry, only: %i[edit update destroy]

  def create
    entry = Current.user.workout_entries.new(entry_params)
    if entry.save
      redirect_to wellbeing_path, notice: t(".added")
    else
      redirect_to wellbeing_path, alert: entry.errors.full_messages.to_sentence
    end
  end

  def edit
  end

  def update
    if @entry.update(entry_params)
      redirect_to wellbeing_path, notice: t(".updated")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @entry.destroy
    redirect_to wellbeing_path, notice: t(".deleted")
  end

  private
    def set_entry
      @entry = Current.user.workout_entries.find(params[:id])
    end

    def entry_params
      params.require(:workout_entry).permit(:done_on, :exercise, :duration_minutes)
    end
end
