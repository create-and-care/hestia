class CreateServiceProviderTypes < ActiveRecord::Migration[8.1]
  def change
    create_table :service_provider_types do |t|
      t.references :household, null: false, foreign_key: true
      t.string :name, null: false
      t.string :icon
      t.string :color

      t.timestamps
    end
  end
end
