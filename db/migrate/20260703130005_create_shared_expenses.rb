class CreateSharedExpenses < ActiveRecord::Migration[8.1]
  def change
    create_table :shared_expenses do |t|
      t.references :shared_project, null: false, foreign_key: true
      t.references :shared_project_participant, foreign_key: true
      t.decimal :amount, precision: 12, scale: 2, null: false
      t.string :description
      t.date :spent_on

      t.timestamps
    end
  end
end
