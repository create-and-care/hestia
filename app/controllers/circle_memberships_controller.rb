class CircleMembershipsController < ApplicationController
  def new
  end

  # Join a circle via its invite code (beyond the household).
  def create
    circle = Circle.find_by(invite_code: params[:invite_code].to_s.strip.upcase)

    if circle.nil?
      flash.now[:alert] = "Code d'invitation invalide."
      render :new, status: :unprocessable_entity
    elsif circle.members.include?(Current.user)
      redirect_to circle, notice: "Vous faites déjà partie de ce cercle."
    else
      circle.circle_memberships.create!(user: Current.user, role: "member")
      redirect_to circle, notice: "Vous avez rejoint « #{circle.name} »."
    end
  end
end
