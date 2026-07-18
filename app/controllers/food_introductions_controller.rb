class FoodIntroductionsController < ApplicationController
  before_action :set_baby
  before_action :set_introduction, only: %i[edit update destroy]

  def create
    introduction = @baby.food_introductions.new(introduction_params)
    if introduction.save
      redirect_to @baby, notice: t(".created")
    else
      redirect_to @baby, alert: introduction.errors.full_messages.to_sentence
    end
  end

  def edit
  end

  def update
    if @introduction.update(introduction_params)
      redirect_to @baby, notice: t(".updated")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @introduction.destroy
    redirect_to @baby, notice: t(".deleted")
  end

  private
    def set_baby
      @baby = Current.household.baby_profiles.find(params[:baby_profile_id])
    end

    def set_introduction
      @introduction = @baby.food_introductions.find(params[:id])
    end

    def introduction_params
      params.require(:food_introduction).permit(:food, :introduced_on, :acceptance)
    end
end
