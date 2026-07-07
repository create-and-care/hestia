class AddRecipeToShoppingListItems < ActiveRecord::Migration[8.1]
  def change
    add_reference :shopping_list_items, :recipe, null: true, foreign_key: true
  end
end
