require "test_helper"

class WineCellarsControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as(users(:one)) }

  test "index requires authentication" do
    sign_out
    get wine_cellars_path
    assert_redirected_to new_session_path
  end

  test "index shows the household's cellars and bottles only" do
    get wine_cellars_path
    assert_response :success
    assert_includes @response.body, "Château Margaux"
    assert_not_includes @response.body, "Bouteille Beta"
  end

  test "search bottles" do
    get wine_cellars_path(q: "margaux")
    assert_response :success
    assert_includes @response.body, "Château Margaux"
  end

  test "create a cellar" do
    assert_difference -> { households(:alpha).wine_cellars.count }, 1 do
      post wine_cellars_path, params: { wine_cellar: { name: "Champagnes" } }
    end
    assert_redirected_to wine_cellars_path
  end

  test "destroy a cellar and its bottles" do
    cellar = wine_cellars(:alpha_reds)
    assert_difference -> { Bottle.count }, -cellar.bottles.count do
      delete wine_cellar_path(cellar)
    end
    assert_redirected_to wine_cellars_path
  end

  test "cannot destroy another household's cellar" do
    assert_no_difference -> { WineCellar.count } do
      delete wine_cellar_path(wine_cellars(:beta_cellar))
    end
    assert_response :not_found
  end
end
