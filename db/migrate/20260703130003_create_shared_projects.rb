class CreateSharedProjects < ActiveRecord::Migration[8.1]
  def change
    create_table :shared_projects do |t|
      t.references :household, null: false, foreign_key: true
      t.string :name, null: false

      t.timestamps
    end
  end
end
