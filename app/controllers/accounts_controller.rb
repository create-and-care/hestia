class AccountsController < ApplicationController
  def edit
    @user = Current.user
    @profile = Current.user.wellbeing_profile || Current.user.build_wellbeing_profile
  end

  def update
    @user = Current.user
    @profile = Current.user.wellbeing_profile || Current.user.build_wellbeing_profile

    unless @user.authenticate(params.dig(:user, :current_password).to_s)
      @user.errors.add(:base, t(".current_password_invalid"))
      return render :edit, status: :unprocessable_entity
    end

    attrs = account_params
    attrs = attrs.except(:password, :password_confirmation) if attrs[:password].blank?

    if @user.update(attrs)
      redirect_to household_path(Current.household, tab: "members"), notice: t(".updated")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private
    def account_params
      params.require(:user).permit(:name, :email_address, :password, :password_confirmation)
    end
end
