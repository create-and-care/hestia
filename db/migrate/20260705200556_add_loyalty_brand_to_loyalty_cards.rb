class AddLoyaltyBrandToLoyaltyCards < ActiveRecord::Migration[8.1]
  def change
    add_reference :loyalty_cards, :loyalty_brand, null: true, foreign_key: true
  end
end
