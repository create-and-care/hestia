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

    click_on "Add to my book"
    assert_text recipe_catalog_entries(:carbonara).title
    assert_text "Faire cuire les pâtes."

    # A short settle beat after the Turbo-driven redirect above avoids a
    # race where a second turbo-stream form submission fired immediately
    # after the first lands before Turbo has fully finished the visit.
    sleep 1
    click_on "Add to shopping list"
    assert_text "Ingredients added to the shopping list."
  end
end
