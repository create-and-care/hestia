class RegistrationsController < ApplicationController
  allow_unauthenticated_access
  allow_without_household

  def new
    @user = User.new
  end

  def create
    @user = User.new(registration_params)

    if @user.save
      start_new_session_for @user
      redirect_to onboarding_path, notice: t(".welcome")
    else
      render :new, status: :unprocessable_entity
    end
  end

  private
    def registration_params
      params.require(:user).permit(:name, :email_address, :password, :password_confirmation)
    end
end
