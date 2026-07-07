require "test_helper"

class NotificationPreferencesControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as(users(:one)) }

  test "update requires authentication" do
    sign_out
    patch notification_preference_path, params: { notification_preference: { fridge_expiry_enabled: false } }
    assert_redirected_to new_session_path
  end

  test "update persists the preferences and redirects to household settings" do
    patch notification_preference_path, params: {
      notification_preference: { fridge_expiry_enabled: false, fridge_expiry_threshold_days: 5, birthday_notifications_enabled: false }
    }
    assert_redirected_to household_path(households(:alpha))

    preference = users(:one).notification_preference.reload
    assert_not preference.fridge_expiry_enabled
    assert_equal 5, preference.fridge_expiry_threshold_days
    assert_not preference.birthday_notifications_enabled
  end

  test "update rejects an invalid threshold" do
    patch notification_preference_path, params: {
      notification_preference: { fridge_expiry_threshold_days: -1 }
    }
    assert_redirected_to household_path(households(:alpha))
    assert_not_equal(-1, NotificationPreference.for_user(users(:one)).fridge_expiry_threshold_days)
  end
end
