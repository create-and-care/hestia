class AddOwnershipAndFeaturesToGifts < ActiveRecord::Migration[8.1]
  def change
    add_column :gift_reservations, :token, :string
    add_index :gift_reservations, :token, unique: true

    add_reference :gift_lists, :created_by, foreign_key: { to_table: :users }, null: true
    add_column :gift_lists, :restricted, :boolean, default: false, null: false
    add_column :gift_lists, :visible_to_ids, :bigint, array: true, default: [], null: false
    add_column :gift_lists, :theme, :string
  end
end
