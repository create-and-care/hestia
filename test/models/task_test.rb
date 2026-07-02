require "test_helper"

class TaskTest < ActiveSupport::TestCase
  test "requires a title" do
    task = households(:alpha).tasks.build
    assert_not task.valid?
    task.title = "X"
    assert task.valid?
  end

  test "due_status is computed from the current date" do
    task = Task.new
    assert_equal :none, task.due_status

    task.due_on = Date.current - 1
    assert_equal :overdue, task.due_status

    task.due_on = Date.current + 1
    assert_equal :urgent, task.due_status

    task.due_on = Date.current + 5
    assert_equal :soon, task.due_status

    task.due_on = Date.current + 20
    assert_equal :later, task.due_status
  end

  test "board_column_id reflects the category" do
    assert_equal "tasks_category_#{task_categories(:alpha_home).id}", tasks(:alpha_dishes).board_column_id
    assert_equal "tasks_uncategorized", tasks(:alpha_call).board_column_id
  end

  test "is scoped to its household" do
    assert_not_includes households(:alpha).tasks, tasks(:beta_report)
  end

  test "destroying a category nullifies its tasks" do
    task = tasks(:alpha_dishes)
    task_categories(:alpha_home).destroy
    assert_nil task.reload.task_category_id
  end
end
