require "test_helper"

class FeedingSessionsControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as(users(:one)) }

  test "create adds a feeding session to the baby profile" do
    baby = baby_profiles(:alpha_baby)
    assert_difference -> { baby.feeding_sessions.count }, 1 do
      post baby_profile_feeding_sessions_path(baby), params: { feeding_session: { kind: "bottle", started_at: 1.hour.ago, ended_at: 30.minutes.ago } }
    end
    assert_redirected_to baby
  end

  test "destroy" do
    baby = baby_profiles(:alpha_baby)
    session = baby.feeding_sessions.create!(kind: "breast")
    delete baby_profile_feeding_session_path(baby, session)
    assert_redirected_to baby
    assert_not FeedingSession.exists?(session.id)
  end

  test "cannot add a feeding session to another household's baby" do
    assert_no_difference -> { FeedingSession.count } do
      post baby_profile_feeding_sessions_path(baby_profiles(:beta_baby)), params: { feeding_session: { kind: "bottle" } }
    end
    assert_response :not_found
  end

  test "cannot destroy another household's feeding session" do
    session = baby_profiles(:beta_baby).feeding_sessions.create!(kind: "bottle")
    assert_no_difference -> { FeedingSession.count } do
      delete baby_profile_feeding_session_path(baby_profiles(:beta_baby), session)
    end
    assert_response :not_found
  end
end
