require "test_helper"

class WorkoutTemplatesControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as(users(:one)) }

  test "index requires authentication" do
    sign_out
    get workout_templates_path
    assert_redirected_to new_session_path
  end

  test "index lists only the current user's templates" do
    users(:one).workout_templates.create!(name: "Jambes")
    users(:two).workout_templates.create!(name: "Autre")

    get workout_templates_path
    assert_response :success
    assert_includes @response.body, "Jambes"
    assert_not_includes @response.body, "Autre"
  end

  test "create scopes the template to the current user" do
    assert_difference -> { users(:one).workout_templates.count }, 1 do
      post workout_templates_path, params: { workout_template: { name: "Jambes" } }
    end
    assert_redirected_to edit_workout_template_path(users(:one).workout_templates.last)
  end

  test "create with a blank name re-renders the form" do
    assert_no_difference -> { WorkoutTemplate.count } do
      post workout_templates_path, params: { workout_template: { name: "" } }
    end
    assert_response :unprocessable_entity
  end

  test "update changes the name" do
    template = users(:one).workout_templates.create!(name: "Jambes")
    patch workout_template_path(template), params: { workout_template: { name: "Haut du corps" } }
    assert_redirected_to workout_templates_path
    assert_equal "Haut du corps", template.reload.name
  end

  test "destroy" do
    template = users(:one).workout_templates.create!(name: "Jambes")
    delete workout_template_path(template)
    assert_redirected_to workout_templates_path
    assert_not WorkoutTemplate.exists?(template.id)
  end

  test "log creates one workout entry per exercise for the current user" do
    template = users(:one).workout_templates.create!(name: "Jambes")
    template.workout_template_exercises.create!(exercise: "Squat")
    template.workout_template_exercises.create!(exercise: "Fentes")

    assert_difference -> { users(:one).workout_entries.count }, 2 do
      post log_workout_template_path(template), params: { done_on: Date.current }
    end
    assert_redirected_to wellbeing_path
  end

  # --- Strict privacy: scoped by Current.user, not household ---

  test "a user cannot edit another user's template" do
    template = users(:two).workout_templates.create!(name: "Autre")
    get edit_workout_template_path(template)
    assert_response :not_found
  end

  test "a user cannot destroy another user's template" do
    template = users(:two).workout_templates.create!(name: "Autre")
    assert_no_difference -> { WorkoutTemplate.count } do
      delete workout_template_path(template)
    end
    assert_response :not_found
  end

  test "a user cannot log another user's template" do
    template = users(:two).workout_templates.create!(name: "Autre")
    template.workout_template_exercises.create!(exercise: "Squat")
    assert_no_difference -> { WorkoutEntry.count } do
      post log_workout_template_path(template), params: { done_on: Date.current }
    end
    assert_response :not_found
  end
end
