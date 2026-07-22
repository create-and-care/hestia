class AddDefaultWateringIntervalDaysToPlantReferences < ActiveRecord::Migration[8.1]
  def change
    add_column :plant_references, :default_watering_interval_days, :integer
  end
end
