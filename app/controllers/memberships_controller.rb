class MembershipsController < ApplicationController
  allow_without_household only: %i[new create]

  def new
  end

  # Join an existing household via its invite code.
  def create
    household = Household.find_by(invite_code: normalized_invite_code)

    if household.nil?
      flash.now[:alert] = t(".invalid_code")
      render :new, status: :unprocessable_entity
    elsif Current.user.households.include?(household)
      switch_household(household)
      redirect_to root_path, notice: t(".already_member")
    else
      household.memberships.create!(user: Current.user, role: :member)
      switch_household(household)
      redirect_to root_path, notice: t(".joined", name: household.name)
    end
  end

  private
    def normalized_invite_code
      params[:invite_code].to_s.strip.upcase
    end
end
