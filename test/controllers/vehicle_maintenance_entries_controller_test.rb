require "test_helper"

class VehicleMaintenanceEntriesControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as(users(:one)) }

  test "create adds a maintenance entry to the vehicle" do
    vehicle = vehicles(:alpha_car)
    assert_difference -> { vehicle.vehicle_maintenance_entries.count }, 1 do
      post vehicle_maintenance_entries_path(vehicle), params: { vehicle_maintenance_entry: { entry_type: "Vidange", cost: 90, provider: "Garage Dupont", done_on: Date.current } }
    end
    assert_redirected_to vehicle
  end

  test "destroy" do
    vehicle = vehicles(:alpha_car)
    entry = vehicle.vehicle_maintenance_entries.create!(entry_type: "Vidange")
    delete vehicle_maintenance_entry_path(vehicle, entry)
    assert_redirected_to vehicle
    assert_not VehicleMaintenanceEntry.exists?(entry.id)
  end

  test "cannot add an entry to another household's vehicle" do
    assert_no_difference -> { VehicleMaintenanceEntry.count } do
      post vehicle_maintenance_entries_path(vehicles(:beta_car)), params: { vehicle_maintenance_entry: { entry_type: "X" } }
    end
    assert_response :not_found
  end

  test "cannot destroy another household's entry" do
    entry = vehicles(:beta_car).vehicle_maintenance_entries.create!(entry_type: "Entretien Beta")
    assert_no_difference -> { VehicleMaintenanceEntry.count } do
      delete vehicle_maintenance_entry_path(vehicles(:beta_car), entry)
    end
    assert_response :not_found
  end
end
