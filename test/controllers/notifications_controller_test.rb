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

  test "mark_all_read marks every unread notification of the current user as read" do
    a = Notification.create!(user: users(:one), household: households(:alpha), kind: "birthday", title: "A")
    b = Notification.create!(user: users(:one), household: households(:alpha), kind: "birthday", title: "B")

    patch mark_all_read_notifications_path
    assert_redirected_to notifications_path
    assert a.reload.read?
    assert b.reload.read?
  end
end
