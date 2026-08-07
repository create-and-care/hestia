require "test_helper"

class EventParticipantTest < ActiveSupport::TestCase
  test "requires an event and a user" do
    participant = EventParticipant.new
    assert_not participant.valid?
    assert_includes participant.errors[:calendar_event], error_message(:required)
    assert_includes participant.errors[:user], error_message(:required)
  end

  test "a user can only participate once in the same event" do
    calendar_events(:alpha_meeting).event_participants.create!(user: users(:one))
    duplicate = calendar_events(:alpha_meeting).event_participants.build(user: users(:one))

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:user_id], error_message(:taken)
  end

  test "the same user can participate in different events" do
    calendar_events(:alpha_meeting).event_participants.create!(user: users(:one))
    other = calendar_events(:beta_event).event_participants.build(user: users(:one))

    assert other.valid?
  end

  test "destroying an event destroys its participants" do
    participant = calendar_events(:alpha_meeting).event_participants.create!(user: users(:one))
    calendar_events(:alpha_meeting).destroy
    assert_raises(ActiveRecord::RecordNotFound) { participant.reload }
  end
end
