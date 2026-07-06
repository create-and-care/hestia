require "test_helper"

class WineCellarTest < ActiveSupport::TestCase
  test "requires a name" do
    cellar = households(:alpha).wine_cellars.build
    assert_not cellar.valid?
    cellar.name = "Rouges"
    assert cellar.valid?
  end

  test "destroying a cellar destroys its bottles" do
    cellar = wine_cellars(:alpha_reds)
    assert_difference -> { Bottle.count }, -cellar.bottles.count do
      cellar.destroy
    end
  end

  test "ordered scope orders by name" do
    assert_equal [ wine_cellars(:alpha_whites), wine_cellars(:alpha_reds) ],
                 households(:alpha).wine_cellars.ordered.to_a
  end

  test "is scoped to its household" do
    assert_not_includes households(:alpha).wine_cellars, wine_cellars(:beta_cellar)
  end
end
