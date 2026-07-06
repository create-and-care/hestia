require "test_helper"

class PlantsControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as(users(:one)) }

  test "create adds a plant to the household" do
    assert_difference -> { households(:alpha).plants.count }, 1 do
      post plants_path, params: { plant: { name: "Basilic", location: "Cuisine" } }
    end
    assert_redirected_to exterior_path
  end

  test "destroy removes the plant" do
    plant = plants(:alpha_rose)
    delete plant_path(plant)
    assert_redirected_to exterior_path
    assert_not Plant.exists?(plant.id)
  end

  test "cannot destroy another household's plant" do
    assert_no_difference -> { Plant.count } do
      delete plant_path(plants(:beta_plant))
    end
    assert_response :not_found
  end
end
