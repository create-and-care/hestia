class CreateContactTaggings < ActiveRecord::Migration[8.1]
  def change
    create_table :contact_taggings do |t|
      t.references :contact, null: false, foreign_key: true
      t.references :contact_tag, null: false, foreign_key: true

      t.timestamps
    end

    add_index :contact_taggings, [ :contact_id, :contact_tag_id ], unique: true
  end
end
