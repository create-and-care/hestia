require "application_system_test_case"

class TasksTest < ApplicationSystemTestCase
  test "the tasks board only shows the signed-in household's tasks" do
    visit new_session_path
    fill_in "email_address", with: users(:one).email_address
    fill_in "password", with: "password"
    click_on "Sign in"

    click_on "Tasks"

    assert_text tasks(:alpha_dishes).title
    assert_no_text tasks(:beta_report).title
  end
end
