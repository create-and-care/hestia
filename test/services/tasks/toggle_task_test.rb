require "test_helper"

module Tasks
  class ToggleTaskTest < ActiveSupport::TestCase
    test "flips the done state" do
      task = tasks(:alpha_dishes)
      assert_not task.done

      Tasks::ToggleTask.call(task: task)
      assert task.reload.done
    end
  end
end
