class CreateGiftIdeas < ActiveRecord::Migration[8.1]
  def change
    create_table :gift_ideas do |t|
      t.references :gift_list, null: false, foreign_key: true
      t.string :name, null: false
      t.decimal :price, precision: 10, scale: 2
      t.string :url
      t.text :comment
      t.string :status, null: false, default: "wanted"

      t.timestamps
    end
  end
end
