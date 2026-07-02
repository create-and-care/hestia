require "test_helper"

class FeedingSessionTest < ActiveSupport::TestCase
  test "duration_minutes from start and end" do
    session = FeedingSession.new(started_at: Time.current, ended_at: Time.current + 20.minutes)
    assert_equal 20, session.duration_minutes
    assert_nil FeedingSession.new(started_at: Time.current).duration_minutes
  end

  test "kind must be valid" do
    baby = baby_profiles(:alpha_baby)
    assert baby.feeding_sessions.build(kind: "breast").valid?
    assert_not baby.feeding_sessions.build(kind: "spoon").valid?
  end

  test "baby profile is scoped to its household" do
    assert_not_includes households(:alpha).baby_profiles, baby_profiles(:beta_baby)
  end
end
