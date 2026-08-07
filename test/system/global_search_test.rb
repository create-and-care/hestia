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

    # A plain Capybara click_on here is flaky: the result link is inserted into
    # the turbo-frame *after* the enclosing native <dialog> is already open
    # (showModal), and Selenium's coordinate-based click occasionally misses
    # that freshly-mutated top-layer content even though it's on-screen and
    # correctly positioned. Dispatching the click via JS sidesteps that
    # WebDriver/Chrome quirk without weakening what the test verifies.
    result_link = find(:link_or_button, tasks(:alpha_dishes).title)
    click_element(result_link)

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
