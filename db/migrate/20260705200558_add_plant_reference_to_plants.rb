class AddPlantReferenceToPlants < ActiveRecord::Migration[8.1]
  def change
    add_reference :plants, :plant_reference, null: true, foreign_key: true
  end
end
