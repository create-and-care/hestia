class CreatePetSupplies < ActiveRecord::Migration[8.1]
  def change
    create_table :pet_supplies do |t|
      t.references :pet, null: false, foreign_key: true
      t.string :name, null: false
      t.string :order_url
      t.date :next_order_on

      t.timestamps
    end
  end
end
