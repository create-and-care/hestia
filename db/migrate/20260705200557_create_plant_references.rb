class CreatePlantReferences < ActiveRecord::Migration[8.1]
  def change
    create_table :plant_references do |t|
      t.string :common_name, null: false
      t.string :scientific_name
      t.string :water_needs
      t.string :sunlight
      t.text :pruning
      t.text :common_diseases

      t.timestamps
      t.index :common_name, unique: true
    end
  end
end
