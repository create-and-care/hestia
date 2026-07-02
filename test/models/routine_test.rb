require "test_helper"

class RoutineTest < ActiveSupport::TestCase
  test "sets an initial due date on create" do
    routine = households(:alpha).routines.create!(name: "X", frequency: "weekly")
    assert_equal Date.current, routine.next_due_on
  end

  test "overdue? reflects the due date" do
    assert routines(:alpha_overdue).overdue?
    assert_not routines(:alpha_vacuum).overdue?
  end

  test "complete! records a completion and advances the due date" do
    routine = routines(:alpha_vacuum) # weekly, interval 1
    assert_difference -> { routine.routine_completions.count }, 1 do
      routine.complete!(author: users(:one), on: Date.current)
    end
    assert_equal Date.current + 1.week, routine.reload.next_due_on
  end

  test "monthly recurrence advances by months" do
    routine = households(:alpha).routines.create!(name: "M", frequency: "monthly", interval: 2)
    routine.complete!(author: users(:one), on: Date.new(2026, 1, 15))
    assert_equal Date.new(2026, 3, 15), routine.next_due_on
  end

  test "is scoped to its household" do
    assert_not_includes households(:alpha).routines, routines(:beta_routine)
  end
end
