class CreateNotes < ActiveRecord::Migration[8.1]
  def change
    create_table :notes do |t|
      t.references :household, null: false, foreign_key: true
      t.references :author, foreign_key: { to_table: :users }
      t.string :title, null: false
      t.text :content
      t.boolean :favorite, null: false, default: false
      t.boolean :archived, null: false, default: false

      t.timestamps
    end

    add_index :notes, [ :household_id, :archived ]
  end
end
