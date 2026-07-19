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

  test "create links an address from the household's address book" do
    post calendar_events_path, params: {
      calendar_event: { title: "Dîner", starts_at: 1.day.from_now.change(min: 0), frequency: "none", color: "blue",
                         address_id: addresses(:alpha_resto).id }
    }
    assert_equal addresses(:alpha_resto), CalendarEvent.find_by!(title: "Dîner").address
  end

  test "the event form offers the household's addresses" do
    get new_calendar_event_path
    assert_select "select#calendar_event_address_id option", text: addresses(:alpha_resto).name
    assert_select "select#calendar_event_address_id option", text: addresses(:beta_place).name, count: 0
  end

  test "an event with a linked address shows a directions link in the agenda view" do
    calendar_events(:alpha_meeting).update!(address: addresses(:alpha_resto))
    get calendar_path(view: "list")
    assert_select "a[href=?]", addresses(:alpha_resto).maps_url, text: addresses(:alpha_resto).name
  end

  test "new prefills starts_at when given (clicking a day in the grid)" do
    get new_calendar_event_path(starts_at: "2026-08-15T09:00:00")
    assert_response :success
    assert_select "input#calendar_event_starts_at[value=?]", "2026-08-15T09:00"
  end

  test "editing this occurrence only detaches it without touching the series" do
    series = households(:alpha).calendar_events.create!(
      title: "Yoga", starts_at: Time.zone.parse("2026-08-03 09:00"), frequency: "weekly", recurrence_interval: 1
    )
    third_occurrence = Time.zone.parse("2026-08-17 09:00")

    patch calendar_event_path(series), params: {
      calendar_event: { title: "Yoga (remplacement)", starts_at: third_occurrence, frequency: "none" },
      scope: "occurrence", occurrence: third_occurrence.iso8601
    }

    assert_redirected_to calendar_path
    assert_equal "Yoga", series.reload.title
    assert_includes series.excluded_occurrences, third_occurrence.to_date
    standalone = households(:alpha).calendar_events.find_by(title: "Yoga (remplacement)")
    assert standalone
    assert_equal "none", standalone.frequency
  end

  test "editing the whole series updates the original event and keeps recurring" do
    series = households(:alpha).calendar_events.create!(
      title: "Yoga", starts_at: Time.zone.parse("2026-08-03 09:00"), frequency: "weekly", recurrence_interval: 1
    )

    patch calendar_event_path(series), params: {
      calendar_event: { title: "Yoga du matin", starts_at: series.starts_at, frequency: "weekly", recurrence_interval: 1 },
      scope: "series", occurrence: Time.zone.parse("2026-08-17 09:00").iso8601
    }

    assert_equal "Yoga du matin", series.reload.title
    assert series.recurring?
  end

  test "deleting a single occurrence excludes just that date from the series" do
    series = households(:alpha).calendar_events.create!(
      title: "Yoga", starts_at: Time.zone.parse("2026-08-03 09:00"), frequency: "weekly", recurrence_interval: 1
    )
    third_occurrence = Time.zone.parse("2026-08-17 09:00")

    assert_no_difference -> { CalendarEvent.count } do
      delete calendar_event_path(series), params: { scope: "occurrence", occurrence: third_occurrence.iso8601 }
    end
    assert_includes series.reload.excluded_occurrences, third_occurrence.to_date
    assert CalendarEvent.exists?(series.id)
  end

  test "deleting scope=series removes the whole recurring event" do
    series = households(:alpha).calendar_events.create!(
      title: "Yoga", starts_at: Time.zone.parse("2026-08-03 09:00"), frequency: "weekly", recurrence_interval: 1
    )

    delete calendar_event_path(series), params: { scope: "series" }
    assert_not CalendarEvent.exists?(series.id)
  end

  test "edit offers a discuss-this-event shortcut into Messages" do
    get edit_calendar_event_path(calendar_events(:alpha_meeting))
    assert_response :success
    assert_select "form[action^=?]", discuss_conversations_path
  end
end
