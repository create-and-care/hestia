class CreateTrips < ActiveRecord::Migration[8.1]
  def change
    create_table :trips do |t|
      t.references :household, null: false, foreign_key: true
      t.string :name, null: false
      t.date :starts_on
      t.date :ends_on

      t.timestamps
    end
  end
end
