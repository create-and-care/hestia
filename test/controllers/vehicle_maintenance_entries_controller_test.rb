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

  test "create with a blank entry_type does not persist and surfaces an error" do
    vehicle = vehicles(:alpha_car)
    assert_no_difference -> { VehicleMaintenanceEntry.count } do
      post vehicle_maintenance_entries_path(vehicle), params: { vehicle_maintenance_entry: { entry_type: "" } }
    end
    assert_redirected_to vehicle
    assert_equal validation_message(VehicleMaintenanceEntry, :entry_type), flash[:alert]
  end

  test "records a description and a linked service provider" do
    vehicle = vehicles(:alpha_car)
    provider = service_providers(:alpha_plombier)
    post vehicle_maintenance_entries_path(vehicle), params: {
      vehicle_maintenance_entry: { entry_type: "oil_change", description: "Huile synthétique 5W30", service_provider_id: provider.id }
    }
    entry = vehicle.vehicle_maintenance_entries.order(:id).last
    assert_equal "Huile synthétique 5W30", entry.description
    assert_equal provider, entry.service_provider
  end

  test "cannot link a service provider from another household" do
    vehicle = vehicles(:alpha_car)
    assert_no_difference -> { VehicleMaintenanceEntry.count } do
      post vehicle_maintenance_entries_path(vehicle), params: {
        vehicle_maintenance_entry: { entry_type: "oil_change", service_provider_id: service_providers(:beta_provider).id }
      }
    end
    assert_redirected_to vehicle
  end

  test "delete button asks for confirmation and has an accessible name" do
    vehicle = vehicles(:alpha_car)
    entry = vehicle.vehicle_maintenance_entries.create!(entry_type: "oil_change")
    get vehicle_path(vehicle)
    assert_select "form[action=?][data-turbo-confirm]", vehicle_maintenance_entry_path(vehicle, entry)
  end

  test "description and provider show on the vehicle page" do
    vehicle = vehicles(:alpha_car)
    vehicle.vehicle_maintenance_entries.create!(entry_type: "oil_change", description: "Huile synthétique", provider: "Garage Dupont")
    get vehicle_path(vehicle)
    assert_includes @response.body, "Huile synthétique"
    assert_includes @response.body, "Garage Dupont"
  end
end
