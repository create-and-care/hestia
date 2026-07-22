# A user's recurring notification preferences (Fridge expiration,
# birthdays). Distinct from one-off reminders
# (TaskReminder/EventReminder) which are created case by case on a specific record.
class NotificationPreference < ApplicationRecord
  belongs_to :user

  validates :user_id, uniqueness: true
  validates :fridge_expiry_threshold_days, numericality: { greater_than_or_equal_to: 0 }
  validates :plant_care_threshold_days, numericality: { greater_than_or_equal_to: 0 }

  def self.for_user(user)
    user.notification_preference || user.build_notification_preference
  end
end
