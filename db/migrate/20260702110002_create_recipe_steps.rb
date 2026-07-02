class CreateRecipeSteps < ActiveRecord::Migration[8.1]
  def change
    create_table :recipe_steps do |t|
      t.references :recipe, null: false, foreign_key: true
      t.integer :position, null: false, default: 0
      t.text :content, null: false

      t.timestamps
    end
  end
end
