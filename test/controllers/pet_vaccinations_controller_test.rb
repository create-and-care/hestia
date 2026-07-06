require "test_helper"

class PetVaccinationsControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as(users(:one)) }

  test "create adds a vaccination to the pet" do
    pet = pets(:alpha_dog)
    assert_difference -> { pet.pet_vaccinations.count }, 1 do
      post pet_vaccinations_path(pet), params: { pet_vaccination: { name: "Rage", injected_on: Date.current, booster_on: Date.current + 1.year } }
    end
    assert_redirected_to pet
  end

  test "destroy" do
    pet = pets(:alpha_dog)
    vaccination = pet.pet_vaccinations.create!(name: "Rage")
    delete pet_vaccination_path(pet, vaccination)
    assert_redirected_to pet
    assert_not PetVaccination.exists?(vaccination.id)
  end

  test "cannot add a vaccination to another household's pet" do
    assert_no_difference -> { PetVaccination.count } do
      post pet_vaccinations_path(pets(:beta_cat)), params: { pet_vaccination: { name: "X" } }
    end
    assert_response :not_found
  end

  test "cannot destroy another household's vaccination" do
    vaccination = pets(:beta_cat).pet_vaccinations.create!(name: "Vaccin Beta")
    assert_no_difference -> { PetVaccination.count } do
      delete pet_vaccination_path(pets(:beta_cat), vaccination)
    end
    assert_response :not_found
  end
end
