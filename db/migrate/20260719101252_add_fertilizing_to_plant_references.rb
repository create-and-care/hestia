class AddFertilizingToPlantReferences < ActiveRecord::Migration[8.1]
  def change
    add_column :plant_references, :fertilizing, :text
  end
end
