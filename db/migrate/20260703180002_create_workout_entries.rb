class CreateWorkoutEntries < ActiveRecord::Migration[8.1]
  def change
    create_table :workout_entries do |t|
      t.references :user, null: false, foreign_key: true
      t.date :done_on, null: false
      t.string :exercise, null: false
      t.integer :duration_minutes

      t.timestamps
    end
  end
end
