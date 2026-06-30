class CreateShoppingListItems < ActiveRecord::Migration[8.1]
  def change
    create_table :shopping_list_items do |t|
      t.references :shopping_list, null: false, foreign_key: true
      t.references :product, foreign_key: true
      t.string :name, null: false
      t.decimal :quantity, precision: 10, scale: 2
      t.string :unit
      t.string :rayon
      t.boolean :checked, null: false, default: false
      t.integer :position, null: false, default: 0

      t.timestamps
    end
  end
end
