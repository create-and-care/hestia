require "test_helper"

class TasksControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as(users(:one)) }

  test "index requires authentication" do
    sign_out
    get tasks_path
    assert_redirected_to new_session_path
  end

  test "index shows the household's tasks in a kanban" do
    get tasks_path
    assert_response :success
    assert_includes @response.body, "Faire la vaisselle"
    assert_not_includes @response.body, "Rapport" # beta's task
    assert_select "#tasks_uncategorized"
  end

  test "search filters the tasks" do
    get tasks_path(q: "vaisselle")
    assert_response :success
    assert_includes @response.body, "Faire la vaisselle"
  end

  test "search also matches the description" do
    tasks(:alpha_call).update!(description: "Prendre rendez-vous urgent")
    get tasks_path(q: "urgent")
    assert_includes @response.body, "Appeler le médecin"
  end

  test "create passes the description through instead of dropping it" do
    post tasks_path, params: { task: { title: "Nouvelle", description: "Des détails" } }, as: :turbo_stream
    assert_equal "Des détails", Task.find_by!(title: "Nouvelle").description
  end

  test "create with a category and an assignee" do
    assert_difference -> { households(:alpha).tasks.count }, 1 do
      post tasks_path, params: { task: {
        title: "Balayer", task_category_id: task_categories(:alpha_home).id, assignee_id: users(:one).id
      } }, as: :turbo_stream
    end
    assert_response :success
    task = Task.find_by!(title: "Balayer")
    assert_equal task_categories(:alpha_home), task.task_category
    assert_equal users(:one), task.assignee
  end

  test "create ignores an assignee outside the household" do
    post tasks_path, params: { task: { title: "Intrus", assignee_id: users(:two).id } }, as: :turbo_stream
    assert_nil Task.find_by(title: "Intrus").assignee_id
  end

  test "toggle flips the done state" do
    task = tasks(:alpha_dishes)
    patch toggle_task_path(task), as: :turbo_stream
    assert_response :success
    assert task.reload.done
  end

  test "update" do
    task = tasks(:alpha_dishes)
    patch task_path(task), params: { task: { title: "Vaisselle du soir" } }
    assert_redirected_to tasks_path
    assert_equal "Vaisselle du soir", task.reload.title
  end

  test "destroy" do
    task = tasks(:alpha_dishes)
    delete task_path(task), as: :turbo_stream
    assert_response :success
    assert_not Task.exists?(task.id)
  end

  test "cannot touch another household's task" do
    delete task_path(tasks(:beta_report))
    assert_response :not_found
  end

  test "move_up swaps position with the previous task in the same column" do
    first = tasks(:alpha_dishes) # alpha_home, position 0
    second = households(:alpha).tasks.create!(title: "Ranger", task_category: task_categories(:alpha_home), position: 5)

    patch move_up_task_path(second)

    assert_equal 0, second.reload.position
    assert_equal 5, first.reload.position
  end

  test "move_up does nothing for the first task in its column" do
    first = tasks(:alpha_dishes)
    patch move_up_task_path(first)
    assert_equal 0, first.reload.position
  end

  test "move_down swaps position with the next task in the same column" do
    first = tasks(:alpha_dishes) # alpha_home, position 0
    second = households(:alpha).tasks.create!(title: "Ranger", task_category: task_categories(:alpha_home), position: 5)

    patch move_down_task_path(first)

    assert_equal 5, first.reload.position
    assert_equal 0, second.reload.position
  end

  test "sort by due_date reorders unfinished tasks within a column without touching other columns" do
    no_due = households(:alpha).tasks.create!(title: "Sans échéance", task_category: task_categories(:alpha_home), position: 0)
    with_due = households(:alpha).tasks.create!(title: "Avec échéance", task_category: task_categories(:alpha_home),
      due_on: 1.day.from_now, position: 10)
    tasks(:alpha_dishes).update!(position: 20) # also alpha_home, due in 3 days — should sort after with_due

    post sort_tasks_path, params: { by: "due_date" }

    assert_equal 0, with_due.reload.position
    assert_equal 1, tasks(:alpha_dishes).reload.position
    assert_equal 2, no_due.reload.position
  end

  test "sort ignores an unknown 'by' value" do
    post sort_tasks_path, params: { by: "nonsense" }
    assert_redirected_to tasks_path
  end
end
