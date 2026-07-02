class CreateAddresses < ActiveRecord::Migration[8.1]
  def change
    create_table :addresses do |t|
      t.references :household, null: false, foreign_key: true
      t.string :address_type, null: false, default: "autre"
      t.string :name, null: false
      t.text :full_address
      t.decimal :latitude, precision: 10, scale: 6
      t.decimal :longitude, precision: 10, scale: 6
      t.string :phone
      t.integer :rating

      t.timestamps
    end

    add_index :addresses, [ :household_id, :address_type ]
  end
end
