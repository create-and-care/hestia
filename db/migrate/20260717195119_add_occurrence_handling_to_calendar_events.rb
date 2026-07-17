class AddOccurrenceHandlingToCalendarEvents < ActiveRecord::Migration[8.1]
  def change
    add_column :calendar_events, :excluded_occurrences, :date, array: true, default: [], null: false
    add_column :calendar_events, :event_type, :string
    add_column :users, :calendar_view, :string, default: "month", null: false
  end
end
