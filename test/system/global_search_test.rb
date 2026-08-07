require "application_system_test_case"

class GlobalSearchTest < ApplicationSystemTestCase
  # Opening the palette with a plain `click_on` leaves every later keystroke
  # going nowhere: `fill_in` reports success and the input stays empty, so the
  # results frame never loads and the failure reads as "no such result".
  #
  # Selenium only runs its own focusing step when the field it is typing into
  # isn't already document.activeElement — and this one is, because the palette
  # input carries `autofocus` and showModal() honours it. With that step
  # skipped, the keys go to whatever WebDriver last focused itself, which after
  # a native click on the trigger is the trigger button, now inert behind the
  # modal. Clicking the trigger from JS never gives WebDriver an element to
  # hold on to, so the keys follow the real focus into the dialog. (Fields
  # without `autofocus` — every other dialog in the suite — are unaffected:
  # Selenium focuses them itself and the keys land.)
  def open_search_palette
    click_element(find(:button, "Search…"))
    assert_dialog_open
  end

  test "searching from the command palette navigates to the matching result" do
    visit new_session_path
    fill_in "email_address", with: users(:one).email_address
    fill_in "password", with: "password"
    click_on "Sign in"
    assert_text households(:alpha).name

    open_search_palette
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

    open_search_palette
    fill_in placeholder: "Search across the household…", with: "zzzznomatchzzzz"

    assert_text "No results found."
  end
end
