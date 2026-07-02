class CreateDocuments < ActiveRecord::Migration[8.1]
  def change
    create_table :documents do |t|
      t.references :household, null: false, foreign_key: true
      t.references :document_folder, foreign_key: true
      t.string :name, null: false

      t.timestamps
    end
  end
end
