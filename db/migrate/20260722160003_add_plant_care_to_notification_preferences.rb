class AddPlantCareToNotificationPreferences < ActiveRecord::Migration[8.1]
  def change
    add_column :notification_preferences, :plant_care_enabled, :boolean, null: false, default: true
    add_column :notification_preferences, :plant_care_threshold_days, :integer, null: false, default: 2
  end
end
