class AddTimeZoneToHouseholds < ActiveRecord::Migration[8.1]
  def change
    add_column :households, :time_zone, :string, default: "UTC", null: false
  end
end
