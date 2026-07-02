class CreateGiftReservations < ActiveRecord::Migration[8.1]
  def change
    create_table :gift_reservations do |t|
      t.references :gift_idea, null: false, foreign_key: true
      t.string :reserver_name

      t.timestamps
    end
  end
end
