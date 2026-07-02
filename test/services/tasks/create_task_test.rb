require "test_helper"

module Tasks
  class CreateTaskTest < ActiveSupport::TestCase
    test "creates a task at the next position" do
      task = Tasks::CreateTask.call(household: households(:alpha), title: "Nouvelle")
      assert_equal "Nouvelle", task.title
      assert_equal 2, task.position # fixtures occupy 0 and 1
    end

    test "assigns member and category" do
      task = Tasks::CreateTask.call(
        household: households(:alpha), title: "X",
        assignee: users(:one), task_category: task_categories(:alpha_home)
      )
      assert_equal users(:one), task.assignee
      assert_equal task_categories(:alpha_home), task.task_category
    end
  end
end
