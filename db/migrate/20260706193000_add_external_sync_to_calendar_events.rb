class AddExternalSyncToCalendarEvents < ActiveRecord::Migration[8.1]
  def change
    add_reference :calendar_events, :external_calendar_connection, foreign_key: true, null: true
    add_column :calendar_events, :external_uid, :string

    add_index :calendar_events, [ :external_calendar_connection_id, :external_uid ],
      unique: true, name: "index_calendar_events_on_connection_and_external_uid"
  end
end
