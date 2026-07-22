require "test_helper"

module Reminders
  class DailyDigestTest < ActiveSupport::TestCase
    test "notifies household members of fridge items expiring within their threshold" do
      # alpha_yogurt expires in 2 days (fixture), default threshold is 2 days.
      assert_difference "users(:one).notifications.where(kind: 'fridge_expiry').count", 1 do
        Reminders::DailyDigest.call
      end
    end

    test "includes prepared dishes expiring within the threshold, not just fridge items" do
      households(:alpha).fridge_items.destroy_all # isolate: only alpha_lasagna (prepared dish) expiring soon

      assert_difference "users(:one).notifications.where(kind: 'fridge_expiry').count", 1 do
        Reminders::DailyDigest.call
      end
      assert_includes users(:one).notifications.where(kind: "fridge_expiry").last.body, "Lasagnes"
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

    test "notifies household members of plant care due within their threshold" do
      # alpha_rose_watering_overdue (fixture) is already overdue, well within any threshold.
      assert_difference "users(:one).notifications.where(kind: 'plant_care_due').count", 1 do
        Reminders::DailyDigest.call
      end
      assert_includes users(:one).notifications.where(kind: "plant_care_due").last.body, "Rosier"
    end

    test "does not notify about plant care beyond the threshold" do
      PlantCareTask.destroy_all
      plants(:alpha_rose).plant_care_tasks.create!(care_type: "watering", frequency: "monthly", next_due_on: 30.days.from_now.to_date)

      assert_no_difference "users(:one).notifications.where(kind: 'plant_care_due').count" do
        Reminders::DailyDigest.call
      end
    end

    test "respects a disabled plant care notification preference" do
      NotificationPreference.create!(user: users(:one), plant_care_enabled: false)

      assert_no_difference "users(:one).notifications.where(kind: 'plant_care_due').count" do
        Reminders::DailyDigest.call
      end
    end
  end
end
