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

  test "create with a blank name does not persist and surfaces an error" do
    cellar = wine_cellars(:alpha_reds)
    assert_no_difference -> { Bottle.count } do
      post bottles_path, params: { bottle: { wine_cellar_id: cellar.id, name: "" } }
    end
    assert_redirected_to wine_cellars_path
    assert_equal validation_message(Bottle, :name), flash[:alert]
  end

  test "edit and update a bottle's own details and photo" do
    bottle = bottles(:alpha_bordeaux)
    get edit_bottle_path(bottle)
    assert_response :success

    photo = fixture_file_upload("sample.png", "image/png")
    patch bottle_path(bottle), params: { bottle: { name: "Château Latour", vintage: 2018, region: "Pauillac", wine_type: "rouge", photo: photo } }
    assert_redirected_to wine_cellars_path
    bottle.reload
    assert_equal "Château Latour", bottle.name
    assert_equal 2018, bottle.vintage
    assert bottle.photo.attached?
  end

  test "cannot edit another household's bottle" do
    get edit_bottle_path(bottles(:beta_bottle))
    assert_response :not_found
  end

  test "delete button uses the design-system alert dialog instead of a native confirm" do
    bottle = bottles(:alpha_bordeaux)
    get wine_cellars_path
    assert_response :success
    assert_select "dialog[role='alertdialog']"
    assert_no_match(/data-turbo-confirm="#{Regexp.escape(I18n.t("bottles.bottle.delete_confirm", name: bottle.name))}"/, @response.body)
  end

  test "taking a bottle out asks for confirmation, putting it back does not" do
    get wine_cellars_path
    assert_response :success
    assert_select "dialog[role='alertdialog'] h2", text: I18n.t("bottles.bottle.take_out_confirm", name: bottles(:alpha_bordeaux).name)
    assert_select "form[action=?]", toggle_stock_bottle_path(bottles(:alpha_chardonnay)) do
      assert_select "button", text: I18n.t("bottles.bottle.put_back")
    end
  end

  test "edit offers a region combobox seeded with the household's existing regions" do
    get edit_bottle_path(bottles(:alpha_bordeaux))
    assert_response :success
    assert_select "[data-controller='combobox']"
    assert_select "input[name='bottle[region]'][type='hidden']"
  end

  test "edit shows a breadcrumb instead of the old back link" do
    get edit_bottle_path(bottles(:alpha_bordeaux))
    assert_response :success
    assert_select "nav"
    assert_not_includes @response.body, "← Cave à vin"
    assert_not_includes @response.body, "← Wine Cellar"
  end

  test "shows the paired recipe when the bottle is linked to one" do
    bottle = bottles(:alpha_bordeaux)
    bottle.update!(recipe: recipes(:alpha_pancakes))
    get wine_cellars_path
    assert_body_includes I18n.t("bottles.bottle.paired_indicator")
  end
end
