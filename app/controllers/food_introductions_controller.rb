class FoodIntroductionsController < ApplicationController
  before_action :set_baby

  def create
    @baby.food_introductions.create(introduction_params)
    redirect_to @baby
  end

  def destroy
    @baby.food_introductions.find(params[:id]).destroy
    redirect_to @baby
  end

  private
    def set_baby
      @baby = Current.household.baby_profiles.find(params[:baby_profile_id])
    end

    def introduction_params
      params.require(:food_introduction).permit(:food, :introduced_on, :acceptance)
    end
end
