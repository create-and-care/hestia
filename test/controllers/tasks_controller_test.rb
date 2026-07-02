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
end
