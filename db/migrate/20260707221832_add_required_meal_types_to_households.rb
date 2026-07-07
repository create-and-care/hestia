class AddRequiredMealTypesToHouseholds < ActiveRecord::Migration[8.1]
  def change
    add_column :households, :required_meal_types, :string, array: true, default: [], null: false
  end
end
