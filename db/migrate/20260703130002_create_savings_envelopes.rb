class CreateSavingsEnvelopes < ActiveRecord::Migration[8.1]
  def change
    create_table :savings_envelopes do |t|
      t.references :household, null: false, foreign_key: true
      t.string :name, null: false
      t.decimal :recurring_deposit, precision: 12, scale: 2, null: false, default: "0"

      t.timestamps
    end
  end
end
