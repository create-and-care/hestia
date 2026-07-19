require "test_helper"

class WellbeingControllerTest < ActionDispatch::IntegrationTest
  test "requires authentication" do
    get wellbeing_path
    assert_redirected_to new_session_path
  end

  test "show renders for the current user" do
    sign_in_as(users(:one))
    get wellbeing_path
    assert_response :success
  end

  test "create a weight entry scoped to the current user" do
    sign_in_as(users(:one))
    assert_difference -> { users(:one).weight_entries.count }, 1 do
      post weight_entries_path, params: { weight_entry: { weight: 72, recorded_on: Date.current } }
    end
    assert_redirected_to wellbeing_path
  end

  test "create a workout entry scoped to the current user" do
    sign_in_as(users(:one))
    assert_difference -> { users(:one).workout_entries.count }, 1 do
      post workout_entries_path, params: { workout_entry: { exercise: "Course", duration_minutes: 30, done_on: Date.current } }
    end
  end

  test "profile update is scoped to the current user" do
    sign_in_as(users(:one))
    patch wellbeing_profile_path, params: { wellbeing_profile: { height: 175, age: 30 } }
    assert_equal 175, users(:one).reload.wellbeing_profile.height
  end

  test "profile update with an invalid sex flashes an alert instead of failing silently" do
    sign_in_as(users(:one))
    patch wellbeing_profile_path, params: { wellbeing_profile: { sex: "bogus" } }
    assert_redirected_to wellbeing_path
    assert_not_nil flash[:alert]
  end

  test "shows an empty state when there are no weigh-ins or workouts yet" do
    sign_in_as(users(:one))
    get wellbeing_path
    assert_response :success
    assert_includes @response.body, I18n.t("wellbeing.show.weight_empty")
    assert_includes @response.body, I18n.t("wellbeing.show.workouts_empty")
  end

  test "does not render the weight chart with fewer than 2 weigh-ins" do
    sign_in_as(users(:one))
    users(:one).weight_entries.create!(recorded_on: Date.current, weight: 70)
    get wellbeing_path
    assert_response :success
    assert_not_includes @response.body, I18n.t("wellbeing.show.chart_heading")
  end

  test "renders the weight chart from 2 weigh-ins" do
    sign_in_as(users(:one))
    users(:one).weight_entries.create!(recorded_on: Date.current - 1.day, weight: 71)
    users(:one).weight_entries.create!(recorded_on: Date.current, weight: 70)
    get wellbeing_path
    assert_response :success
    assert_includes @response.body, I18n.t("wellbeing.show.chart_heading")
  end

  test "delete forms for entries have a turbo_confirm" do
    sign_in_as(users(:one))
    users(:one).weight_entries.create!(recorded_on: Date.current, weight: 70)
    users(:one).workout_entries.create!(done_on: Date.current, exercise: "Vélo")
    get wellbeing_path
    assert_response :success
    assert_select "form[action=?][data-turbo-confirm]", weight_entry_path(users(:one).weight_entries.first)
    assert_select "form[action=?][data-turbo-confirm]", workout_entry_path(users(:one).workout_entries.first)
  end

  test "history shows the full weigh-in and workout history, paginated" do
    sign_in_as(users(:one))
    20.times { |i| users(:one).weight_entries.create!(recorded_on: Date.current - i.days, weight: 70 + i) }

    get history_wellbeing_path
    assert_response :success
    assert_select "a[href=?]", history_wellbeing_path(weight_page: 2, workout_page: 1)
  end

  test "history is scoped to the current user" do
    users(:two).weight_entries.create!(recorded_on: Date.current, weight: 123.7)
    sign_in_as(users(:one))
    get history_wellbeing_path
    assert_response :success
    assert_includes @response.body, I18n.t("wellbeing.history.weight_empty")
  end

  # --- Strict privacy (Spec §5, point 4) ---

  test "a user cannot delete another user's weight entry" do
    entry = users(:one).weight_entries.create!(recorded_on: Date.current, weight: 70)
    sign_in_as(users(:two))
    assert_no_difference -> { WeightEntry.count } do
      delete weight_entry_path(entry)
    end
    assert_response :not_found
  end

  test "an administrator of the same household cannot access another member's wellbeing data" do
    admin = User.create!(name: "Admin2", email_address: "admin2@example.com", password: "secret123")
    households(:alpha).memberships.create!(user: admin, role: "admin")
    entry = users(:one).weight_entries.create!(recorded_on: Date.current, weight: 88)

    sign_in_as(admin)
    assert_no_difference -> { WeightEntry.count } do
      delete weight_entry_path(entry)
    end
    assert_response :not_found
  end
end
