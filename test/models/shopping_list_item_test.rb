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

  test "orders items by store-aisle order rather than alphabetically" do
    list = shopping_lists(:alpha_groceries)
    drinks = list.items.create!(name: "Eau", rayon: "boissons")
    other = list.items.create!(name: "Divers", rayon: "autre")
    produce = list.items.create!(name: "Tomate", rayon: "fruits_legumes")

    ids_in_order = list.reload.items.map(&:id) & [ produce.id, drinks.id, other.id ]
    assert_equal [ produce.id, drinks.id, other.id ], ids_in_order
  end
end
