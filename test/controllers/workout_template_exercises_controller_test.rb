require "test_helper"

class WorkoutTemplateExercisesControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as(users(:one)) }

  test "create adds an exercise to the current user's template" do
    template = users(:one).workout_templates.create!(name: "Jambes")
    assert_difference -> { template.workout_template_exercises.count }, 1 do
      post workout_template_exercises_path(template), params: { workout_template_exercise: { exercise: "Squat", duration_minutes: 10 } }
    end
    assert_redirected_to edit_workout_template_path(template)
  end

  test "destroy removes the exercise" do
    template = users(:one).workout_templates.create!(name: "Jambes")
    exercise = template.workout_template_exercises.create!(exercise: "Squat")
    assert_difference -> { template.workout_template_exercises.count }, -1 do
      delete workout_template_exercise_path(template, exercise)
    end
    assert_redirected_to edit_workout_template_path(template)
  end

  # --- Strict privacy: scoped by Current.user, not household ---

  test "a user cannot add an exercise to another user's template" do
    template = users(:two).workout_templates.create!(name: "Autre")
    assert_no_difference -> { template.workout_template_exercises.count } do
      post workout_template_exercises_path(template), params: { workout_template_exercise: { exercise: "Squat" } }
    end
    assert_response :not_found
  end

  test "a user cannot destroy an exercise on another user's template" do
    template = users(:two).workout_templates.create!(name: "Autre")
    exercise = template.workout_template_exercises.create!(exercise: "Squat")
    assert_no_difference -> { template.workout_template_exercises.count } do
      delete workout_template_exercise_path(template, exercise)
    end
    assert_response :not_found
  end
end
