class NotificationPreferencesController < ApplicationController
  def update
    preference = NotificationPreference.for_user(Current.user)

    # Back to the tab the form was submitted from: the settings tabs are
    # client-side, so a bare redirect reopens "general" and the save reads as
    # having been lost.
    if preference.update(preference_params)
      redirect_to household_path(Current.household, tab: "notifications"), notice: t(".updated")
    else
      redirect_to household_path(Current.household, tab: "notifications"), alert: t(".failed")
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
