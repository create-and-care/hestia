class CreateRecipes < ActiveRecord::Migration[8.1]
  def change
    create_table :recipes do |t|
      t.references :household, null: false, foreign_key: true
      t.string :title, null: false
      t.string :category
      t.string :tags, array: true, default: [], null: false
      t.integer :prep_time_minutes
      t.integer :cook_time_minutes
      t.integer :servings
      t.string :source_url

      t.timestamps
    end
  end
end
