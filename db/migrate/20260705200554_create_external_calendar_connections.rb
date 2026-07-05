class CreateExternalCalendarConnections < ActiveRecord::Migration[8.1]
  def change
    create_table :external_calendar_connections do |t|
      t.references :user, null: false, foreign_key: true
      t.string :provider, null: false
      t.text :access_token
      t.text :refresh_token
      t.datetime :expires_at
      t.string :external_calendar_id
      t.string :caldav_url
      t.boolean :active, null: false, default: true

      t.timestamps
    end
  end
end
