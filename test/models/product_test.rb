require "test_helper"

class ProductTest < ActiveSupport::TestCase
  test "name is unique per household, case-insensitively" do
    duplicate = households(:alpha).products.build(name: "lait")
    assert_not duplicate.valid?
  end

  test "the same name is allowed in a different household" do
    product = households(:beta).products.build(name: "Lait")
    assert product.valid?
  end

  test "matching finds a catalog product named inside a longer phrase, case-insensitively" do
    assert_equal products(:alpha_milk), Product.matching(household: households(:alpha), text: "Il faut acheter du lait")
  end

  test "matching returns nil when no catalog product appears in the text" do
    assert_nil Product.matching(household: households(:alpha), text: "Idée de cadeau pour Léa")
  end

  test "matching only looks within the given household's own catalog" do
    assert_nil Product.matching(household: households(:beta), text: "Il faut acheter du lait")
  end

  test "matching returns nil for blank text" do
    assert_nil Product.matching(household: households(:alpha), text: "")
  end

  test "matching treats % literally in product names" do
    product = households(:alpha).products.create!(name: "Lait 2%")
    assert_equal product, Product.matching(household: households(:alpha), text: "Acheter du lait 2%")
    # "2%" is not a wildcard: text with "2X" instead falls back to the plain
    # "Lait" fixture rather than matching "Lait 2%".
    assert_equal products(:alpha_milk), Product.matching(household: households(:alpha), text: "Acheter du lait 2X")
  end

  test "matching treats _ literally in product names" do
    product = households(:alpha).products.create!(name: "Eau_gazeuse")
    assert_equal product, Product.matching(household: households(:alpha), text: "Acheter de l'eau_gazeuse")
    assert_nil Product.matching(household: households(:alpha), text: "Acheter de l'eau gazeuse")
  end
end
