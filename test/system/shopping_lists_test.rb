require "application_system_test_case"

class ShoppingListsTest < ApplicationSystemTestCase
  test "the shopping lists index only shows the signed-in household's lists" do
    visit new_session_path
    fill_in "email_address", with: users(:one).email_address
    fill_in "password", with: "password"
    click_on "Sign in"

    click_on "Daily life"
    click_on "Shopping"

    assert_text shopping_lists(:alpha_groceries).name
    assert_no_text shopping_lists(:beta_groceries).name
  end
end
