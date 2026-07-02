require "test_helper"

class BottlesControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as(users(:one)) }

  test "create a bottle in a cellar" do
    cellar = wine_cellars(:alpha_reds)
    assert_difference -> { cellar.bottles.count }, 1 do
      post bottles_path, params: { bottle: { wine_cellar_id: cellar.id, name: "Saint-Émilion", wine_type: "rouge" } }
    end
    assert_redirected_to wine_cellars_path
  end

  test "toggle stock (consumption)" do
    bottle = bottles(:alpha_bordeaux)
    patch toggle_stock_bottle_path(bottle)
    assert_not bottle.reload.in_stock
  end

  test "move a bottle to another cellar" do
    bottle = bottles(:alpha_bordeaux)
    patch bottle_path(bottle), params: { bottle: { wine_cellar_id: wine_cellars(:alpha_whites).id } }
    assert_equal wine_cellars(:alpha_whites), bottle.reload.wine_cellar
  end

  test "cannot move a bottle to another household's cellar" do
    bottle = bottles(:alpha_bordeaux)
    patch bottle_path(bottle), params: { bottle: { wine_cellar_id: wine_cellars(:beta_cellar).id } }
    assert_response :not_found
    assert_equal wine_cellars(:alpha_reds), bottle.reload.wine_cellar
  end

  test "cannot touch another household's bottle" do
    delete bottle_path(bottles(:beta_bottle))
    assert_response :not_found
  end

  test "destroy" do
    bottle = bottles(:alpha_bordeaux)
    delete bottle_path(bottle)
    assert_not Bottle.exists?(bottle.id)
  end
end
