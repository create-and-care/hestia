class AddTripToMealPlanEntries < ActiveRecord::Migration[8.1]
  def change
    add_reference :meal_plan_entries, :trip, null: true, foreign_key: true
  end
end
