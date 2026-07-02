class CreateCircles < ActiveRecord::Migration[8.1]
  def change
    create_table :circles do |t|
      t.string :name, null: false
      t.string :theme
      t.string :invite_code, null: false

      t.timestamps
    end

    add_index :circles, :invite_code, unique: true
  end
end
