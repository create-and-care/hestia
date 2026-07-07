require "application_system_test_case"

class AuthenticationTest < ApplicationSystemTestCase
  test "signing in with valid credentials reaches the dashboard" do
    visit new_session_path

    fill_in "email_address", with: users(:one).email_address
    fill_in "password", with: "password"
    click_on "Sign in"

    assert_text households(:alpha).name

    click_on "Daily life"
    assert_text "Shopping"
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

    click_on "Sign out"

    assert_current_path new_session_path
  end
end
