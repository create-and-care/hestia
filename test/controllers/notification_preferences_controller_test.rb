require "test_helper"

class NotificationPreferencesControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as(users(:one)) }

  test "show requires authentication" do
    sign_out
    get notification_preference_path
    assert_redirected_to new_session_path
  end

  test "show builds a default preference when none exists yet" do
    get notification_preference_path
    assert_response :success
  end

  test "update persists the preferences" do
    patch notification_preference_path, params: {
      notification_preference: { fridge_expiry_enabled: false, fridge_expiry_threshold_days: 5, birthday_notifications_enabled: false }
    }
    assert_redirected_to notification_preference_path

    preference = users(:one).notification_preference.reload
    assert_not preference.fridge_expiry_enabled
    assert_equal 5, preference.fridge_expiry_threshold_days
    assert_not preference.birthday_notifications_enabled
  end

  test "update rejects an invalid threshold" do
    patch notification_preference_path, params: {
      notification_preference: { fridge_expiry_threshold_days: -1 }
    }
    assert_response :unprocessable_entity
  end
end
