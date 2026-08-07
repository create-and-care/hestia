require "test_helper"

class WorkoutTemplateExerciseTest < ActiveSupport::TestCase
  test "requires an exercise name" do
    template = users(:one).workout_templates.create!(name: "Jambes")
    exercise = template.workout_template_exercises.new
    assert_not exercise.valid?
    assert_includes exercise.errors[:exercise], error_message(:blank)
  end

  test "assigns incrementing positions in creation order" do
    template = users(:one).workout_templates.create!(name: "Jambes")
    first = template.workout_template_exercises.create!(exercise: "Squat")
    second = template.workout_template_exercises.create!(exercise: "Fentes")

    assert_equal 0, first.position
    assert_equal 1, second.position
  end
end
