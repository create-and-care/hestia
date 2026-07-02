class CreateFridgeItems < ActiveRecord::Migration[8.1]
  def change
    create_table :fridge_items do |t|
      t.references :household, null: false, foreign_key: true
      t.references :product, foreign_key: true
      t.string :name, null: false
      t.string :location, null: false
      t.date :expires_on

      t.timestamps
    end

    add_index :fridge_items, [ :household_id, :location ]
  end
end
