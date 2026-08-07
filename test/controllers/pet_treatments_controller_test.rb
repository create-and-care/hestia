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

  test "create with a blank name does not persist and surfaces an error" do
    pet = pets(:alpha_dog)
    assert_no_difference -> { PetTreatment.count } do
      post pet_treatments_path(pet), params: { pet_treatment: { name: "" } }
    end
    assert_redirected_to pet
    assert_equal validation_message(PetTreatment, :name), flash[:alert]
  end

  test "edit and update a treatment's fields" do
    pet = pets(:alpha_dog)
    treatment = pet.pet_treatments.create!(name: "Vermifuge")
    get edit_pet_treatment_path(pet, treatment)
    assert_response :success

    patch pet_treatment_path(pet, treatment), params: {
      pet_treatment: { name: "Vermifuge", frequency: "Mensuel", quantity: "2 comprimés", price: 15 }
    }
    assert_redirected_to pet
    treatment.reload
    assert_equal "Mensuel", treatment.frequency
    assert_equal "2 comprimés", treatment.quantity
  end

  test "cannot edit another household's treatment" do
    treatment = pets(:beta_cat).pet_treatments.create!(name: "Traitement Beta")
    get edit_pet_treatment_path(pets(:beta_cat), treatment)
    assert_response :not_found
  end

  test "quantity and price show on the pet page" do
    pet = pets(:alpha_dog)
    pet.pet_treatments.create!(name: "Vermifuge", quantity: "2 comprimés", price: 15)
    get pet_path(pet)
    assert_includes @response.body, "2 comprimés"
    assert_body_includes ActiveSupport::NumberHelper.number_to_currency(15, unit: "€", format: "%n %u")
  end
end
