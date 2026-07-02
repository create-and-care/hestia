class CreateVehicleMaintenanceEntries < ActiveRecord::Migration[8.1]
  def change
    create_table :vehicle_maintenance_entries do |t|
      t.references :vehicle, null: false, foreign_key: true
      t.string :entry_type
      t.date :done_on
      t.decimal :cost, precision: 10, scale: 2
      t.string :provider
      t.text :description

      t.timestamps
    end
  end
end
