class CreateLoyaltyCards < ActiveRecord::Migration[8.1]
  def change
    create_table :loyalty_cards do |t|
      t.references :household, null: false, foreign_key: true
      t.string :name, null: false
      t.string :number, null: false
      t.string :code_format, null: false, default: "barcode"
      t.integer :position, null: false, default: 0

      t.timestamps
    end
  end
end
