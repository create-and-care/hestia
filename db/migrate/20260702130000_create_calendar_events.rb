class CreateCalendarEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :calendar_events do |t|
      t.references :household, null: false, foreign_key: true
      t.string :title, null: false
      t.datetime :starts_at, null: false
      t.datetime :ends_at
      t.boolean :all_day, null: false, default: false
      t.string :location
      t.string :color, null: false, default: "blue"
      t.string :frequency, null: false, default: "none"
      t.integer :recurrence_interval, null: false, default: 1
      t.date :recurrence_until

      t.timestamps
    end

    add_index :calendar_events, [ :household_id, :starts_at ]
  end
end
