class CreatePlants < ActiveRecord::Migration[8.1]
  def change
    create_table :plants do |t|
      t.references :household, null: false, foreign_key: true
      t.string :name, null: false
      t.string :location
      t.text :notes

      t.timestamps
    end
  end
end
