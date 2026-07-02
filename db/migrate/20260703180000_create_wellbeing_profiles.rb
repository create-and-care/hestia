class CreateWellbeingProfiles < ActiveRecord::Migration[8.1]
  def change
    create_table :wellbeing_profiles do |t|
      t.references :user, null: false, foreign_key: true, index: { unique: true }
      t.integer :height
      t.integer :age
      t.string :sex
      t.string :activity_level
      t.decimal :start_weight, precision: 6, scale: 2
      t.decimal :goal_weight, precision: 6, scale: 2

      t.timestamps
    end
  end
end
