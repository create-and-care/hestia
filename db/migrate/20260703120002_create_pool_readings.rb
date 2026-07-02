class CreatePoolReadings < ActiveRecord::Migration[8.1]
  def change
    create_table :pool_readings do |t|
      t.references :pool, null: false, foreign_key: true
      t.date :measured_on, null: false
      t.string :measure_type, null: false
      t.decimal :value, precision: 8, scale: 2

      t.timestamps
    end
  end
end
