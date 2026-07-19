require "test_helper"

class PlantsControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as(users(:one)) }

  test "create adds a plant to the household" do
    assert_difference -> { households(:alpha).plants.count }, 1 do
      post plants_path, params: { plant: { name: "Basilic", location: "Cuisine" } }
    end
    assert_redirected_to exterior_path
  end

  test "create attaches an optional photo" do
    photo = fixture_file_upload("sample.png", "image/png")
    post plants_path, params: { plant: { name: "Basilic", photo: photo } }
    assert Plant.find_by!(name: "Basilic").photo.attached?
  end

  test "create with a blank name redirects with an error instead of failing silently" do
    assert_no_difference -> { Plant.count } do
      post plants_path, params: { plant: { name: "" } }
    end
    assert_redirected_to exterior_path
    assert_not_nil flash[:alert]
  end

  test "edit" do
    get edit_plant_path(plants(:alpha_rose))
    assert_response :success
  end

  test "cannot edit another household's plant" do
    get edit_plant_path(plants(:beta_plant))
    assert_response :not_found
  end

  test "update" do
    plant = plants(:alpha_rose)
    patch plant_path(plant), params: { plant: { name: "Rosier grimpant" } }
    assert_redirected_to exterior_path
    assert_equal "Rosier grimpant", plant.reload.name
  end

  test "update with a blank name re-renders the edit form" do
    plant = plants(:alpha_rose)
    patch plant_path(plant), params: { plant: { name: "" } }
    assert_response :unprocessable_entity
    assert_equal "Rosier", plant.reload.name
  end

  test "cannot update another household's plant" do
    patch plant_path(plants(:beta_plant)), params: { plant: { name: "X" } }
    assert_response :not_found
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
