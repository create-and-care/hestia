class MembershipsController < ApplicationController
  allow_without_household only: %i[new create]
  before_action :set_membership, only: %i[update destroy]

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

  # Change a member's role (admin only, never on yourself — use #destroy to leave).
  def update
    return redirect_to household_path(Current.household), alert: t(".not_authorized") unless current_membership&.admin?

    role = params[:role].to_s
    return redirect_to household_path(Current.household) unless Membership::ROLES.include?(role)

    if role == "member" && Current.household.only_admin?(@membership.user)
      redirect_to household_path(Current.household), alert: t(".last_admin")
    else
      @membership.update(role: role)
      redirect_to household_path(Current.household)
    end
  end

  # Leave the household (member removes themself) or, if the current user is
  # an admin, remove another member.
  def destroy
    leaving = @membership.user_id == Current.user.id
    unless leaving || current_membership&.admin?
      return redirect_to household_path(Current.household), alert: t(".not_authorized")
    end

    if Current.household.only_admin?(@membership.user)
      redirect_to household_path(Current.household), alert: t(".last_admin")
      return
    end

    household = Current.household
    @membership.destroy

    if leaving
      Session.where(user: Current.user, active_household: household).update_all(active_household_id: nil)
      next_household = Current.user.households.reload.first
      next_household ? switch_household(next_household) : (Current.household = nil)
      redirect_to(next_household ? root_path : onboarding_path, notice: t(".left"))
    else
      redirect_to household_path(household), notice: t(".removed")
    end
  end

  private
    def set_membership
      @membership = Current.household.memberships.find(params[:id])
    end

    def normalized_invite_code
      params[:invite_code].to_s.strip.upcase
    end
end
