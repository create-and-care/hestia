require "test_helper"

class TaskReminderTest < ActiveSupport::TestCase
  test "requires remind_at" do
    reminder = TaskReminder.new(task: tasks(:alpha_dishes), user: users(:one))
    assert_not reminder.valid?
  end

  test "due scope returns only undelivered reminders in the past" do
    due = TaskReminder.create!(task: tasks(:alpha_dishes), user: users(:one), remind_at: 1.hour.ago)
    future = TaskReminder.create!(task: tasks(:alpha_dishes), user: users(:one), remind_at: 1.hour.from_now)
    delivered = TaskReminder.create!(task: tasks(:alpha_dishes), user: users(:one), remind_at: 1.hour.ago, delivered_at: Time.current)

    assert_includes TaskReminder.due, due
    assert_not_includes TaskReminder.due, future
    assert_not_includes TaskReminder.due, delivered
  end

  test "delegates household to task" do
    reminder = TaskReminder.new(task: tasks(:alpha_dishes))
    assert_equal households(:alpha), reminder.household
  end
end
