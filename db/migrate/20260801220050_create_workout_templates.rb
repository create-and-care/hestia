class CreateWorkoutTemplates < ActiveRecord::Migration[8.1]
  def change
    create_table :workout_templates do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name, null: false

      t.timestamps
    end

    create_table :workout_template_exercises do |t|
      t.references :workout_template, null: false, foreign_key: true
      t.string :exercise, null: false
      t.integer :duration_minutes
      t.integer :position, null: false, default: 0

      t.timestamps
    end

    add_reference :workout_entries, :workout_template, foreign_key: true
  end
end
