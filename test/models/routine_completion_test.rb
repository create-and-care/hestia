require "test_helper"

class RoutineCompletionTest < ActiveSupport::TestCase
  test "requires a completed_on date" do
    completion = routines(:alpha_vacuum).routine_completions.build(author: users(:one))
    assert_not completion.valid?
    completion.completed_on = Date.current
    assert completion.valid?
  end

  test "author is optional" do
    completion = routines(:alpha_vacuum).routine_completions.build(completed_on: Date.current)
    assert completion.valid?
  end

  test "recent scope orders by completed_on descending" do
    older = routines(:alpha_vacuum).routine_completions.create!(completed_on: 2.days.ago.to_date)
    newer = routines(:alpha_vacuum).routine_completions.create!(completed_on: 1.day.ago.to_date)
    assert_equal [ newer, older ], RoutineCompletion.where(id: [ older.id, newer.id ]).recent.to_a
  end
end
