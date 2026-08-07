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

  test "show lists documents linked to the vehicle" do
    document = households(:alpha).documents.build(name: "Carte grise", documentable: vehicles(:alpha_car))
    document.file.attach(io: File.open(Rails.root.join("test/fixtures/files/sample.pdf")), filename: "sample.pdf", content_type: "application/pdf")
    document.save!

    get vehicle_path(vehicles(:alpha_car))
    assert_response :success
    assert_includes @response.body, "Carte grise"
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

  test "create with a custom (free-text) vehicle type" do
    post vehicles_path, params: { vehicle: { name: "Le quad", vehicle_type: "Quad" } }
    assert_equal "Quad", Vehicle.find_by!(name: "Le quad").vehicle_type
  end

  test "the new-vehicle form offers a predefined type list plus a custom fallback field" do
    get new_vehicle_path
    assert_response :success
    assert_select "select#vehicle_vehicle_type option", text: I18n.t("vehicles.types.car")
    assert_select "select#vehicle_vehicle_type option", text: I18n.t("vehicles.types.other")
    assert_select "input#vehicle_vehicle_type_custom"
  end

  test "create attaches an optional photo" do
    photo = fixture_file_upload("sample.png", "image/png")
    post vehicles_path, params: { vehicle: { name: "Le van", photo: photo } }
    assert Vehicle.find_by!(name: "Le van").photo.attached?
  end

  test "urgent and soon inspection statuses use different badge colors" do
    urgent = households(:alpha).vehicles.create!(name: "Urgent", inspection_expires_on: 10.days.from_now.to_date)
    soon = households(:alpha).vehicles.create!(name: "Soon", inspection_expires_on: 60.days.from_now.to_date)

    get vehicles_path
    assert_select "##{dom_id(urgent)} span.bg-destructive\\/10"
    assert_select "##{dom_id(soon)} span.bg-warning\\/10"
  end

  test "delete button asks for confirmation and has an accessible name" do
    vehicle = vehicles(:alpha_car)
    get vehicles_path
    assert_select "form[action=?][data-turbo-confirm]", vehicle_path(vehicle)
    assert_select "a[href=?][aria-label=?]", edit_vehicle_path(vehicle), I18n.t("vehicles.vehicle.edit_aria", name: vehicle.name)
  end
end
