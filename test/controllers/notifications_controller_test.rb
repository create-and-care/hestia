require "test_helper"

class NotificationsControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as(users(:one)) }

  test "index requires authentication" do
    sign_out
    get notifications_path
    assert_redirected_to new_session_path
  end

  test "index shows only the current user's notifications" do
    mine = Notification.create!(user: users(:one), household: households(:alpha), kind: "birthday", title: "Mine")
    other = Notification.create!(user: users(:two), household: households(:beta), kind: "birthday", title: "Other")

    get notifications_path
    assert_response :success
    assert_includes @response.body, mine.title
    assert_not_includes @response.body, other.title
  end

  test "the preferences button opens the notifications tab of the household settings" do
    get notifications_path
    assert_response :success
    assert_select "a[href=?]", household_path(households(:alpha), tab: "notifications")
  end

  test "mark_read marks a single notification as read" do
    notification = Notification.create!(user: users(:one), household: households(:alpha), kind: "birthday", title: "Mine")
    patch mark_read_notification_path(notification)
    assert_redirected_to notifications_path
    assert notification.reload.read?
  end

  test "cannot mark another user's notification as read" do
    other = Notification.create!(user: users(:two), household: households(:beta), kind: "birthday", title: "Other")
    patch mark_read_notification_path(other)
    assert_response :not_found
    assert_not other.reload.read?
  end

  test "a task reminder links to its task" do
    task = tasks(:alpha_dishes)
    Notification.create!(user: users(:one), household: households(:alpha), kind: "task_reminder", title: "Reminder", notifiable: task)

    get notifications_path
    assert_response :success
    assert_select "a[href=?]", edit_task_path(task)
  end

  test "an event reminder links to its calendar event" do
    event = calendar_events(:alpha_meeting)
    Notification.create!(user: users(:one), household: households(:alpha), kind: "event_reminder", title: "Reminder", notifiable: event)

    get notifications_path
    assert_response :success
    assert_select "a[href=?]", edit_calendar_event_path(event)
  end

  test "a fridge expiry digest links to the fridge" do
    Notification.create!(user: users(:one), household: households(:alpha), kind: "fridge_expiry", title: "Fridge digest")

    get notifications_path
    assert_response :success
    assert_select "a[href=?]", fridge_path
  end

  test "a birthday digest links to contacts" do
    Notification.create!(user: users(:one), household: households(:alpha), kind: "birthday", title: "Birthday digest")

    get notifications_path
    assert_response :success
    assert_select "a[href=?]", contacts_path
  end

  test "a sync failure notice links to external calendar connections" do
    Notification.create!(user: users(:one), household: households(:alpha), kind: "external_calendar_sync_failed", title: "Sync failed")

    get notifications_path
    assert_response :success
    assert_select "a[href=?]", external_calendar_connections_path
  end

  test "does not show the originating household for a single-household user" do
    notification = Notification.create!(user: users(:one), household: households(:alpha), kind: "birthday", title: "Birthday digest")

    get notifications_path
    assert_response :success
    node = css_select("##{dom_id(notification)}").first
    assert_not_includes node.text, households(:alpha).name
  end

  test "shows the originating household for a multi-household user" do
    households(:beta).memberships.create!(user: users(:one), role: "member")
    notification = Notification.create!(user: users(:one), household: households(:alpha), kind: "birthday", title: "Birthday digest")

    get notifications_path
    assert_response :success
    assert_select "##{dom_id(notification)}", text: /#{Regexp.escape(households(:alpha).name)}/
  end

  test "mark_all_read marks every unread notification of the current user as read" do
    a = Notification.create!(user: users(:one), household: households(:alpha), kind: "birthday", title: "A")
    b = Notification.create!(user: users(:one), household: households(:alpha), kind: "birthday", title: "B")

    patch mark_all_read_notifications_path
    assert_redirected_to notifications_path
    assert a.reload.read?
    assert b.reload.read?
  end

  test "mark_read responds with a turbo stream that updates the notification and badge in place, without redirecting" do
    notification = Notification.create!(user: users(:one), household: households(:alpha), kind: "birthday", title: "Mine")

    patch mark_read_notification_path(notification), as: :turbo_stream
    assert_response :success
    assert_turbo_stream action: "replace", target: dom_id(notification)
    assert_turbo_stream action: "replace", target: "notifications_badge"
  end

  test "mark_all_read responds with a turbo stream that updates every notification and the badge in place" do
    a = Notification.create!(user: users(:one), household: households(:alpha), kind: "birthday", title: "A")
    b = Notification.create!(user: users(:one), household: households(:alpha), kind: "birthday", title: "B")

    patch mark_all_read_notifications_path, as: :turbo_stream
    assert_response :success
    assert_turbo_stream action: "replace", target: dom_id(a)
    assert_turbo_stream action: "replace", target: dom_id(b)
    assert_turbo_stream action: "replace", target: "notifications_badge"
  end

  test "index subscribes to the user's notifications turbo stream" do
    get notifications_path
    assert_response :success
    assert_select "turbo-cable-stream-source"
  end
end
