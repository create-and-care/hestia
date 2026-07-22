class CreatePlantCareTasks < ActiveRecord::Migration[8.1]
  def change
    create_table :plant_care_tasks do |t|
      t.references :plant, null: false, foreign_key: true
      t.string :care_type, null: false
      t.string :frequency, null: false, default: "weekly"
      t.integer :interval, null: false, default: 1
      t.date :next_due_on

      t.timestamps
    end
  end
end
