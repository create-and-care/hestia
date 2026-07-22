require "test_helper"

class WorkoutEntriesControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as(users(:one)) }

  test "create requires authentication" do
    sign_out
    post workout_entries_path, params: { workout_entry: { exercise: "Course", duration_minutes: 30, done_on: Date.current } }
    assert_redirected_to new_session_path
  end

  test "create scopes the entry to the current user" do
    assert_difference -> { users(:one).workout_entries.count }, 1 do
      post workout_entries_path, params: { workout_entry: { exercise: "Course", duration_minutes: 30, done_on: Date.current } }
    end
    assert_redirected_to wellbeing_path
    assert_equal I18n.t("workout_entries.create.added"), flash[:notice]
  end

  test "create with a blank exercise flashes an alert instead of failing silently" do
    assert_no_difference -> { WorkoutEntry.count } do
      post workout_entries_path, params: { workout_entry: { exercise: "", done_on: Date.current } }
    end
    assert_redirected_to wellbeing_path
    assert_not_nil flash[:alert]
  end

  test "gets the edit form" do
    entry = users(:one).workout_entries.create!(done_on: Date.current, exercise: "Vélo", duration_minutes: 45)
    get edit_workout_entry_path(entry)
    assert_response :success
  end

  test "update changes the exercise" do
    entry = users(:one).workout_entries.create!(done_on: Date.current, exercise: "Vélo", duration_minutes: 45)
    patch workout_entry_path(entry), params: { workout_entry: { exercise: "Course", duration_minutes: 20, done_on: Date.current } }
    assert_redirected_to wellbeing_path
    assert_equal I18n.t("workout_entries.update.updated"), flash[:notice]
    entry.reload
    assert_equal "Course", entry.exercise
    assert_equal 20, entry.duration_minutes
  end

  test "update with a blank exercise re-renders the edit form" do
    entry = users(:one).workout_entries.create!(done_on: Date.current, exercise: "Vélo", duration_minutes: 45)
    patch workout_entry_path(entry), params: { workout_entry: { exercise: "" } }
    assert_response :unprocessable_entity
  end

  test "destroy" do
    entry = users(:one).workout_entries.create!(done_on: Date.current, exercise: "Vélo", duration_minutes: 45)
    delete workout_entry_path(entry)
    assert_redirected_to wellbeing_path
    assert_equal I18n.t("workout_entries.destroy.deleted"), flash[:notice]
    assert_not WorkoutEntry.exists?(entry.id)
  end

  # --- Strict privacy: scoped by Current.user, not household ---

  test "a user cannot delete another user's workout entry" do
    entry = users(:one).workout_entries.create!(done_on: Date.current, exercise: "Vélo", duration_minutes: 45)
    sign_in_as(users(:two))
    assert_no_difference -> { WorkoutEntry.count } do
      delete workout_entry_path(entry)
    end
    assert_response :not_found
  end

  test "another member of the same household cannot delete this user's workout entry" do
    same_household_user = User.create!(name: "Coloc", email_address: "coloc@example.com", password: "secret123")
    households(:alpha).memberships.create!(user: same_household_user, role: "member")
    entry = users(:one).workout_entries.create!(done_on: Date.current, exercise: "Vélo", duration_minutes: 45)

    sign_in_as(same_household_user)
    assert_no_difference -> { WorkoutEntry.count } do
      delete workout_entry_path(entry)
    end
    assert_response :not_found
  end

  test "a user cannot edit another user's workout entry" do
    entry = users(:one).workout_entries.create!(done_on: Date.current, exercise: "Vélo", duration_minutes: 45)
    sign_in_as(users(:two))
    get edit_workout_entry_path(entry)
    assert_response :not_found
  end

  test "a user cannot update another user's workout entry" do
    entry = users(:one).workout_entries.create!(done_on: Date.current, exercise: "Vélo", duration_minutes: 45)
    sign_in_as(users(:two))
    patch workout_entry_path(entry), params: { workout_entry: { exercise: "Hack" } }
    assert_response :not_found
    assert_equal "Vélo", entry.reload.exercise
  end
end
