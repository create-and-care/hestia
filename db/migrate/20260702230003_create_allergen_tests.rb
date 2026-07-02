class CreateAllergenTests < ActiveRecord::Migration[8.1]
  def change
    create_table :allergen_tests do |t|
      t.references :baby_profile, null: false, foreign_key: true
      t.string :allergen, null: false
      t.date :tested_on
      t.string :severity

      t.timestamps
    end
  end
end
