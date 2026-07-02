class CreatePreparedDishes < ActiveRecord::Migration[8.1]
  def change
    create_table :prepared_dishes do |t|
      t.references :household, null: false, foreign_key: true
      t.string :name, null: false
      t.string :location, null: false
      t.date :expires_on

      t.timestamps
    end

    add_index :prepared_dishes, [ :household_id, :location ]
  end
end
