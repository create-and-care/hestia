require "application_system_test_case"

class AuthenticationTest < ApplicationSystemTestCase
  test "signing in with valid credentials reaches the dashboard" do
    visit new_session_path

    fill_in "email_address", with: users(:one).email_address
    fill_in "password", with: "password"
    click_on "Sign in"

    assert_text households(:alpha).name
    assert_text "Daily life"
  end

  test "signing in with an invalid password shows an error and stays signed out" do
    visit new_session_path

    fill_in "email_address", with: users(:one).email_address
    fill_in "password", with: "wrong-password"
    click_on "Sign in"

    assert_current_path new_session_path
    assert_text "Try another email address or password."
  end

  test "signing out returns to the sign-in page" do
    visit new_session_path
    fill_in "email_address", with: users(:one).email_address
    fill_in "password", with: "password"
    click_on "Sign in"
    assert_text households(:alpha).name

    # Sign out is no longer a row in the sidebar footer: it moved behind the
    # gear in shared/_sidebar_user_card, so the account popover has to be opened
    # before the row exists on screen. The row is a button_to, hence
    # submit_button_to rather than click_on.
    click_element(find("button[aria-label='Open account menu']"))
    submit_button_to "Sign out"

    assert_current_path new_session_path
  end
end
