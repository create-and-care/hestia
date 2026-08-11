require "test_helper"

module Frigo
  class MoveToShoppingListTest < ActiveSupport::TestCase
    test "adds the fridge item to the given shopping list" do
      list = shopping_lists(:alpha_groceries)
      fridge_item = fridge_items(:alpha_yogurt)

      assert_difference -> { list.items.count }, 1 do
        item = Frigo::MoveToShoppingList.call(fridge_item: fridge_item, shopping_list: list)
        assert_equal "Yaourts", item.name
      end
    end

    test "carries the fridge item's quantity and unit over to the shopping list item" do
      fridge_item = fridge_items(:alpha_yogurt)
      fridge_item.update!(quantity: 2, unit: "pots")

      item = Frigo::MoveToShoppingList.call(fridge_item: fridge_item, shopping_list: shopping_lists(:alpha_groceries))

      assert_equal 2, item.quantity
      assert_equal "pots", item.unit
    end
  end
end
