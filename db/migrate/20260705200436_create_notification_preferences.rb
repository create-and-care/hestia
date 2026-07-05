class CreateNotificationPreferences < ActiveRecord::Migration[8.1]
  def change
    create_table :notification_preferences do |t|
      t.references :user, null: false, foreign_key: true, index: { unique: true }
      t.boolean :fridge_expiry_enabled, null: false, default: true
      t.integer :fridge_expiry_threshold_days, null: false, default: 2
      t.boolean :birthday_notifications_enabled, null: false, default: true

      t.timestamps
    end
  end
end
