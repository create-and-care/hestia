class CreatePoolActions < ActiveRecord::Migration[8.1]
  def change
    create_table :pool_actions do |t|
      t.references :pool, null: false, foreign_key: true
      t.date :done_on, null: false
      t.string :action_type, null: false
      t.text :note

      t.timestamps
    end
  end
end
