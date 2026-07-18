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

  test "create with a blank name does not persist and surfaces an error" do
    pet = pets(:alpha_dog)
    assert_no_difference -> { PetSupply.count } do
      post pet_supplies_path(pet), params: { pet_supply: { name: "" } }
    end
    assert_redirected_to pet
    assert_equal "Name can't be blank", flash[:alert]
  end

  test "edit and update a supply's fields" do
    pet = pets(:alpha_dog)
    supply = pet.pet_supplies.create!(name: "Croquettes")
    get edit_pet_supply_path(pet, supply)
    assert_response :success

    patch pet_supply_path(pet, supply), params: { pet_supply: { name: "Croquettes premium", order_url: "https://example.com" } }
    assert_redirected_to pet
    assert_equal "Croquettes premium", supply.reload.name
  end

  test "cannot edit another household's supply" do
    supply = pets(:beta_cat).pet_supplies.create!(name: "Litière Beta")
    get edit_pet_supply_path(pets(:beta_cat), supply)
    assert_response :not_found
  end

  test "add_to_shopping_list exports the supply to the household's shopping list" do
    pet = pets(:alpha_dog)
    supply = pet.pet_supplies.create!(name: "Croquettes")
    assert_difference -> { ShoppingListItem.count }, 1 do
      post add_to_shopping_list_pet_supply_path(pet, supply)
    end
    assert_redirected_to pet
    follow_redirect!
    assert_includes @response.body, "Croquettes"
  end

  test "cannot export another household's supply to the shopping list" do
    supply = pets(:beta_cat).pet_supplies.create!(name: "Litière Beta")
    assert_no_difference -> { ShoppingListItem.count } do
      post add_to_shopping_list_pet_supply_path(pets(:beta_cat), supply)
    end
    assert_response :not_found
  end
end
