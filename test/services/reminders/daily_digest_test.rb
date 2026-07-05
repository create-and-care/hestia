require "test_helper"

module Reminders
  class DailyDigestTest < ActiveSupport::TestCase
    test "notifies household members of fridge items expiring within their threshold" do
      # alpha_yogurt expires in 2 days (fixture), default threshold is 2 days.
      assert_difference "users(:one).notifications.where(kind: 'fridge_expiry').count", 1 do
        Reminders::DailyDigest.call
      end
    end

    test "does not notify twice the same day" do
      Reminders::DailyDigest.call

      assert_no_difference "users(:one).notifications.where(kind: 'fridge_expiry').count" do
        Reminders::DailyDigest.call
      end
    end

    test "respects a disabled fridge notification preference" do
      NotificationPreference.create!(user: users(:one), fridge_expiry_enabled: false)

      assert_no_difference "users(:one).notifications.where(kind: 'fridge_expiry').count" do
        Reminders::DailyDigest.call
      end
    end

    test "notifies household members of a birthday today" do
      contacts(:alpha_mom).update!(born_on: Date.current.change(year: 1960))

      assert_difference "users(:one).notifications.where(kind: 'birthday').count", 1 do
        Reminders::DailyDigest.call
      end
    end
  end
end
