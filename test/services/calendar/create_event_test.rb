require "test_helper"

module Calendar
  class CreateEventTest < ActiveSupport::TestCase
    test "creates an event with its participants" do
      event = Calendar::CreateEvent.call(
        household: households(:alpha),
        attributes: { title: "Repas", starts_at: Time.current, frequency: "none", color: "blue" },
        participant_ids: [ users(:one).id ]
      )
      assert event.persisted?
      assert_equal [ users(:one) ], event.participants.to_a
    end

    test "ignores participant ids outside the household" do
      event = Calendar::CreateEvent.call(
        household: households(:alpha),
        attributes: { title: "X", starts_at: Time.current, frequency: "none", color: "blue" },
        participant_ids: [ users(:two).id ]
      )
      assert_empty event.participants
    end
  end
end
