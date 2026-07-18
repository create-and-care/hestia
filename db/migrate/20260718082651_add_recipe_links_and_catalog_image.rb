class AddRecipeLinksAndCatalogImage < ActiveRecord::Migration[8.1]
  def change
    add_column :recipe_catalog_entries, :image_url, :string

    add_reference :notes, :recipe, foreign_key: true, null: true
    add_reference :bottles, :recipe, foreign_key: true, null: true
  end
end
