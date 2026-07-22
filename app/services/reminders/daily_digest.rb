# Recurring daily notifications: Fridge products soon to
# expire, today's birthdays. A single Notification per user and per day and
# per type, to avoid noise in case of re-execution. Called once a day by
# Reminders::DailyDigestJob (see config/recurring.yml).
module Reminders
  class DailyDigest
    def self.call = new.call

    def call
      Household.find_each do |household|
        household.in_time_zone do
          household.users.find_each do |user|
            preference = user.notification_preference || NotificationPreference.new
            notify_fridge_expiry(household, user, preference) if preference.fridge_expiry_enabled
            notify_birthdays(household, user) if preference.birthday_notifications_enabled
            notify_plant_care(household, user, preference) if preference.plant_care_enabled
          end
        end
      end
    end

    private
      def notify_fridge_expiry(household, user, preference)
        return if already_notified_today?(user, "fridge_expiry")

        threshold = preference.fridge_expiry_threshold_days
        range = Date.current..(Date.current + threshold.days)
        items = household.fridge_items.where(expires_on: range).order(:expires_on).to_a
        dishes = household.prepared_dishes.where(expires_on: range).order(:expires_on).to_a
        return if items.empty? && dishes.empty?

        Notification.create!(
          user: user, household: household, kind: "fridge_expiry",
          title: I18n.t("reminders.daily_digest.fridge_expiry", count: items.size + dishes.size),
          body: (items + dishes).sort_by(&:expires_on).map(&:name).join(", ")
        )
      end

      def notify_birthdays(household, user)
        return if already_notified_today?(user, "birthday")

        contacts = household.contacts.select { |contact| contact.days_until_birthday&.zero? }
        return if contacts.empty?

        Notification.create!(
          user: user, household: household, kind: "birthday",
          title: I18n.t("reminders.daily_digest.birthday", count: contacts.size),
          body: contacts.map(&:name).join(", ")
        )
      end

      def notify_plant_care(household, user, preference)
        return if already_notified_today?(user, "plant_care_due")

        threshold = preference.plant_care_threshold_days
        tasks = PlantCareTask.joins(:plant).where(plants: { household_id: household.id })
                              .where("next_due_on <= ?", Date.current + threshold.days)
                              .order(:next_due_on).includes(:plant).to_a
        return if tasks.empty?

        Notification.create!(
          user: user, household: household, kind: "plant_care_due",
          title: I18n.t("reminders.daily_digest.plant_care_due", count: tasks.size),
          body: tasks.map { |task| "#{task.plant.name} (#{I18n.t("plant_care_tasks.types.#{task.care_type}", default: task.care_type.humanize)})" }.join(", ")
        )
      end

      def already_notified_today?(user, kind)
        user.notifications.where(kind: kind, created_at: Date.current.all_day).exists?
      end
  end
end
