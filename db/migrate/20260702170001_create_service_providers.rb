class CreateServiceProviders < ActiveRecord::Migration[8.1]
  def change
    create_table :service_providers do |t|
      t.references :household, null: false, foreign_key: true
      t.references :service_provider_type, foreign_key: true
      t.string :name, null: false
      t.string :phone
      t.string :email
      t.text :address

      t.timestamps
    end
  end
end
