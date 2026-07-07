require "test_helper"

class BottleTest < ActiveSupport::TestCase
  test "requires a name" do
    bottle = households(:alpha).bottles.build(wine_cellar: wine_cellars(:alpha_reds))
    assert_not bottle.valid?
    bottle.name = "Château Latour"
    assert bottle.valid?
  end

  test "is scoped to its household" do
    assert_not_includes households(:alpha).bottles, bottles(:beta_bottle)
  end

  test "in_stock scope returns only bottles marked in stock" do
    bottles(:alpha_bordeaux).update!(in_stock: false)
    assert_not_includes Bottle.in_stock, bottles(:alpha_bordeaux)
    assert_includes Bottle.in_stock, bottles(:beta_bottle)
  end

  test "ordered scope orders by name" do
    other = households(:alpha).bottles.create!(wine_cellar: wine_cellars(:alpha_reds), name: "Abricot")
    assert_equal [ other, bottles(:alpha_bordeaux) ],
                 households(:alpha).bottles.ordered.to_a
  end

  test "destroying a wine cellar destroys its bottles" do
    cellar = wine_cellars(:alpha_reds)
    assert_difference -> { Bottle.count }, -cellar.bottles.count do
      cellar.destroy
    end
  end
end
