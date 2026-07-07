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

  test "add_to_household clones the entry into the current household" do
    entry = recipe_catalog_entries(:carbonara)

    assert_difference -> { households(:alpha).recipes.count }, 1 do
      post add_to_household_recipe_catalog_path(entry)
    end

    recipe = households(:alpha).recipes.order(:created_at).last
    assert_redirected_to recipe
    assert_equal entry.title, recipe.title
  end
end
