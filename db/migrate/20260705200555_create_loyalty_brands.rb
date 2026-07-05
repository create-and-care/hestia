class CreateLoyaltyBrands < ActiveRecord::Migration[8.1]
  def change
    create_table :loyalty_brands do |t|
      t.string :name, null: false
      t.string :logo_emoji
      t.string :code_format, null: false, default: "barcode"

      t.timestamps
      t.index :name, unique: true
    end
  end
end
