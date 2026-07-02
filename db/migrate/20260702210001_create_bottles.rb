class CreateBottles < ActiveRecord::Migration[8.1]
  def change
    create_table :bottles do |t|
      t.references :household, null: false, foreign_key: true
      t.references :wine_cellar, null: false, foreign_key: true
      t.string :name, null: false
      t.integer :vintage
      t.string :region
      t.string :wine_type
      t.boolean :in_stock, null: false, default: true

      t.timestamps
    end
  end
end
