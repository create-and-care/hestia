module Frigo
  # Produit du frigo à racheter → article ajouté à une liste de courses (CDC §9.4).
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
