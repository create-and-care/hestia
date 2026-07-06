require "test_helper"

class SharedExpensesControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as(users(:one)) }

  test "create requires authentication" do
    sign_out
    project = shared_projects(:alpha_trip)
    post shared_project_shared_expenses_path(project), params: { shared_expense: { amount: 30, description: "Repas" } }
    assert_redirected_to new_session_path
  end

  test "create adds an expense to the project" do
    project = shared_projects(:alpha_trip)
    assert_difference -> { project.shared_expenses.count }, 1 do
      post shared_project_shared_expenses_path(project), params: { shared_expense: { amount: 30, description: "Repas" } }
    end
    assert_redirected_to project
  end

  test "create with a payer" do
    project = shared_projects(:alpha_trip)
    participant = shared_project_participants(:trip_bob)
    post shared_project_shared_expenses_path(project),
      params: { shared_expense: { amount: 30, description: "Repas", shared_project_participant_id: participant.id } }
    assert_equal participant, SharedExpense.find_by(description: "Repas").shared_project_participant
  end

  test "destroy" do
    project = shared_projects(:alpha_trip)
    expense = shared_expenses(:exp_one)
    assert_difference -> { project.shared_expenses.count }, -1 do
      delete shared_project_shared_expense_path(project, expense)
    end
    assert_redirected_to project
  end

  test "cannot add an expense to another household's project" do
    assert_no_difference -> { SharedExpense.count } do
      post shared_project_shared_expenses_path(shared_projects(:beta_project)), params: { shared_expense: { amount: 10, description: "Hack" } }
    end
    assert_response :not_found
  end

  test "cannot destroy an expense of another household's project" do
    delete shared_project_shared_expense_path(shared_projects(:beta_project), shared_expenses(:exp_one))
    assert_response :not_found
  end
end
