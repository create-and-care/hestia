class CreateBudgetEntries < ActiveRecord::Migration[8.1]
  def change
    create_table :budget_entries do |t|
      t.references :budget_category, null: false, foreign_key: true
      t.string :name
      t.decimal :amount, precision: 12, scale: 2, null: false
      t.string :periodicity, null: false, default: "monthly"

      t.timestamps
    end
  end
end
