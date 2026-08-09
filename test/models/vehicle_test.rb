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
    assert_equal :destructive, vehicle.inspection_status

    vehicle.inspection_expires_on = Date.current + 60
    assert_equal :soon, vehicle.inspection_status

    vehicle.inspection_expires_on = Date.current + 200
    assert_equal :ok, vehicle.inspection_status
  end

  test "is scoped to its household" do
    assert_not_includes households(:alpha).vehicles, vehicles(:beta_car)
  end

  test "inspection_due matches exactly the vehicles inspection_status flags" do
    household = households(:alpha)
    household.vehicles.destroy_all
    expired = household.vehicles.create!(name: "Périmée", inspection_expires_on: 1.day.ago.to_date)
    urgent = household.vehicles.create!(name: "Urgente", inspection_expires_on: Vehicle::INSPECTION_URGENT_DAYS.days.from_now.to_date)
    soon = household.vehicles.create!(name: "Bientôt", inspection_expires_on: 60.days.from_now.to_date)
    household.vehicles.create!(name: "Sans contrôle", inspection_expires_on: nil)

    assert_equal [ expired, urgent ], household.vehicles.inspection_due.to_a
    assert_equal :soon, soon.inspection_status
  end

  test "can have a photo attached" do
    vehicle = vehicles(:alpha_car)
    vehicle.photo.attach(io: File.open(Rails.root.join("test/fixtures/files/sample.png")), filename: "sample.png", content_type: "image/png")
    assert vehicle.photo.attached?
  end
end
