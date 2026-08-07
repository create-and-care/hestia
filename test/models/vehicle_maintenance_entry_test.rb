require "test_helper"
require "turbo/broadcastable/test_helper"

class VehicleMaintenanceEntryTest < ActiveSupport::TestCase
  include Turbo::Broadcastable::TestHelper
  include ActiveJob::TestHelper

  test "requires an entry_type" do
    entry = vehicles(:alpha_car).vehicle_maintenance_entries.build
    assert_not entry.valid?
    entry.entry_type = "Vidange"
    assert entry.valid?
  end

  test "belongs to a vehicle" do
    entry = vehicles(:alpha_car).vehicle_maintenance_entries.create!(entry_type: "Vidange")
    assert_equal vehicles(:alpha_car), entry.vehicle
  end

  test "chronological orders most recent done_on first" do
    vehicle = vehicles(:alpha_car)
    older = vehicle.vehicle_maintenance_entries.create!(entry_type: "Vidange", done_on: Date.current - 1.year)
    newer = vehicle.vehicle_maintenance_entries.create!(entry_type: "Pneus", done_on: Date.current - 1.month)
    scoped = vehicle.vehicle_maintenance_entries.where(id: [ older.id, newer.id ]).chronological
    assert_equal [ newer, older ], scoped.to_a
  end

  test "destroyed when its vehicle is destroyed" do
    vehicle = vehicles(:alpha_car)
    vehicle.vehicle_maintenance_entries.create!(entry_type: "Vidange")
    assert_difference -> { VehicleMaintenanceEntry.count }, -1 do
      vehicle.destroy
    end
  end

  test "rejects a service provider from another household" do
    entry = vehicles(:alpha_car).vehicle_maintenance_entries.build(entry_type: "Vidange", service_provider: service_providers(:beta_provider))
    assert_not entry.valid?
    assert_includes entry.errors[:service_provider], error_message(:invalid)
  end

  test "accepts a service provider from the same household" do
    entry = vehicles(:alpha_car).vehicle_maintenance_entries.build(entry_type: "Vidange", service_provider: service_providers(:alpha_plombier))
    assert entry.valid?
  end

  test "broadcasts to its vehicle on create" do
    vehicle = vehicles(:alpha_car)
    assert_turbo_stream_broadcasts vehicle do
      perform_enqueued_jobs { vehicle.vehicle_maintenance_entries.create!(entry_type: "Vidange") }
    end
  end
end
