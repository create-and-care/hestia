class CreatePetVaccinations < ActiveRecord::Migration[8.1]
  def change
    create_table :pet_vaccinations do |t|
      t.references :pet, null: false, foreign_key: true
      t.string :name, null: false
      t.date :injected_on
      t.date :booster_on
      t.decimal :price, precision: 8, scale: 2

      t.timestamps
    end
  end
end
