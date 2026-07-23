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

  test "routine deletion uses the design-system alert dialog instead of a native confirm" do
    get routines_path
    assert_response :success
    assert_select "dialog[role='alertdialog']"
    assert_no_match(/data-turbo-confirm="#{Regexp.escape(I18n.t("routines.routine.delete_confirm"))}"/, @response.body)
  end

  test "index no longer offers an emoji input in the new-routine form" do
    get routines_path
    assert_response :success
    assert_select "input[name='routine[emoji]']", count: 0
  end

  test "index offers a lazy-loaded edit modal and history modal for each routine, scoped to the routine's own frame" do
    routine = routines(:alpha_vacuum)
    get routines_path
    assert_select "turbo-frame##{ActionView::RecordIdentifier.dom_id(routine, :edit)}[src=?]", edit_routine_path(routine)
    assert_select "turbo-frame##{ActionView::RecordIdentifier.dom_id(routine, :history)}[src=?]", routine_path(routine)
  end

  test "create" do
    assert_difference -> { households(:alpha).routines.count }, 1 do
      post routines_path, params: { routine: { name: "Sortir les poubelles", frequency: "weekly", interval: 1 } }
    end
    assert_redirected_to routines_path
  end

  test "create with a new list name" do
    assert_difference -> { households(:alpha).routines.count }, 1 do
      post routines_path, params: { routine: { name: "Ranger le garage", frequency: "monthly", list_name: "Garage" } }
    end
    assert_equal "Garage", Routine.order(:id).last.list_name
  end

  test "create with invalid attributes redirects with an alert" do
    assert_no_difference -> { Routine.count } do
      post routines_path, params: { routine: { name: "", frequency: "invalid" } }
    end
    assert_redirected_to routines_path
  end

  test "show renders the completion history" do
    routine = routines(:alpha_vacuum)
    routine.complete!(author: users(:one), on: Date.current)

    get routine_path(routine)

    assert_response :success
    assert_includes @response.body, "Alice"
  end

  test "show shows a breadcrumb back to routines instead of a back link" do
    get routine_path(routines(:alpha_vacuum))
    assert_select "nav a[href=?]", routines_path
    assert_no_match(/← Routines/, @response.body)
  end

  test "cannot view another household's routine history" do
    get routine_path(routines(:beta_routine))
    assert_response :not_found
  end

  test "complete advances the due date" do
    routine = routines(:alpha_vacuum)
    assert_difference -> { routine.routine_completions.count }, 1 do
      post complete_routine_path(routine)
    end
    assert_equal Date.current + 1.week, routine.reload.next_due_on
  end

  test "update" do
    routine = routines(:alpha_vacuum)
    patch routine_path(routine), params: { routine: { name: "Passer le balai" } }
    assert_redirected_to routines_path
    assert_equal "Passer le balai", routine.reload.name
  end

  test "update via turbo_stream returns no content so the modal can close, relying on the real-time stream to refresh the card" do
    routine = routines(:alpha_vacuum)
    patch routine_path(routine), params: { routine: { name: "Passer le balai" } }, as: :turbo_stream
    assert_response :no_content
    assert_equal "Passer le balai", routine.reload.name
  end

  test "edit no longer offers an emoji input" do
    get edit_routine_path(routines(:alpha_vacuum))
    assert_response :success
    assert_select "input[name='routine[emoji]']", count: 0
  end

  test "edit shows a breadcrumb back to routines instead of a back link" do
    get edit_routine_path(routines(:alpha_vacuum))
    assert_select "nav a[href=?]", routines_path
    assert_no_match(/← Routines/, @response.body)
  end

  test "destroy" do
    routine = routines(:alpha_vacuum)
    delete routine_path(routine), as: :turbo_stream
    assert_response :success
    assert_not Routine.exists?(routine.id)
  end

  test "cannot touch another household's routine" do
    post complete_routine_path(routines(:beta_routine))
    assert_response :not_found
  end
end
