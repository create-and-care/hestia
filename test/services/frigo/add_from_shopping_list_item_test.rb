require "test_helper"

module Frigo
  class AddFromShoppingListItemTest < ActiveSupport::TestCase
    test "stores the item in the fridge and removes it from the list" do
      item = shopping_list_items(:alpha_apples)

      assert_difference -> { households(:alpha).fridge_items.count }, 1 do
        assert_difference -> { ShoppingListItem.count }, -1 do
          fridge_item = Frigo::AddFromShoppingListItem.call(shopping_list_item: item, location: "garde_manger")
          assert_equal "Pommes", fridge_item.name
          assert_equal "garde_manger", fridge_item.location
        end
      end

      assert_not ShoppingListItem.exists?(item.id)
    end

    test "carries the shopping list item's quantity and unit over to the fridge item" do
      item = shopping_list_items(:alpha_apples)
      item.update!(quantity: 6, unit: "pièces")

      fridge_item = Frigo::AddFromShoppingListItem.call(shopping_list_item: item)

      assert_equal 6, fridge_item.quantity
      assert_equal "pièces", fridge_item.unit
    end
  end
end
