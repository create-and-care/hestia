require "test_helper"
require "turbo/broadcastable/test_helper"

class TaskTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper
  include Turbo::Broadcastable::TestHelper
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

  test "is scoped to its household" do
    assert_not_includes households(:alpha).tasks, tasks(:beta_report)
  end

  test "destroying a category nullifies its tasks" do
    task = tasks(:alpha_dishes)
    task_categories(:alpha_home).destroy
    assert_nil task.reload.task_category_id
  end

  # A card-shaped payload cannot be right for both views at once, and the agenda
  # one it would have to target does not even exist in a board reader's DOM.
  test "a mutation broadcasts a page refresh on the tasks stream" do
    household = households(:alpha)

    streams = capture_turbo_stream_broadcasts [ household, "tasks" ] do
      perform_enqueued_jobs { household.tasks.create!(title: "Nouvelle tâche", task_category: task_categories(:alpha_home)) }
    end

    assert_equal [ "refresh" ], streams.map { |stream| stream["action"] }.uniq
  end

  # The household's own stream carries every other module's index, which would
  # reload wholesale on any task change.
  test "the refresh does not go out on the household's general stream" do
    household = households(:alpha)

    assert_no_turbo_stream_broadcasts household do
      perform_enqueued_jobs { household.tasks.create!(title: "Nouvelle tâche") }
    end
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
