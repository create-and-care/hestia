class FeedingSessionsController < ApplicationController
  before_action :set_baby

  def create
    @baby.feeding_sessions.create(feeding_params)
    redirect_to @baby
  end

  def destroy
    @baby.feeding_sessions.find(params[:id]).destroy
    redirect_to @baby
  end

  private
    def set_baby
      @baby = Current.household.baby_profiles.find(params[:baby_profile_id])
    end

    def feeding_params
      params.require(:feeding_session).permit(:kind, :started_at, :ended_at)
    end
end
