class CreateRoutineCompletions < ActiveRecord::Migration[8.1]
  def change
    create_table :routine_completions do |t|
      t.references :routine, null: false, foreign_key: true
      t.references :author, foreign_key: { to_table: :users }
      t.date :completed_on, null: false

      t.timestamps
    end
  end
end
