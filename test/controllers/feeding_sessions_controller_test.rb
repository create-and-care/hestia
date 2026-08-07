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

  test "create without a started_at starts the timer at the current time" do
    baby = baby_profiles(:alpha_baby)
    post baby_profile_feeding_sessions_path(baby), params: { feeding_session: { kind: "bottle" } }
    session = baby.feeding_sessions.last
    assert_in_delta Time.current, session.started_at, 5.seconds
    assert_nil session.ended_at
  end

  test "create gives a success flash notice" do
    baby = baby_profiles(:alpha_baby)
    post baby_profile_feeding_sessions_path(baby), params: { feeding_session: { kind: "bottle" } }
    follow_redirect!
    assert_body_includes I18n.t("feeding_sessions.create.created")
  end

  test "create with an invalid kind does not persist and surfaces an error" do
    baby = baby_profiles(:alpha_baby)
    assert_no_difference -> { FeedingSession.count } do
      post baby_profile_feeding_sessions_path(baby), params: { feeding_session: { kind: "spoon" } }
    end
    assert_redirected_to baby
    assert_equal validation_message(FeedingSession, :kind, :inclusion), flash[:alert]
  end

  test "stop sets the end time on an in-progress session" do
    baby = baby_profiles(:alpha_baby)
    session = baby.feeding_sessions.create!(kind: "bottle", started_at: 10.minutes.ago)
    patch stop_baby_profile_feeding_session_path(baby, session)
    assert_redirected_to baby
    assert_not_nil session.reload.ended_at
  end

  test "cannot stop another household's feeding session" do
    session = baby_profiles(:beta_baby).feeding_sessions.create!(kind: "bottle", started_at: 10.minutes.ago)
    patch stop_baby_profile_feeding_session_path(baby_profiles(:beta_baby), session)
    assert_response :not_found
  end

  test "edit and update a feeding session's times" do
    baby = baby_profiles(:alpha_baby)
    session = baby.feeding_sessions.create!(kind: "bottle", started_at: 1.hour.ago, ended_at: 30.minutes.ago)

    get edit_baby_profile_feeding_session_path(baby, session)
    assert_response :success

    patch baby_profile_feeding_session_path(baby, session), params: { feeding_session: { kind: "breast" } }
    assert_redirected_to baby
    assert_equal "breast", session.reload.kind
  end

  test "cannot edit another household's feeding session" do
    session = baby_profiles(:beta_baby).feeding_sessions.create!(kind: "bottle")
    get edit_baby_profile_feeding_session_path(baby_profiles(:beta_baby), session)
    assert_response :not_found
  end
end
