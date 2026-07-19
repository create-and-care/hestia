class AddServiceProviderToBabyProfiles < ActiveRecord::Migration[8.1]
  def change
    add_reference :baby_profiles, :service_provider, null: true, foreign_key: true
  end
end
