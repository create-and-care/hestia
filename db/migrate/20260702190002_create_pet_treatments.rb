class CreatePetTreatments < ActiveRecord::Migration[8.1]
  def change
    create_table :pet_treatments do |t|
      t.references :pet, null: false, foreign_key: true
      t.string :name, null: false
      t.string :frequency
      t.string :quantity
      t.date :last_done_on
      t.decimal :price, precision: 8, scale: 2

      t.timestamps
    end
  end
end
