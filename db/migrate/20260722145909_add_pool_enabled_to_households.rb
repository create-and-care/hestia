class AddPoolEnabledToHouseholds < ActiveRecord::Migration[8.1]
  def change
    add_column :households, :pool_enabled, :boolean, default: true, null: false
  end
end
