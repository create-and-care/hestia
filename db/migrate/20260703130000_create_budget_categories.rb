class CreateBudgetCategories < ActiveRecord::Migration[8.1]
  def change
    create_table :budget_categories do |t|
      t.references :household, null: false, foreign_key: true
      t.string :kind, null: false, default: "expense"
      t.string :name, null: false
      t.string :emoji
      t.string :color

      t.timestamps
    end
  end
end
