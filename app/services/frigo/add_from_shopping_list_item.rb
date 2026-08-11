module Frigo
  # Purchased item → product stored in the fridge then removed from the shopping list
  # (bidirectional bridge Shopping ↔ Fridge).
  class AddFromShoppingListItem
    def self.call(shopping_list_item:, location: "refrigerateur", expires_on: nil)
      fridge_item = Frigo::AddItem.call(
        household: shopping_list_item.shopping_list.household,
        name: shopping_list_item.name,
        location: location,
        expires_on: expires_on,
        quantity: shopping_list_item.quantity,
        unit: shopping_list_item.unit,
        product: shopping_list_item.product
      )
      shopping_list_item.destroy!
      fridge_item
    end
  end
end
