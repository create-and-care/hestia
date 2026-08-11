require "test_helper"

module Reminders
  class DeliverDueTest < ActiveSupport::TestCase
    test "delivers due task reminders as a notification and marks them delivered" do
      reminder = TaskReminder.create!(task: tasks(:alpha_dishes), user: users(:one), remind_at: 1.minute.ago)

      assert_difference "Notification.count", 1 do
        Reminders::DeliverDue.call
      end

      assert reminder.reload.delivered_at.present?
      notification = Notification.last
      assert_equal "task_reminder", notification.kind
      assert_equal users(:one), notification.user
      assert_equal tasks(:alpha_dishes), notification.notifiable
    end

    test "does not re-deliver an already delivered task reminder" do
      TaskReminder.create!(task: tasks(:alpha_dishes), user: users(:one), remind_at: 1.minute.ago, delivered_at: 1.minute.ago)

      assert_no_difference "Notification.count" do
        Reminders::DeliverDue.call
      end
    end

    test "does not deliver a task reminder scheduled in the future" do
      TaskReminder.create!(task: tasks(:alpha_dishes), user: users(:one), remind_at: 1.hour.from_now)

      assert_no_difference "Notification.count" do
        Reminders::DeliverDue.call
      end
    end

    test "delivers an event reminder once its delay before the occurrence is reached" do
      event = calendar_events(:alpha_meeting)
      minutes_until_occurrence = ((event.starts_at - Time.current) / 60).ceil
      reminder = EventReminder.create!(calendar_event: event, user: users(:one), minutes_before: minutes_until_occurrence + 60)

      assert_difference "Notification.count", 1 do
        Reminders::DeliverDue.call
      end

      assert_equal event.starts_at, reminder.reload.last_notified_occurrence_at
    end

    test "does not re-notify the same occurrence twice" do
      event = calendar_events(:alpha_meeting)
      EventReminder.create!(
        calendar_event: event, user: users(:one),
        minutes_before: 2.days.in_minutes.to_i + 60, last_notified_occurrence_at: event.starts_at
      )

      assert_no_difference "Notification.count" do
        Reminders::DeliverDue.call
      end
    end
  end
end
