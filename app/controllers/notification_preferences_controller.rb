class NotificationPreferencesController < ApplicationController
  def show
    @preference = NotificationPreference.for_user(Current.user)
  end

  def update
    preference = NotificationPreference.for_user(Current.user)
    preference.assign_attributes(preference_params)

    if preference.save
      redirect_to notification_preference_path, notice: "Préférences mises à jour."
    else
      @preference = preference
      render :show, status: :unprocessable_entity
    end
  end

  private
    def preference_params
      params.require(:notification_preference).permit(
        :fridge_expiry_enabled, :fridge_expiry_threshold_days, :birthday_notifications_enabled
      )
    end
end
