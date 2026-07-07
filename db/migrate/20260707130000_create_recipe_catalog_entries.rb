class CreateRecipeCatalogEntries < ActiveRecord::Migration[8.1]
  def change
    create_table :recipe_catalog_entries do |t|
      t.string :source_url, null: false
      t.string :title, null: false
      t.string :tags, array: true, default: [], null: false
      t.integer :prep_time_minutes
      t.integer :cook_time_minutes
      t.integer :servings
      t.jsonb :ingredients, default: [], null: false
      t.jsonb :steps, default: [], null: false
      t.datetime :last_synced_at

      t.timestamps
    end
    add_index :recipe_catalog_entries, :source_url, unique: true
  end
end
