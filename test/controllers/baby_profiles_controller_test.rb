require "test_helper"

class BabyProfilesControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as(users(:one)) }

  test "index requires authentication" do
    sign_out
    get baby_profiles_path
    assert_redirected_to new_session_path
  end

  test "index shows the household's babies only" do
    get baby_profiles_path
    assert_response :success
    assert_includes @response.body, "Lou"
    assert_not_includes @response.body, "Bébé Beta"
  end

  test "show" do
    get baby_profile_path(baby_profiles(:alpha_baby))
    assert_response :success
    assert_includes @response.body, "Lou"
  end

  test "create" do
    assert_difference -> { households(:alpha).baby_profiles.count }, 1 do
      post baby_profiles_path, params: { baby_profile: { name: "Sam" } }
    end
    assert_redirected_to BabyProfile.find_by(name: "Sam")
  end

  test "add a feeding session, a food introduction and an allergen test" do
    baby = baby_profiles(:alpha_baby)
    post baby_profile_feeding_sessions_path(baby), params: { feeding_session: { kind: "bottle", started_at: Time.current } }
    post baby_profile_food_introductions_path(baby), params: { food_introduction: { food: "Carotte", acceptance: "Aimé" } }
    post baby_profile_allergen_tests_path(baby), params: { allergen_test: { allergen: "Arachide", severity: "Aucune" } }
    assert_equal 1, baby.feeding_sessions.count
    assert_equal 1, baby.food_introductions.count
    assert_equal 1, baby.allergen_tests.count
  end

  test "destroy" do
    baby = baby_profiles(:alpha_baby)
    delete baby_profile_path(baby)
    assert_redirected_to baby_profiles_path
    assert_not BabyProfile.exists?(baby.id)
  end

  test "cannot access another household's baby" do
    get baby_profile_path(baby_profiles(:beta_baby))
    assert_response :not_found
  end

  test "cannot add records to another household's baby" do
    assert_no_difference -> { FeedingSession.count } do
      post baby_profile_feeding_sessions_path(baby_profiles(:beta_baby)), params: { feeding_session: { kind: "bottle" } }
    end
    assert_response :not_found
  end
end
