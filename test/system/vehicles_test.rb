require "application_system_test_case"

class VehiclesTest < ApplicationSystemTestCase
  def sign_in_to_alpha
    visit new_session_path
    fill_in "email_address", with: users(:one).email_address
    fill_in "password", with: "password"
    click_on "Sign in"
    assert_text households(:alpha).name
  end

  test "choosing a predefined type creates the vehicle with that type" do
    sign_in_to_alpha
    visit new_vehicle_path

    fill_in "vehicle_name", with: "Le camion"
    select "Truck", from: "vehicle_vehicle_type"
    click_on "Save"

    assert_text "Le camion"
    assert_equal "truck", Vehicle.find_by!(name: "Le camion").vehicle_type
  end

  test "choosing Other reveals a custom field to set a free-text type" do
    sign_in_to_alpha
    visit new_vehicle_path

    fill_in "vehicle_name", with: "Le quad"
    select "Other…", from: "vehicle_vehicle_type"
    assert_selector "#vehicle_vehicle_type_custom"
    fill_in "vehicle_vehicle_type_custom", with: "Quad"
    click_on "Save"

    assert_text "Le quad"
    assert_equal "Quad", Vehicle.find_by!(name: "Le quad").vehicle_type
  end
end
