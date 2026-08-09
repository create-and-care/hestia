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
      # The add form specifically — a preview button is still offered, since an
      # already-cloned entry is exactly one you might want to look at again.
      assert_select "form[action=?]", add_to_household_recipe_catalog_path(entry), count: 0
      assert_select "span.sr-only", text: I18n.t("recipe_catalog.entry.already_added")
    end
  end

  test "every card offers a preview whose body is deferred to a lazy frame" do
    entry = recipe_catalog_entries(:carbonara)

    get recipe_catalog_path

    assert_response :success
    frame = ActionView::RecordIdentifier.dom_id(entry, :preview)
    assert_select "turbo-frame##{frame}[src=?][loading='lazy']", preview_recipe_catalog_path(entry)
    # Deferred, so the page itself must not already carry the ingredients.
    assert_not_includes @response.body, entry.ingredients.first
  end

  test "preview renders the recipe alongside its details" do
    entry = recipe_catalog_entries(:carbonara)

    get preview_recipe_catalog_path(entry)

    assert_response :success
    assert_select "turbo-frame##{ActionView::RecordIdentifier.dom_id(entry, :preview)}"
    assert_body_includes I18n.t("recipe_catalog.preview.ingredients_heading")
    assert_body_includes I18n.t("recipe_catalog.preview.steps_heading")
    assert_includes @response.body, entry.ingredients.first
    assert_includes @response.body, entry.steps.first
  end

  test "preview offers the add action, and reports when the entry is already in the book" do
    entry = recipe_catalog_entries(:carbonara)

    get preview_recipe_catalog_path(entry)
    assert_select "form[action=?]", add_to_household_recipe_catalog_path(entry)

    post add_to_household_recipe_catalog_path(entry)
    get preview_recipe_catalog_path(entry)

    assert_select "form[action=?]", add_to_household_recipe_catalog_path(entry), count: 0
    assert_body_includes I18n.t("recipe_catalog.entry.already_added")
  end

  test "preview requires authentication" do
    sign_out
    get preview_recipe_catalog_path(recipe_catalog_entries(:carbonara))
    assert_redirected_to new_session_path
  end
end
