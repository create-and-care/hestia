require "test_helper"

class NotificationTest < ActiveSupport::TestCase
  test "requires a known kind" do
    notification = Notification.new(user: users(:one), household: households(:alpha), title: "Test", kind: "unknown")
    assert_not notification.valid?
  end

  test "unread scope excludes read notifications" do
    unread = Notification.create!(user: users(:one), household: households(:alpha), kind: "birthday", title: "A")
    read = Notification.create!(user: users(:one), household: households(:alpha), kind: "birthday", title: "B", read_at: Time.current)

    assert_includes Notification.unread, unread
    assert_not_includes Notification.unread, read
  end

  test "mark_read! sets read_at once" do
    notification = Notification.create!(user: users(:one), household: households(:alpha), kind: "birthday", title: "A")
    assert_not notification.read?

    notification.mark_read!
    assert notification.read?
  end

  test "block_key groups a single-module kind under that module" do
    notification = Notification.create!(user: users(:one), household: households(:alpha), kind: "birthday", title: "A")
    assert_equal "birthdays", notification.block_key
  end

  test "block_key falls back to global for a kind with no mapped module" do
    notification = Notification.new(user: users(:one), household: households(:alpha), kind: "birthday", title: "A")
    notification.define_singleton_method(:module_keys) { [] }
    assert_equal "global", notification.block_key
  end

  test "block_key falls back to global for a kind mapped to several modules" do
    notification = Notification.new(user: users(:one), household: households(:alpha), kind: "birthday", title: "A")
    notification.define_singleton_method(:module_keys) { %w[birthdays gifts] }
    assert_equal "global", notification.block_key
  end
end
