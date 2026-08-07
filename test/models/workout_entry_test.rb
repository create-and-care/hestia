require "test_helper"

class WorkoutEntryTest < ActiveSupport::TestCase
  test "requires done_on and exercise" do
    entry = WorkoutEntry.new(user: users(:one))
    assert_not entry.valid?
    assert_includes entry.errors[:done_on], error_message(:blank)
    assert_includes entry.errors[:exercise], error_message(:blank)
  end

  test "belongs to a user" do
    entry = WorkoutEntry.new(done_on: Date.current, exercise: "Course")
    assert_not entry.valid?
    assert_includes entry.errors[:user], error_message(:required)
  end

  test "recent orders from newest to oldest" do
    user = users(:one)
    older = user.workout_entries.create!(done_on: 3.days.ago.to_date, exercise: "Course", duration_minutes: 30)
    newer = user.workout_entries.create!(done_on: Date.current, exercise: "Vélo", duration_minutes: 45)

    assert_equal [ newer, older ], user.workout_entries.recent.to_a
  end
end
