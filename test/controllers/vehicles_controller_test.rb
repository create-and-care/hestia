require "test_helper"

class VehiclesControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as(users(:one)) }

  test "index requires authentication" do
    sign_out
    get vehicles_path
    assert_redirected_to new_session_path
  end

  test "index shows the household's vehicles only" do
    get vehicles_path
    assert_response :success
    assert_includes @response.body, "La Clio"
    assert_not_includes @response.body, "Voiture Beta"
  end

  test "search by manufacturer" do
    get vehicles_path(q: "renault")
    assert_response :success
    assert_includes @response.body, "La Clio"
  end

  test "create" do
    assert_difference -> { households(:alpha).vehicles.count }, 1 do
      post vehicles_path, params: { vehicle: { name: "Le scooter", vehicle_type: "motorcycle" } }
    end
    assert_redirected_to Vehicle.find_by(name: "Le scooter")
  end

  test "add a maintenance entry" do
    vehicle = vehicles(:alpha_car)
    assert_difference -> { vehicle.vehicle_maintenance_entries.count }, 1 do
      post vehicle_maintenance_entries_path(vehicle), params: { vehicle_maintenance_entry: { entry_type: "Vidange", cost: 90 } }
    end
    assert_redirected_to vehicle
  end

  test "destroy" do
    vehicle = vehicles(:alpha_car)
    delete vehicle_path(vehicle)
    assert_redirected_to vehicles_path
    assert_not Vehicle.exists?(vehicle.id)
  end

  test "cannot access another household's vehicle" do
    get vehicle_path(vehicles(:beta_car))
    assert_response :not_found
  end
end
