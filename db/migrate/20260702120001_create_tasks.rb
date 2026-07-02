class CreateTasks < ActiveRecord::Migration[8.1]
  def change
    create_table :tasks do |t|
      t.references :household, null: false, foreign_key: true
      t.references :task_category, foreign_key: true
      t.references :assignee, foreign_key: { to_table: :users }
      t.string :title, null: false
      t.text :description
      t.string :emoji
      t.date :due_on
      t.integer :position, null: false, default: 0
      t.boolean :done, null: false, default: false

      t.timestamps
    end
  end
end
