require "application_system_test_case"

class GlobalSearchTest < ApplicationSystemTestCase
  test "searching from the command palette navigates to the matching result" do
    visit new_session_path
    fill_in "email_address", with: users(:one).email_address
    fill_in "password", with: "password"
    click_on "Sign in"
    assert_text households(:alpha).name

    click_on "Search…"
    assert_selector "[role=combobox]"

    fill_in placeholder: "Search across the household…", with: "vaisselle"
    click_on tasks(:alpha_dishes).title

    assert_current_path edit_task_path(tasks(:alpha_dishes))
  end

  test "a query with no matches shows the no-results state" do
    visit new_session_path
    fill_in "email_address", with: users(:one).email_address
    fill_in "password", with: "password"
    click_on "Sign in"
    assert_text households(:alpha).name

    click_on "Search…"
    assert_selector "[role=combobox]"

    fill_in placeholder: "Search across the household…", with: "zzzznomatchzzzz"

    assert_text "No results found."
  end
end
