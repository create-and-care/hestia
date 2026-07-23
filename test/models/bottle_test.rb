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
                 wine_cellars(:alpha_reds).bottles.ordered.to_a
  end

  test "destroying a wine cellar destroys its bottles" do
    cellar = wine_cellars(:alpha_reds)
    assert_difference -> { Bottle.count }, -cellar.bottles.count do
      cellar.destroy
    end
  end

  test "can have a photo attached" do
    bottle = bottles(:alpha_bordeaux)
    bottle.photo.attach(io: File.open(Rails.root.join("test/fixtures/files/sample.png")), filename: "sample.png", content_type: "image/png")
    assert bottle.photo.attached?
  end

  test "rejects a wine cellar from another household" do
    bottle = households(:alpha).bottles.build(name: "X", wine_cellar: wine_cellars(:beta_cellar))
    assert_not bottle.valid?
    assert_includes bottle.errors[:wine_cellar], "is invalid"
  end
end
