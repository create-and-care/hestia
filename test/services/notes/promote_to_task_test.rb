require "test_helper"

module Notes
  class PromoteToTaskTest < ActiveSupport::TestCase
    test "creates a task in the note's household from its title and content" do
      note = notes(:alpha_idea)

      task = Notes::PromoteToTask.call(note: note)

      assert_equal note.household, task.household
      assert_equal note.title, task.title
      assert_equal note.content, task.description
    end
  end
end
