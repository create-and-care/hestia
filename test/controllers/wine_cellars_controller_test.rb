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

  test "search matches region and wine type, and shows the bottle's cellar" do
    get wine_cellars_path(q: "bordeaux")
    assert_response :success
    assert_includes @response.body, "Château Margaux"
    assert_includes @response.body, wine_cellars(:alpha_reds).name

    get wine_cellars_path(q: "rouge")
    assert_includes @response.body, "Château Margaux"
  end

  test "create a cellar with a blank name does not persist and surfaces an error" do
    assert_no_difference -> { WineCellar.count } do
      post wine_cellars_path, params: { wine_cellar: { name: "" } }
    end
    assert_redirected_to wine_cellars_path
    assert_equal validation_message(WineCellar, :name), flash[:alert]
  end

  test "delete cellar button asks for confirmation" do
    cellar = wine_cellars(:alpha_reds)
    get wine_cellars_path
    assert_select "form[action=?][data-turbo-confirm]", wine_cellar_path(cellar)
  end

  test "search input is wired for debounced auto-submit" do
    get wine_cellars_path
    assert_select "form[data-controller='debounced-search']" do
      assert_select "input[data-action='input->debounced-search#submit']"
    end
  end

  test "the new-cellar form opens in a design-system dialog" do
    get wine_cellars_path
    assert_response :success
    assert_select "dialog[role='dialog']" do
      assert_select "input#wine_cellar_name"
    end
  end

  test "the filters sheet offers cellar, type, region, vintage, and stock filters" do
    get wine_cellars_path
    assert_response :success
    assert_select "select#wine_cellars_filter_cellar"
    assert_select "select#wine_cellars_filter_wine_type"
    assert_select "select#wine_cellars_filter_region option", text: "Bordeaux"
    assert_select "select#wine_cellars_filter_vintage option", text: "2015"
    assert_select "select#wine_cellars_filter_in_stock"
  end

  test "filtering by wine type narrows the bottle list" do
    get wine_cellars_path(wine_type: "rouge")
    assert_response :success
    assert_includes @response.body, "Château Margaux"
    assert_not_includes @response.body, "Chardonnay Bourgogne"
  end

  test "filtering by cellar narrows the bottle list" do
    get wine_cellars_path(wine_cellar_id: wine_cellars(:alpha_whites).id)
    assert_response :success
    assert_includes @response.body, "Chardonnay Bourgogne"
    assert_not_includes @response.body, "Château Margaux"
  end

  test "filtering by vintage narrows the bottle list" do
    get wine_cellars_path(vintage: 2020)
    assert_response :success
    assert_includes @response.body, "Chardonnay Bourgogne"
    assert_not_includes @response.body, "Château Margaux"
  end

  test "filtering by stock status narrows the bottle list" do
    get wine_cellars_path(in_stock: "0")
    assert_response :success
    assert_includes @response.body, "Chardonnay Bourgogne"
    assert_not_includes @response.body, "Château Margaux"
  end

  test "paginates cellars when there are more than the page size" do
    households(:alpha).wine_cellars.destroy_all
    (WineCellarsController::PER_PAGE + 1).times { |i| households(:alpha).wine_cellars.create!(name: "Cave #{'%02d' % i}") }

    get wine_cellars_path
    assert_select "#wine_cellars h2.font-medium", count: WineCellarsController::PER_PAGE

    get wine_cellars_path(page: 2)
    assert_select "#wine_cellars h2.font-medium", count: 1
  end
end
