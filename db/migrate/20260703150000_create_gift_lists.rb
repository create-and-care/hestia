class CreateGiftLists < ActiveRecord::Migration[8.1]
  def change
    create_table :gift_lists do |t|
      t.references :household, null: false, foreign_key: true
      t.references :contact, foreign_key: true
      t.string :name, null: false
      t.string :perspective, null: false, default: "receive"

      t.timestamps
    end
  end
end
