class AddCustomizationAndLinksToNotes < ActiveRecord::Migration[8.1]
  def change
    add_column :notes, :color, :string, default: "default", null: false
    add_reference :notes, :document, null: true, foreign_key: true
  end
end
