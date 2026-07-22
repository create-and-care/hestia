class CreatePlantCareCompletions < ActiveRecord::Migration[8.1]
  def change
    create_table :plant_care_completions do |t|
      t.references :plant_care_task, null: false, foreign_key: true
      t.references :author, foreign_key: { to_table: :users }
      t.date :completed_on, null: false
      t.text :note

      t.timestamps
    end
  end
end
