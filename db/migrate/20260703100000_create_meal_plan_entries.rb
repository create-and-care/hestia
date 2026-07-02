class CreateMealPlanEntries < ActiveRecord::Migration[8.1]
  def change
    create_table :meal_plan_entries do |t|
      t.references :household, null: false, foreign_key: true
      t.references :recipe, foreign_key: true
      t.date :on_date, null: false
      t.string :meal_type, null: false, default: "dinner"
      t.integer :position, null: false, default: 0
      t.string :free_name

      t.timestamps
    end

    add_index :meal_plan_entries, [ :household_id, :on_date ]
  end
end
