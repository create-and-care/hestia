require "test_helper"

class VehicleTest < ActiveSupport::TestCase
  test "requires a name" do
    vehicle = households(:alpha).vehicles.build
    assert_not vehicle.valid?
    vehicle.name = "X"
    assert vehicle.valid?
  end

  test "inspection_status from thresholds" do
    vehicle = Vehicle.new
    assert_equal :none, vehicle.inspection_status

    vehicle.inspection_expires_on = Date.current - 1
    assert_equal :expired, vehicle.inspection_status

    vehicle.inspection_expires_on = Date.current + 20
    assert_equal :urgent, vehicle.inspection_status

    vehicle.inspection_expires_on = Date.current + 60
    assert_equal :soon, vehicle.inspection_status

    vehicle.inspection_expires_on = Date.current + 200
    assert_equal :ok, vehicle.inspection_status
  end

  test "is scoped to its household" do
    assert_not_includes households(:alpha).vehicles, vehicles(:beta_car)
  end

  test "can have a photo attached" do
    vehicle = vehicles(:alpha_car)
    vehicle.photo.attach(io: File.open(Rails.root.join("test/fixtures/files/sample.png")), filename: "sample.png", content_type: "image/png")
    assert vehicle.photo.attached?
  end
end
