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
end
