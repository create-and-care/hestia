require "test_helper"

class PetSuppliesControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as(users(:one)) }

  test "create adds a supply to the pet" do
    pet = pets(:alpha_dog)
    assert_difference -> { pet.pet_supplies.count }, 1 do
      post pet_supplies_path(pet), params: { pet_supply: { name: "Croquettes", order_url: "https://example.com", next_order_on: Date.current + 1.week } }
    end
    assert_redirected_to pet
  end

  test "destroy" do
    pet = pets(:alpha_dog)
    supply = pet.pet_supplies.create!(name: "Croquettes")
    delete pet_supply_path(pet, supply)
    assert_redirected_to pet
    assert_not PetSupply.exists?(supply.id)
  end

  test "cannot add a supply to another household's pet" do
    assert_no_difference -> { PetSupply.count } do
      post pet_supplies_path(pets(:beta_cat)), params: { pet_supply: { name: "X" } }
    end
    assert_response :not_found
  end

  test "cannot destroy another household's supply" do
    supply = pets(:beta_cat).pet_supplies.create!(name: "Litière Beta")
    assert_no_difference -> { PetSupply.count } do
      delete pet_supply_path(pets(:beta_cat), supply)
    end
    assert_response :not_found
  end
end
