class WeightEntriesController < ApplicationController
  before_action :set_entry, only: %i[edit update destroy]

  def create
    entry = Current.user.weight_entries.new(entry_params)
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
      @entry = Current.user.weight_entries.find(params[:id])
    end

    def entry_params
      params.require(:weight_entry).permit(:recorded_on, :weight)
    end
end
