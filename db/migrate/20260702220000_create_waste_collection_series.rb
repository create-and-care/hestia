class CreateWasteCollectionSeries < ActiveRecord::Migration[8.1]
  def change
    create_table :waste_collection_series do |t|
      t.references :household, null: false, foreign_key: true
      t.string :waste_type, null: false
      t.integer :weekday, null: false
      t.integer :interval_weeks, null: false, default: 1
      t.date :starts_on, null: false
      t.date :ends_on, null: false

      t.timestamps
    end
  end
end
