class CircleMembershipsController < ApplicationController
  before_action :set_circle_and_membership, only: %i[update destroy]

  def new
  end

  # Join a circle via its invite code (beyond the household).
  def create
    circle = Circle.find_by(invite_code: params[:invite_code].to_s.strip.upcase)

    if circle.nil?
      flash.now[:alert] = t(".invalid_code")
      render :new, status: :unprocessable_entity
    elsif circle.members.include?(Current.user)
      redirect_to circle, notice: t(".already_member")
    else
      circle.circle_memberships.create!(user: Current.user, role: "member")
      redirect_to circle, notice: t(".joined", name: circle.name)
    end
  end

  # Change a member's role (admin only, never on yourself — use the danger
  # zone / leave flow for that).
  def update
    return redirect_to @circle, alert: t("circles.not_admin") unless @circle.admin?(Current.user)

    role = params[:role].to_s
    return redirect_to edit_circle_path(@circle) unless CircleMembership::ROLES.include?(role)

    if role == "member" && @circle.only_admin?(@membership.user)
      redirect_to edit_circle_path(@circle), alert: t(".last_admin")
    else
      @membership.update(role: role)
      redirect_to edit_circle_path(@circle)
    end
  end

  # Leave a circle (member removes themself) or, if the current user is an
  # admin, remove another member.
  def destroy
    leaving = @membership.user_id == Current.user.id
    return redirect_to @circle, alert: t("circles.not_admin") unless leaving || @circle.admin?(Current.user)

    if @circle.only_admin?(@membership.user)
      redirect_to (leaving ? circle_path(@circle) : edit_circle_path(@circle)), alert: t(".last_admin")
      return
    end

    @membership.destroy
    redirect_to (leaving ? circles_path : edit_circle_path(@circle)), notice: leaving ? t(".left") : t(".removed")
  end

  private
    def set_circle_and_membership
      @circle = Current.user.circles.find(params[:circle_id])
      @membership = @circle.circle_memberships.find(params[:id])
    end
end
