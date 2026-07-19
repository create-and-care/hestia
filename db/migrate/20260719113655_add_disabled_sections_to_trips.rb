class AddDisabledSectionsToTrips < ActiveRecord::Migration[8.1]
  def change
    add_column :trips, :disabled_sections, :string, array: true, default: [], null: false
  end
end
