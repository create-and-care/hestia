require "test_helper"

class RecipeCatalogControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as(users(:one)) }

  test "index requires authentication" do
    sign_out
    get recipe_catalog_path
    assert_redirected_to new_session_path
  end

  test "index lists catalog entries" do
    get recipe_catalog_path
    assert_response :success
    assert_includes @response.body, "Pâtes carbonara"
  end

  test "search filters the catalog" do
    get recipe_catalog_path(q: "carbo")
    assert_response :success
    assert_includes @response.body, "Pâtes carbonara"
  end

  test "tag filter narrows the catalog to matching entries" do
    get recipe_catalog_path(tag: "vegetarien")
    assert_response :success
    assert_includes @response.body, "Salade de quinoa"
    assert_not_includes @response.body, "Pâtes carbonara"
  end

  test "switching to list view persists across requests" do
    get recipe_catalog_path(view: "list")
    assert_response :success

    get recipe_catalog_path
    assert_response :success
    assert_select "#recipe_catalog_entries.divide-y"
  end

  test "add_to_household clones the entry into the current household" do
    entry = recipe_catalog_entries(:carbonara)

    assert_difference -> { households(:alpha).recipes.count }, 1 do
      post add_to_household_recipe_catalog_path(entry)
    end

    recipe = households(:alpha).recipes.order(:created_at).last
    assert_redirected_to recipe
    assert_equal entry.title, recipe.title
    assert_equal entry, recipe.recipe_catalog_entry
  end

  test "add_to_household is idempotent and redirects to the existing clone" do
    entry = recipe_catalog_entries(:carbonara)
    post add_to_household_recipe_catalog_path(entry)
    first_clone = households(:alpha).recipes.order(:created_at).last

    assert_no_difference -> { households(:alpha).recipes.count } do
      post add_to_household_recipe_catalog_path(entry)
    end
    assert_redirected_to first_clone
  end

  test "index shows an already-added state instead of the add button" do
    entry = recipe_catalog_entries(:carbonara)
    post add_to_household_recipe_catalog_path(entry)

    get recipe_catalog_path

    assert_response :success
    assert_select "##{ActionView::RecordIdentifier.dom_id(entry, :catalog)}" do
      assert_select "button", text: I18n.t("recipe_catalog.entry.add_link"), count: 0
      assert_select "span", text: I18n.t("recipe_catalog.entry.already_added")
    end
  end
end
