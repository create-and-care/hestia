require "test_helper"

class SharedProjectParticipantsControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as(users(:one)) }

  test "create requires authentication" do
    sign_out
    project = shared_projects(:alpha_trip)
    post shared_project_shared_project_participants_path(project), params: { shared_project_participant: { name: "Chris" } }
    assert_redirected_to new_session_path
  end

  test "create adds a participant to the project" do
    project = shared_projects(:alpha_trip)
    assert_difference -> { project.shared_project_participants.count }, 1 do
      post shared_project_shared_project_participants_path(project), params: { shared_project_participant: { name: "Chris" } }
    end
    assert_redirected_to project
  end

  test "destroy" do
    project = shared_projects(:alpha_trip)
    participant = shared_project_participants(:trip_bob)
    assert_difference -> { project.shared_project_participants.count }, -1 do
      delete shared_project_shared_project_participant_path(project, participant)
    end
    assert_redirected_to project
  end

  test "cannot add a participant to another household's project" do
    assert_no_difference -> { SharedProjectParticipant.count } do
      post shared_project_shared_project_participants_path(shared_projects(:beta_project)), params: { shared_project_participant: { name: "Hack" } }
    end
    assert_response :not_found
  end

  test "cannot destroy a participant of another household's project" do
    delete shared_project_shared_project_participant_path(shared_projects(:beta_project), shared_project_participants(:trip_alice))
    assert_response :not_found
  end
end
