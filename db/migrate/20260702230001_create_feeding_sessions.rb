class CreateFeedingSessions < ActiveRecord::Migration[8.1]
  def change
    create_table :feeding_sessions do |t|
      t.references :baby_profile, null: false, foreign_key: true
      t.string :kind, null: false, default: "bottle"
      t.datetime :started_at
      t.datetime :ended_at

      t.timestamps
    end
  end
end
