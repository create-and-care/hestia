# Préférences de notifications récurrentes d'un utilisateur (péremption Frigo,
# anniversaires) — CDC §9.4 et §10.2. Distinct des rappels ponctuels
# (TaskReminder/EventReminder) qui sont créés au cas par cas sur un enregistrement précis.
class NotificationPreference < ApplicationRecord
  belongs_to :user

  validates :user_id, uniqueness: true
  validates :fridge_expiry_threshold_days, numericality: { greater_than_or_equal_to: 0 }

  def self.for_user(user)
    user.notification_preference || user.build_notification_preference
  end
end
