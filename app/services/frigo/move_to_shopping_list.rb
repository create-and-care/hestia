module Frigo
  # Fridge product to repurchase → item added to a shopping list.
  class MoveToShoppingList
    def self.call(fridge_item:, shopping_list:)
      Courses::AddItem.call(
        shopping_list: shopping_list,
        name: fridge_item.name,
        product: fridge_item.product
      )
    end
  end
end
