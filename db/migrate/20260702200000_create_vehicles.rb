class CreateVehicles < ActiveRecord::Migration[8.1]
  def change
    create_table :vehicles do |t|
      t.references :household, null: false, foreign_key: true
      t.string :name, null: false
      t.string :vehicle_type, null: false, default: "car"
      t.string :manufacturer
      t.string :plate
      t.integer :year
      t.string :energy
      t.date :inspection_expires_on

      t.timestamps
    end
  end
end
