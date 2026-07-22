require "test_helper"

class WellbeingProfilesControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as(users(:one)) }

  test "update requires authentication" do
    sign_out
    patch wellbeing_profile_path, params: { wellbeing_profile: { height: 175 } }
    assert_redirected_to new_session_path
  end

  test "update builds a profile for the current user when none exists" do
    assert_nil users(:one).wellbeing_profile
    patch wellbeing_profile_path, params: { wellbeing_profile: { height: 175, age: 30, sex: "female", activity_level: "moderate" } }
    assert_redirected_to wellbeing_path
    assert_equal 175, users(:one).reload.wellbeing_profile.height
  end

  test "update edits the existing profile for the current user" do
    users(:one).create_wellbeing_profile!(height: 160)
    patch wellbeing_profile_path, params: { wellbeing_profile: { height: 182 } }
    assert_equal 182, users(:one).reload.wellbeing_profile.height
  end

  # --- Strict privacy: scoped by Current.user, not household ---

  test "another member of the same household cannot edit this user's profile" do
    same_household_user = User.create!(name: "Coloc", email_address: "coloc@example.com", password: "secret123")
    households(:alpha).memberships.create!(user: same_household_user, role: "member")
    users(:one).create_wellbeing_profile!(height: 160)

    sign_in_as(same_household_user)
    patch wellbeing_profile_path, params: { wellbeing_profile: { height: 999 } }

    assert_equal 160, users(:one).reload.wellbeing_profile.height
  end
end
