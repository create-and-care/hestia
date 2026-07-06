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
  end

  test "destroy" do
    entry = users(:one).weight_entries.create!(recorded_on: Date.current, weight: 70)
    delete weight_entry_path(entry)
    assert_redirected_to wellbeing_path
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
end
