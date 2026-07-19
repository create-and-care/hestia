require "test_helper"

class WeightEntriesControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as(users(:one)) }

  test "create requires authentication" do
    sign_out
    post weight_entries_path, params: { weight_entry: { weight: 72, recorded_on: Date.current } }
    assert_redirected_to new_session_path
  end

  test "create scopes the entry to the current user" do
    assert_difference -> { users(:one).weight_entries.count }, 1 do
      post weight_entries_path, params: { weight_entry: { weight: 72.5, recorded_on: Date.current } }
    end
    assert_redirected_to wellbeing_path
    assert_equal I18n.t("weight_entries.create.added"), flash[:notice]
  end

  test "create with a blank weight flashes an alert instead of failing silently" do
    assert_no_difference -> { WeightEntry.count } do
      post weight_entries_path, params: { weight_entry: { weight: "", recorded_on: Date.current } }
    end
    assert_redirected_to wellbeing_path
    assert_not_nil flash[:alert]
  end

  test "gets the edit form" do
    entry = users(:one).weight_entries.create!(recorded_on: Date.current, weight: 70)
    get edit_weight_entry_path(entry)
    assert_response :success
  end

  test "update changes the weight and date" do
    entry = users(:one).weight_entries.create!(recorded_on: Date.current, weight: 70)
    patch weight_entry_path(entry), params: { weight_entry: { weight: 68.5, recorded_on: Date.current - 1.day } }
    assert_redirected_to wellbeing_path
    assert_equal I18n.t("weight_entries.update.updated"), flash[:notice]
    entry.reload
    assert_equal 68.5, entry.weight
  end

  test "update with a blank weight re-renders the edit form" do
    entry = users(:one).weight_entries.create!(recorded_on: Date.current, weight: 70)
    patch weight_entry_path(entry), params: { weight_entry: { weight: "" } }
    assert_response :unprocessable_entity
  end

  test "destroy" do
    entry = users(:one).weight_entries.create!(recorded_on: Date.current, weight: 70)
    delete weight_entry_path(entry)
    assert_redirected_to wellbeing_path
    assert_equal I18n.t("weight_entries.destroy.deleted"), flash[:notice]
    assert_not WeightEntry.exists?(entry.id)
  end

  # --- Strict privacy (Spec §5, point 4): scoped by Current.user, not household ---

  test "a user cannot delete another user's weight entry" do
    entry = users(:one).weight_entries.create!(recorded_on: Date.current, weight: 70)
    sign_in_as(users(:two))
    assert_no_difference -> { WeightEntry.count } do
      delete weight_entry_path(entry)
    end
    assert_response :not_found
  end

  test "another member of the same household cannot delete this user's weight entry" do
    same_household_user = User.create!(name: "Coloc", email_address: "coloc@example.com", password: "secret123")
    households(:alpha).memberships.create!(user: same_household_user, role: "member")
    entry = users(:one).weight_entries.create!(recorded_on: Date.current, weight: 70)

    sign_in_as(same_household_user)
    assert_no_difference -> { WeightEntry.count } do
      delete weight_entry_path(entry)
    end
    assert_response :not_found
  end

  test "a user cannot edit another user's weight entry" do
    entry = users(:one).weight_entries.create!(recorded_on: Date.current, weight: 70)
    sign_in_as(users(:two))
    get edit_weight_entry_path(entry)
    assert_response :not_found
  end

  test "a user cannot update another user's weight entry" do
    entry = users(:one).weight_entries.create!(recorded_on: Date.current, weight: 70)
    sign_in_as(users(:two))
    patch weight_entry_path(entry), params: { weight_entry: { weight: 999 } }
    assert_response :not_found
    assert_equal 70, entry.reload.weight
  end
end
