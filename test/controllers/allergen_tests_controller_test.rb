require "test_helper"

class AllergenTestsControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as(users(:one)) }

  test "create adds an allergen test to the baby profile" do
    baby = baby_profiles(:alpha_baby)
    assert_difference -> { baby.allergen_tests.count }, 1 do
      post baby_profile_allergen_tests_path(baby), params: { allergen_test: { allergen: "Arachide", tested_on: Date.current, severity: "Aucune" } }
    end
    assert_redirected_to baby
  end

  test "destroy" do
    baby = baby_profiles(:alpha_baby)
    test_record = baby.allergen_tests.create!(allergen: "Arachide")
    delete baby_profile_allergen_test_path(baby, test_record)
    assert_redirected_to baby
    assert_not AllergenTest.exists?(test_record.id)
  end

  test "cannot add an allergen test to another household's baby" do
    assert_no_difference -> { AllergenTest.count } do
      post baby_profile_allergen_tests_path(baby_profiles(:beta_baby)), params: { allergen_test: { allergen: "X" } }
    end
    assert_response :not_found
  end

  test "cannot destroy another household's allergen test" do
    test_record = baby_profiles(:beta_baby).allergen_tests.create!(allergen: "Gluten Beta")
    assert_no_difference -> { AllergenTest.count } do
      delete baby_profile_allergen_test_path(baby_profiles(:beta_baby), test_record)
    end
    assert_response :not_found
  end
end
