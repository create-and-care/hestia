class CreatePets < ActiveRecord::Migration[8.1]
  def change
    create_table :pets do |t|
      t.references :household, null: false, foreign_key: true
      t.string :name, null: false
      t.string :species
      t.string :breed
      t.decimal :weight, precision: 6, scale: 2
      t.string :identifier
      t.date :born_on

      t.timestamps
    end
  end
end
