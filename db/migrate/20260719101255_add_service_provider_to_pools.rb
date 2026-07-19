class AddServiceProviderToPools < ActiveRecord::Migration[8.1]
  def change
    add_reference :pools, :service_provider, null: true, foreign_key: true
  end
end
