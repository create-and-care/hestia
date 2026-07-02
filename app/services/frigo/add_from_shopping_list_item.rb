module Frigo
  # Article acheté → produit rangé au frigo puis retiré de la liste de courses
  # (passerelle bidirectionnelle Courses ↔ Frigo, CDC §9.1 / §9.4).
  class AddFromShoppingListItem
    def self.call(shopping_list_item:, location: "refrigerateur", expires_on: nil)
      fridge_item = Frigo::AddItem.call(
        household: shopping_list_item.shopping_list.household,
        name: shopping_list_item.name,
        location: location,
        expires_on: expires_on,
        product: shopping_list_item.product
      )
      shopping_list_item.destroy!
      fridge_item
    end
  end
end
