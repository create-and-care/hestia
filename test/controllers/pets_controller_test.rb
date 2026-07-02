require "test_helper"

class PetsControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as(users(:one)) }

  test "index requires authentication" do
    sign_out
    get pets_path
    assert_redirected_to new_session_path
  end

  test "index shows the household's pets only" do
    get pets_path
    assert_response :success
    assert_includes @response.body, "Rex"
    assert_not_includes @response.body, "Minou"
  end

  test "show" do
    get pet_path(pets(:alpha_dog))
    assert_response :success
    assert_includes @response.body, "Rex"
  end

  test "create" do
    assert_difference -> { households(:alpha).pets.count }, 1 do
      post pets_path, params: { pet: { name: "Félix", species: "Chat" } }
    end
    assert_redirected_to Pet.find_by(name: "Félix")
  end

  test "add and remove a vaccination" do
    pet = pets(:alpha_dog)
    assert_difference -> { pet.pet_vaccinations.count }, 1 do
      post pet_vaccinations_path(pet), params: { pet_vaccination: { name: "Rage", injected_on: Date.current } }
    end
    assert_redirected_to pet
  end

  test "add a treatment and a supply" do
    pet = pets(:alpha_dog)
    post pet_treatments_path(pet), params: { pet_treatment: { name: "Vermifuge", frequency: "Tous les 3 mois" } }
    post pet_supplies_path(pet), params: { pet_supply: { name: "Croquettes" } }
    assert_equal 1, pet.pet_treatments.count
    assert_equal 1, pet.pet_supplies.count
  end

  test "destroy" do
    pet = pets(:alpha_dog)
    delete pet_path(pet)
    assert_redirected_to pets_path
    assert_not Pet.exists?(pet.id)
  end

  test "cannot access another household's pet" do
    get pet_path(pets(:beta_cat))
    assert_response :not_found
  end

  test "cannot add records to another household's pet" do
    assert_no_difference -> { PetVaccination.count } do
      post pet_vaccinations_path(pets(:beta_cat)), params: { pet_vaccination: { name: "X" } }
    end
    assert_response :not_found
  end
end
