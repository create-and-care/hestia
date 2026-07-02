class WellbeingProfilesController < ApplicationController
  def update
    profile = Current.user.wellbeing_profile || Current.user.build_wellbeing_profile
    profile.update(profile_params)
    redirect_to wellbeing_path, notice: "Profil mis à jour."
  end

  private
    def profile_params
      params.require(:wellbeing_profile).permit(:height, :age, :sex, :activity_level, :start_weight, :goal_weight)
    end
end
