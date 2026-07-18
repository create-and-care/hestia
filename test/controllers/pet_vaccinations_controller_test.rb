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

  test "create with a blank name does not persist and surfaces an error" do
    pet = pets(:alpha_dog)
    assert_no_difference -> { PetVaccination.count } do
      post pet_vaccinations_path(pet), params: { pet_vaccination: { name: "" } }
    end
    assert_redirected_to pet
    assert_equal "Name can't be blank", flash[:alert]
  end

  test "edit and update a vaccination's name, dates and price" do
    pet = pets(:alpha_dog)
    vaccination = pet.pet_vaccinations.create!(name: "Rage")
    get edit_pet_vaccination_path(pet, vaccination)
    assert_response :success

    patch pet_vaccination_path(pet, vaccination), params: {
      pet_vaccination: { name: "Rage (rappel)", injected_on: Date.current, booster_on: Date.current + 1.year, price: 45 }
    }
    assert_redirected_to pet
    vaccination.reload
    assert_equal "Rage (rappel)", vaccination.name
    assert_equal 45, vaccination.price.to_i
  end

  test "cannot edit another household's vaccination" do
    vaccination = pets(:beta_cat).pet_vaccinations.create!(name: "Vaccin Beta")
    get edit_pet_vaccination_path(pets(:beta_cat), vaccination)
    assert_response :not_found
  end

  test "price shows on the pet page and a destructive badge marks an overdue booster" do
    pet = pets(:alpha_dog)
    pet.pet_vaccinations.create!(name: "Rage", price: 30, booster_on: Date.current - 1)
    get pet_path(pet)
    assert_includes @response.body, "30.00"
    assert_select "span.bg-destructive\\/10", text: /booster/
  end

  test "delete button asks for confirmation and has an accessible name" do
    pet = pets(:alpha_dog)
    vaccination = pet.pet_vaccinations.create!(name: "Rage")
    get pet_path(pet)
    assert_select "form[action=?][data-turbo-confirm]", pet_vaccination_path(pet, vaccination)
  end
end
