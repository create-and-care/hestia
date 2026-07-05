class CreateTaskReminders < ActiveRecord::Migration[8.1]
  def change
    create_table :task_reminders do |t|
      t.references :task, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.datetime :remind_at, null: false
      t.datetime :delivered_at

      t.timestamps
    end
  end
end
