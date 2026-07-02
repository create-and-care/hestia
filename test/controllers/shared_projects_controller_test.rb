require "test_helper"

class SharedProjectsControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as(users(:one)) }

  test "index shows the household's projects only" do
    get shared_projects_path
    assert_response :success
    assert_includes @response.body, "Week-end"
    assert_not_includes @response.body, "Projet Beta"
  end

  test "show renders the settlement balances" do
    get shared_project_path(shared_projects(:alpha_trip))
    assert_response :success
    assert_includes @response.body, "Alice"
  end

  test "create a project adds the current user as a participant" do
    assert_difference -> { households(:alpha).shared_projects.count }, 1 do
      post shared_projects_path, params: { shared_project: { name: "Rénovation" } }
    end
    project = SharedProject.find_by!(name: "Rénovation")
    assert_equal 1, project.shared_project_participants.count
  end

  test "add a participant and an expense" do
    project = shared_projects(:alpha_trip)
    post shared_project_shared_project_participants_path(project), params: { shared_project_participant: { name: "Chris" } }
    post shared_project_shared_expenses_path(project), params: { shared_expense: { amount: 30, description: "Repas" } }
    assert_equal 3, project.shared_project_participants.count
    assert_equal 3, project.shared_expenses.count
  end

  test "cannot access another household's project" do
    get shared_project_path(shared_projects(:beta_project))
    assert_response :not_found
  end
end
