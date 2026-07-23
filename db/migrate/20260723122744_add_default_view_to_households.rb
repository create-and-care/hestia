class AddDefaultViewToHouseholds < ActiveRecord::Migration[8.1]
  def change
    add_column :households, :default_view, :string, default: "list", null: false
  end
end
