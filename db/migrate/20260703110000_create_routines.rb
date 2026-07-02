class CreateRoutines < ActiveRecord::Migration[8.1]
  def change
    create_table :routines do |t|
      t.references :household, null: false, foreign_key: true
      t.references :assignee, foreign_key: { to_table: :users }
      t.string :name, null: false
      t.string :emoji
      t.text :description
      t.string :frequency, null: false, default: "weekly"
      t.integer :interval, null: false, default: 1
      t.date :next_due_on
      t.string :list_name

      t.timestamps
    end
  end
end
