class CreateWasteCollectionEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :waste_collection_events do |t|
      t.references :household, null: false, foreign_key: true
      t.references :waste_collection_series, foreign_key: true
      t.string :waste_type, null: false
      t.date :collected_on, null: false

      t.timestamps
    end

    add_index :waste_collection_events, [ :household_id, :collected_on ]
  end
end
