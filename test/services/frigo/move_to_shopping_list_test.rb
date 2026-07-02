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
  end
end
