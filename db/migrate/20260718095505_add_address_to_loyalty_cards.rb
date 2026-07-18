class AddAddressToLoyaltyCards < ActiveRecord::Migration[8.1]
  def change
    add_reference :loyalty_cards, :address, null: true, foreign_key: true
  end
end
