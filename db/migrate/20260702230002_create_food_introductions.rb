class CreateFoodIntroductions < ActiveRecord::Migration[8.1]
  def change
    create_table :food_introductions do |t|
      t.references :baby_profile, null: false, foreign_key: true
      t.string :food, null: false
      t.date :introduced_on
      t.string :acceptance

      t.timestamps
    end
  end
end
