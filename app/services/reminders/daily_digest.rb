# Notifications récurrentes quotidiennes (CDC §9.4, §10.2) : produits du Frigo
# bientôt périmés, anniversaires du jour. Une seule Notification par utilisateur et
# par jour et par type, pour éviter le bruit en cas de ré-exécution. Appelé une fois
# par jour par Reminders::DailyDigestJob (cf. config/recurring.yml).
module Reminders
  class DailyDigest
    def self.call = new.call

    def call
      Household.find_each do |household|
        household.users.find_each do |user|
          preference = user.notification_preference || NotificationPreference.new
          notify_fridge_expiry(household, user, preference) if preference.fridge_expiry_enabled
          notify_birthdays(household, user) if preference.birthday_notifications_enabled
        end
      end
    end

    private
      def notify_fridge_expiry(household, user, preference)
        return if already_notified_today?(user, "fridge_expiry")

        threshold = preference.fridge_expiry_threshold_days
        items = household.fridge_items.where(expires_on: Date.current..(Date.current + threshold.days))
        return if items.none?

        Notification.create!(
          user: user, household: household, kind: "fridge_expiry",
          title: "#{items.count} produit#{'s' if items.count > 1} bientôt périmé#{'s' if items.count > 1}",
          body: items.order(:expires_on).map(&:name).join(", ")
        )
      end

      def notify_birthdays(household, user)
        return if already_notified_today?(user, "birthday")

        contacts = household.contacts.select { |contact| contact.days_until_birthday&.zero? }
        return if contacts.empty?

        Notification.create!(
          user: user, household: household, kind: "birthday",
          title: contacts.one? ? "Anniversaire aujourd'hui 🎂" : "Anniversaires aujourd'hui 🎂",
          body: contacts.map(&:name).join(", ")
        )
      end

      def already_notified_today?(user, kind)
        user.notifications.where(kind: kind, created_at: Date.current.all_day).exists?
      end
  end
end
