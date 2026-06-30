require "test_helper"

class ShoppingListItemTest < ActiveSupport::TestCase
  test "requires a name" do
    item = shopping_lists(:alpha_groceries).items.build(rayon: "frais")
    assert_not item.valid?
  end

  test "rejects an unknown rayon" do
    item = shopping_lists(:alpha_groceries).items.build(name: "X", rayon: "inconnu")
    assert_not item.valid?
  end

  test "allows a nil rayon" do
    item = shopping_lists(:alpha_groceries).items.build(name: "X", rayon: nil)
    assert item.valid?
  end
end
