class NotificationPreferencesController < ApplicationController
  def update
    preference = NotificationPreference.for_user(Current.user)

    if preference.update(preference_params)
      redirect_to household_path(Current.household), notice: t(".updated")
    else
      redirect_to household_path(Current.household), alert: t(".failed")
    end
  end

  private
    def preference_params
      params.require(:notification_preference).permit(
        :fridge_expiry_enabled, :fridge_expiry_threshold_days, :birthday_notifications_enabled,
        :plant_care_enabled, :plant_care_threshold_days
      )
    end
end
