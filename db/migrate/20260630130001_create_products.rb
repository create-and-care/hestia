class CreateProducts < ActiveRecord::Migration[8.1]
  def change
    create_table :products do |t|
      t.references :household, null: false, foreign_key: true
      t.string :name, null: false
      t.string :brand
      t.string :rayon
      t.string :barcode

      t.timestamps
    end

    add_index :products, [ :household_id, :name ], unique: true
    add_index :products, :barcode
  end
end
