class CreateEventReminders < ActiveRecord::Migration[8.1]
  def change
    create_table :event_reminders do |t|
      t.references :calendar_event, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.integer :minutes_before, null: false, default: 30
      t.datetime :last_notified_occurrence_at

      t.timestamps
    end
  end
end
