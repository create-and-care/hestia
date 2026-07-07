class AddDisabledModulesToHouseholds < ActiveRecord::Migration[8.1]
  def change
    add_column :households, :disabled_modules, :string, array: true, null: false, default: []
  end
end
