require "test_helper"

class FoodIntroductionsControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as(users(:one)) }

  test "create adds a food introduction to the baby profile" do
    baby = baby_profiles(:alpha_baby)
    assert_difference -> { baby.food_introductions.count }, 1 do
      post baby_profile_food_introductions_path(baby), params: { food_introduction: { food: "Carotte", introduced_on: Date.current, acceptance: "Aimé" } }
    end
    assert_redirected_to baby
  end

  test "destroy" do
    baby = baby_profiles(:alpha_baby)
    introduction = baby.food_introductions.create!(food: "Carotte")
    delete baby_profile_food_introduction_path(baby, introduction)
    assert_redirected_to baby
    assert_not FoodIntroduction.exists?(introduction.id)
  end

  test "cannot add a food introduction to another household's baby" do
    assert_no_difference -> { FoodIntroduction.count } do
      post baby_profile_food_introductions_path(baby_profiles(:beta_baby)), params: { food_introduction: { food: "X" } }
    end
    assert_response :not_found
  end

  test "cannot destroy another household's food introduction" do
    introduction = baby_profiles(:beta_baby).food_introductions.create!(food: "Pomme Beta")
    assert_no_difference -> { FoodIntroduction.count } do
      delete baby_profile_food_introduction_path(baby_profiles(:beta_baby), introduction)
    end
    assert_response :not_found
  end

  test "create gives a success flash notice" do
    baby = baby_profiles(:alpha_baby)
    post baby_profile_food_introductions_path(baby), params: { food_introduction: { food: "Carotte" } }
    follow_redirect!
    assert_body_includes I18n.t("food_introductions.create.created")
  end

  test "create with a blank food does not persist and surfaces an error" do
    baby = baby_profiles(:alpha_baby)
    assert_no_difference -> { FoodIntroduction.count } do
      post baby_profile_food_introductions_path(baby), params: { food_introduction: { food: "" } }
    end
    assert_redirected_to baby
    assert_equal validation_message(FoodIntroduction, :food), flash[:alert]
  end

  test "edit and update a food introduction" do
    baby = baby_profiles(:alpha_baby)
    introduction = baby.food_introductions.create!(food: "Carotte")

    get edit_baby_profile_food_introduction_path(baby, introduction)
    assert_response :success

    patch baby_profile_food_introduction_path(baby, introduction), params: { food_introduction: { acceptance: "Aimé" } }
    assert_redirected_to baby
    assert_equal "Aimé", introduction.reload.acceptance
  end

  test "cannot edit another household's food introduction" do
    introduction = baby_profiles(:beta_baby).food_introductions.create!(food: "Pomme Beta")
    get edit_baby_profile_food_introduction_path(baby_profiles(:beta_baby), introduction)
    assert_response :not_found
  end
end
