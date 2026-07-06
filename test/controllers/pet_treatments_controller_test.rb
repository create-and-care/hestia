require "test_helper"

class PetTreatmentsControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as(users(:one)) }

  test "create adds a treatment to the pet" do
    pet = pets(:alpha_dog)
    assert_difference -> { pet.pet_treatments.count }, 1 do
      post pet_treatments_path(pet), params: { pet_treatment: { name: "Vermifuge", frequency: "Tous les 3 mois", quantity: "1 comprimé", price: 12.5 } }
    end
    assert_redirected_to pet
  end

  test "destroy" do
    pet = pets(:alpha_dog)
    treatment = pet.pet_treatments.create!(name: "Vermifuge")
    delete pet_treatment_path(pet, treatment)
    assert_redirected_to pet
    assert_not PetTreatment.exists?(treatment.id)
  end

  test "cannot add a treatment to another household's pet" do
    assert_no_difference -> { PetTreatment.count } do
      post pet_treatments_path(pets(:beta_cat)), params: { pet_treatment: { name: "X" } }
    end
    assert_response :not_found
  end

  test "cannot destroy another household's treatment" do
    treatment = pets(:beta_cat).pet_treatments.create!(name: "Traitement Beta")
    assert_no_difference -> { PetTreatment.count } do
      delete pet_treatment_path(pets(:beta_cat), treatment)
    end
    assert_response :not_found
  end
end
