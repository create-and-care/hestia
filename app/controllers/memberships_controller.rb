class MembershipsController < ApplicationController
  allow_without_household only: %i[new create]

  def new
  end

  # Rejoindre un foyer existant via son code d'invitation.
  def create
    household = Household.find_by(invite_code: normalized_invite_code)

    if household.nil?
      flash.now[:alert] = "Code d'invitation invalide."
      render :new, status: :unprocessable_entity
    elsif Current.user.households.include?(household)
      switch_household(household)
      redirect_to root_path, notice: "Vous faites déjà partie de ce foyer."
    else
      household.memberships.create!(user: Current.user, role: :member)
      switch_household(household)
      redirect_to root_path, notice: "Vous avez rejoint « #{household.name} »."
    end
  end

  private
    def normalized_invite_code
      params[:invite_code].to_s.strip.upcase
    end
end
