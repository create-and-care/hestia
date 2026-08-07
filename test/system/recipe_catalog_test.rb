require "application_system_test_case"

class RecipeCatalogTest < ApplicationSystemTestCase
  test "discovering a catalog recipe, adding it to my book, then to the shopping list" do
    visit new_session_path
    fill_in "email_address", with: users(:one).email_address
    fill_in "password", with: "password"
    click_on "Sign in"
    assert_text households(:alpha).name

    visit recipe_catalog_path
    assert_text recipe_catalog_entries(:carbonara).title

    within "##{ActionView::RecordIdentifier.dom_id(recipe_catalog_entries(:carbonara), :catalog)}" do
      submit_button_to "Add to my book"
    end
    assert_text recipe_catalog_entries(:carbonara).title
    assert_text "Faire cuire les pâtes."

    # A plain click_on is flaky here for the same reason noted in
    # global_search_test.rb: Selenium's coordinate-based click occasionally
    # misses a dialog trigger. Dispatch the click via JS instead.
    page.execute_script("arguments[0].click()", find(:button, "Add to shopping list").native)
    assert_dialog_open
    submit_button_to "Add to this list"

    assert_text "View shopping list"
    recipe = households(:alpha).recipes.find_by!(recipe_catalog_entry: recipe_catalog_entries(:carbonara))
    assert_equal recipe.recipe_ingredients.count, ShoppingListItem.where(recipe: recipe).count
  end
end
