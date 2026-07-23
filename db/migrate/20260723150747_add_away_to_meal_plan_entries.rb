class AddAwayToMealPlanEntries < ActiveRecord::Migration[8.1]
  def change
    add_column :meal_plan_entries, :away, :boolean, null: false, default: false
  end
end
