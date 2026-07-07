class AddRecipeCatalogEntryToRecipes < ActiveRecord::Migration[8.1]
  def change
    add_reference :recipes, :recipe_catalog_entry, null: true, foreign_key: true
  end
end
