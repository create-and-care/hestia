require "test_helper"

module Calendar
  module ExternalSync
    class ImporterTest < ActiveSupport::TestCase
      setup do
        @connection = ExternalCalendarConnection.create!(user: users(:one), provider: "google", access_token: "at")
      end

      test "creates a CalendarEvent per normalized event, scoped to the user's household" do
        events = [
          { uid: "evt1", title: "Standup", starts_at: 1.day.from_now, ends_at: 1.day.from_now + 30.minutes, all_day: false, location: "Room A" }
        ]

        assert_difference -> { CalendarEvent.count }, 1 do
          Importer.call(@connection, events)
        end

        event = @connection.calendar_events.sole
        assert_equal "Standup", event.title
        assert_equal households(:alpha), event.household
        assert_equal "evt1", event.external_uid
      end

      test "re-importing the same uid updates the existing event instead of duplicating it" do
        Importer.call(@connection, [ { uid: "evt1", title: "Standup", starts_at: 1.day.from_now, all_day: false } ])

        assert_no_difference -> { CalendarEvent.count } do
          Importer.call(@connection, [ { uid: "evt1", title: "Standup (renamed)", starts_at: 1.day.from_now, all_day: false } ])
        end

        assert_equal "Standup (renamed)", @connection.calendar_events.sole.title
      end

      test "skips events with no start time" do
        assert_no_difference -> { CalendarEvent.count } do
          Importer.call(@connection, [ { uid: "evt1", title: "Broken", starts_at: nil } ])
        end
      end
    end
  end
end
