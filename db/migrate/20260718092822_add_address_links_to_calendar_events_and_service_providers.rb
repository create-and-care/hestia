class AddAddressLinksToCalendarEventsAndServiceProviders < ActiveRecord::Migration[8.1]
  def change
    add_reference :calendar_events, :address, null: true, foreign_key: true
    add_reference :service_providers, :linked_address, null: true, foreign_key: { to_table: :addresses }
  end
end
