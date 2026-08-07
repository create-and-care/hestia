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

  test "show wires the real-time stream" do
    get baby_profile_path(baby_profiles(:alpha_baby))
    assert_response :success
    assert_select "turbo-cable-stream-source"
  end

  test "show displays the baby's age in months" do
    get baby_profile_path(baby_profiles(:alpha_baby))
    assert_response :success
    assert_body_includes I18n.t("baby_profiles.age_months", count: baby_profiles(:alpha_baby).age_in_months)
  end

  test "show links to the linked pediatrician" do
    baby = baby_profiles(:alpha_baby)
    baby.update!(service_provider: service_providers(:alpha_plombier))
    get baby_profile_path(baby)
    assert_response :success
    assert_includes @response.body, service_providers(:alpha_plombier).name
  end

  test "create with a pediatrician links the service provider" do
    provider = service_providers(:alpha_plombier)
    post baby_profiles_path, params: { baby_profile: { name: "Sam", service_provider_id: provider.id } }
    assert_equal provider, BabyProfile.find_by(name: "Sam").service_provider
  end

  test "cannot link a pediatrician from another household" do
    post baby_profiles_path, params: { baby_profile: { name: "Sam", service_provider_id: service_providers(:beta_provider).id } }
    assert_not BabyProfile.exists?(name: "Sam")
  end

  test "is searchable via GlobalSearch" do
    results = GlobalSearch.call(query: "Lou", household: households(:alpha), user: users(:one))
    baby_group = results.find { |g| g[:module_key] == "baby" }
    assert baby_group
    assert_includes baby_group[:records].map { |r| r[:label] }, "Lou"
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
