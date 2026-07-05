require "test_helper"

class EventReminderTest < ActiveSupport::TestCase
  test "requires a positive minutes_before" do
    reminder = EventReminder.new(calendar_event: calendar_events(:alpha_meeting), user: users(:one), minutes_before: 0)
    assert_not reminder.valid?
  end

  test "delegates household to calendar_event" do
    reminder = EventReminder.new(calendar_event: calendar_events(:alpha_meeting))
    assert_equal households(:alpha), reminder.household
  end
end
