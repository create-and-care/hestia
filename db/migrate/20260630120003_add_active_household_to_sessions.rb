class AddActiveHouseholdToSessions < ActiveRecord::Migration[8.1]
  def change
    add_reference :sessions, :active_household, null: true,
      foreign_key: { to_table: :households }
  end
end
