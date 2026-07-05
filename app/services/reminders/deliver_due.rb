# Livre les rappels ponctuels arrivés à échéance (CDC §9.2, §9.3) sous forme de
# Notification in-app temps réel. Appelé périodiquement par Reminders::DeliverDueJob
# (cf. config/recurring.yml).
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
            title: "Rappel : #{task.title}",
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
            title: "Rappel : #{event.title}",
            body: I18n.l(occurrence, format: :long),
            notifiable: event
          )
          reminder.update!(last_notified_occurrence_at: occurrence)
        end
      end

      # Prochaine occurrence de l'événement dont l'heure de rappel (occurrence -
      # délai configuré) est atteinte, et qui n'a pas déjà été notifiée.
      def next_occurrence_to_notify(event, reminder)
        window_end = Time.current + LOOKAHEAD + reminder.minutes_before.minutes
        event.occurrences_between(Time.current, window_end).find do |occurrence|
          not_yet_notified = reminder.last_notified_occurrence_at.nil? || occurrence > reminder.last_notified_occurrence_at
          due = occurrence - reminder.minutes_before.minutes <= Time.current
          not_yet_notified && due
        end
      end
  end
end
