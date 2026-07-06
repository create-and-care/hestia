class AddLastSyncedAtToExternalCalendarConnections < ActiveRecord::Migration[8.1]
  def change
    add_column :external_calendar_connections, :last_synced_at, :datetime
  end
end
