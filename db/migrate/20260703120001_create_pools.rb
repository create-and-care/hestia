class CreatePools < ActiveRecord::Migration[8.1]
  def change
    create_table :pools do |t|
      t.references :household, null: false, foreign_key: true
      t.string :name, null: false
      t.string :treatment_type, null: false, default: "chlore"

      t.timestamps
    end
  end
end
