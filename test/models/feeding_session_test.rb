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

  test "in_progress scope returns sessions without an end time" do
    baby = baby_profiles(:alpha_baby)
    ongoing = baby.feeding_sessions.create!(kind: "bottle", started_at: Time.current)
    baby.feeding_sessions.create!(kind: "bottle", started_at: 1.hour.ago, ended_at: 30.minutes.ago)

    assert_equal [ ongoing ], baby.feeding_sessions.in_progress.to_a
  end
end
