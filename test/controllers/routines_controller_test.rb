require "test_helper"

class RoutinesControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as(users(:one)) }

  test "index requires authentication" do
    sign_out
    get routines_path
    assert_redirected_to new_session_path
  end

  test "index shows the household's routines only" do
    get routines_path
    assert_response :success
    assert_includes @response.body, "aspirateur"
    assert_not_includes @response.body, "Routine Beta"
  end

  test "filter by thematic list" do
    get routines_path(list: "Ménage")
    assert_response :success
    assert_includes @response.body, "aspirateur"
  end

  test "create" do
    assert_difference -> { households(:alpha).routines.count }, 1 do
      post routines_path, params: { routine: { name: "Sortir les poubelles", frequency: "weekly", interval: 1 } }
    end
    assert_redirected_to routines_path
  end

  test "complete advances the due date" do
    routine = routines(:alpha_vacuum)
    assert_difference -> { routine.routine_completions.count }, 1 do
      post complete_routine_path(routine)
    end
    assert_equal Date.current + 1.week, routine.reload.next_due_on
  end

  test "destroy" do
    routine = routines(:alpha_vacuum)
    delete routine_path(routine)
    assert_not Routine.exists?(routine.id)
  end

  test "cannot touch another household's routine" do
    post complete_routine_path(routines(:beta_routine))
    assert_response :not_found
  end
end
