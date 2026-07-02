class CreateGiftListShares < ActiveRecord::Migration[8.1]
  def change
    create_table :gift_list_shares do |t|
      t.references :gift_list, null: false, foreign_key: true
      t.string :token, null: false

      t.timestamps
    end

    add_index :gift_list_shares, :token, unique: true
  end
end
