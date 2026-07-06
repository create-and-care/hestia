require "test_helper"

class EventRemindersControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as(users(:one)) }

  test "create adds a reminder for the current user" do
    event = calendar_events(:alpha_meeting)
    assert_difference -> { event.event_reminders.count }, 1 do
      post calendar_event_event_reminders_path(event), params: { event_reminder: { minutes_before: 60 } }
    end
    assert_redirected_to edit_calendar_event_path(event)
    assert_equal users(:one), event.event_reminders.last.user
  end

  test "ignores a user_id from another household and falls back to the current user" do
    event = calendar_events(:alpha_meeting)
    post calendar_event_event_reminders_path(event), params: { event_reminder: { minutes_before: 30, user_id: users(:two).id } }
    assert_equal users(:one), event.event_reminders.last.user
  end

  test "destroy removes a reminder" do
    event = calendar_events(:alpha_meeting)
    reminder = event.event_reminders.create!(minutes_before: 30, user: users(:one))
    assert_difference -> { event.event_reminders.count }, -1 do
      delete calendar_event_event_reminder_path(event, reminder)
    end
    assert_redirected_to edit_calendar_event_path(event)
  end

  test "cannot create a reminder on another household's event" do
    event = calendar_events(:beta_event)
    assert_no_difference -> { EventReminder.count } do
      post calendar_event_event_reminders_path(event), params: { event_reminder: { minutes_before: 30 } }
    end
    assert_response :not_found
  end

  test "cannot destroy a reminder on another household's event" do
    event = calendar_events(:beta_event)
    reminder = event.event_reminders.create!(minutes_before: 30, user: users(:two))
    delete calendar_event_event_reminder_path(event, reminder)
    assert_response :not_found
  end
end
