# Delivers one-off reminders that have come due as
# real-time in-app Notifications. Called periodically by Reminders::DeliverDueJob
# (see config/recurring.yml).
module Reminders
  class DeliverDue
    LOOKAHEAD = 1.day

    def self.call = new.call

    def call
      deliver_task_reminders
      deliver_event_reminders
    end

    private
      def deliver_task_reminders
        TaskReminder.due.includes(:task, :user).find_each do |reminder|
          task = reminder.task
          Notification.create!(
            user: reminder.user,
            household: task.household,
            kind: "task_reminder",
            title: I18n.t("reminders.task_reminder.title", title: task.title),
            body: task.description,
            notifiable: task
          )
          reminder.update!(delivered_at: Time.current)
        end
      end

      def deliver_event_reminders
        EventReminder.includes(:calendar_event, :user).find_each do |reminder|
          event = reminder.calendar_event
          occurrence = next_occurrence_to_notify(event, reminder)
          next unless occurrence

          Notification.create!(
            user: reminder.user,
            household: event.household,
            kind: "event_reminder",
            title: I18n.t("reminders.event_reminder.title", title: event.title),
            body: I18n.l(occurrence, format: :long),
            notifiable: event
          )
          reminder.update!(last_notified_occurrence_at: occurrence)
        end
      end

      # Next occurrence of the event whose reminder time (occurrence -
      # configured delay) has been reached, and that has not already been notified.
      def next_occurrence_to_notify(event, reminder)
        window_start = Time.current - reminder.minutes_before.minutes
        window_end = Time.current + LOOKAHEAD + reminder.minutes_before.minutes

        event.occurrences_between(window_start, window_end).find do |occurrence|
          not_yet_notified =
            reminder.last_notified_occurrence_at.nil? ||
            occurrence > reminder.last_notified_occurrence_at

          due = occurrence - reminder.minutes_before.minutes <= Time.current

          not_yet_notified && due
        end
      end
  end
end
