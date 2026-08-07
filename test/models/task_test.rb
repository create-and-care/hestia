require "test_helper"
require "turbo/broadcastable/test_helper"

class TaskTest < ActiveSupport::TestCase
  include Turbo::Broadcastable::TestHelper

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

  test "removes the empty-column placeholder when the first task lands in a category" do
    category = task_categories(:alpha_home)
    household = households(:alpha)
    household.tasks.where(task_category: category).destroy_all

    streams = capture_turbo_stream_broadcasts household do
      household.tasks.create!(title: "Nouvelle tâche", task_category: category)
    end

    removal = streams.find { |stream| stream["action"] == "remove" }
    assert_equal "tasks_category_#{category.id}_empty", removal["target"]
  end

  test "overdue matches exactly the tasks due_status flags as overdue" do
    household = households(:alpha)
    household.tasks.destroy_all
    late = household.tasks.create!(title: "En retard", due_on: 2.days.ago.to_date)
    older = household.tasks.create!(title: "Encore plus vieille", due_on: 10.days.ago.to_date)
    household.tasks.create!(title: "Faite", due_on: 2.days.ago.to_date, done: true)
    household.tasks.create!(title: "Aujourd'hui", due_on: Date.current)
    household.tasks.create!(title: "Sans échéance", due_on: nil)

    assert_equal [ older, late ], household.tasks.overdue.to_a
  end
end
