require "test_helper"

class CalendarEventsControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as(users(:one)) }

  test "new" do
    get new_calendar_event_path
    assert_response :success
  end

  test "create with participants" do
    assert_difference -> { households(:alpha).calendar_events.count }, 1 do
      post calendar_events_path, params: {
        calendar_event: { title: "Repas", starts_at: 1.day.from_now.change(min: 0), frequency: "none", color: "blue" },
        participant_ids: [ users(:one).id ]
      }
    end
    assert_redirected_to calendar_path
    event = CalendarEvent.find_by!(title: "Repas")
    assert_equal [ users(:one) ], event.participants.to_a
  end

  test "create with invalid data re-renders" do
    assert_no_difference -> { CalendarEvent.count } do
      post calendar_events_path, params: { calendar_event: { title: "", starts_at: "", frequency: "none" } }
    end
    assert_response :unprocessable_entity
  end

  test "update" do
    event = calendar_events(:alpha_meeting)
    patch calendar_event_path(event), params: {
      calendar_event: { title: "Réunion importante", starts_at: event.starts_at, frequency: "none", color: "red" }
    }
    assert_redirected_to calendar_path
    assert_equal "Réunion importante", event.reload.title
  end

  test "destroy" do
    event = calendar_events(:alpha_meeting)
    delete calendar_event_path(event)
    assert_redirected_to calendar_path
    assert_not CalendarEvent.exists?(event.id)
  end

  test "cannot touch another household's event" do
    get edit_calendar_event_path(calendar_events(:beta_event))
    assert_response :not_found
  end
end
