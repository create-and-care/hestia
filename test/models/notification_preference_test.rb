require "test_helper"

class NotificationPreferenceTest < ActiveSupport::TestCase
  test "defaults enable fridge and birthday notifications" do
    preference = NotificationPreference.create!(user: users(:one))
    assert preference.fridge_expiry_enabled
    assert preference.birthday_notifications_enabled
    assert_equal 2, preference.fridge_expiry_threshold_days
  end

  test "one preference per user" do
    NotificationPreference.create!(user: users(:one))
    duplicate = NotificationPreference.new(user: users(:one))
    assert_not duplicate.valid?
  end

  test "for_user builds an unsaved default preference when none exists" do
    preference = NotificationPreference.for_user(users(:two))
    assert_not preference.persisted?
    assert preference.fridge_expiry_enabled
  end
end
