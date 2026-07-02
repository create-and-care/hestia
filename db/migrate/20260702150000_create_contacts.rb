class CreateContacts < ActiveRecord::Migration[8.1]
  def change
    create_table :contacts do |t|
      t.references :household, null: false, foreign_key: true
      t.string :name, null: false
      t.date :born_on
      t.boolean :year_known, null: false, default: true

      t.timestamps
    end
  end
end
