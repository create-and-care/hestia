class AddServiceProviderToVehicleMaintenanceEntries < ActiveRecord::Migration[8.1]
  def change
    add_reference :vehicle_maintenance_entries, :service_provider, null: true, foreign_key: true
  end
end
