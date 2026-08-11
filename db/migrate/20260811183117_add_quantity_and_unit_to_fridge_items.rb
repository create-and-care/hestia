class AddQuantityAndUnitToFridgeItems < ActiveRecord::Migration[8.1]
  def change
    add_column :fridge_items, :quantity, :decimal, precision: 10, scale: 2
    add_column :fridge_items, :unit, :string
  end
end
