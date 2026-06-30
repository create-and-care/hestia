require "test_helper"

class ShoppingListTest < ActiveSupport::TestCase
  test "requires a name" do
    list = ShoppingList.new(household: households(:alpha))
    assert_not list.valid?
    list.name = "Test"
    assert list.valid?
  end

  test "items are ordered: unchecked first, then by rayon and position" do
    list = shopping_lists(:alpha_groceries)
    assert_equal [ shopping_list_items(:alpha_apples), shopping_list_items(:alpha_bread) ], list.items.to_a
  end

  test "destroying a list destroys its items" do
    list = shopping_lists(:alpha_groceries)
    assert_difference -> { ShoppingListItem.count }, -list.items.count do
      list.destroy
    end
  end

  test "lists are scoped to their household" do
    assert_not_includes households(:alpha).shopping_lists, shopping_lists(:beta_groceries)
  end
end
