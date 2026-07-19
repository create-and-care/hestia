require "application_system_test_case"

class NotificationsTest < ApplicationSystemTestCase
  test "opening the popover shows an unread notification, and marking it read updates it in place" do
    Notification.create!(user: users(:one), household: households(:alpha), kind: "birthday", title: "Anniversaire de Mamie")

    visit new_session_path
    fill_in "email_address", with: users(:one).email_address
    fill_in "password", with: "password"
    click_on "Sign in"
    assert_text households(:alpha).name

    find("[aria-label='Notifications']").click
    assert_text "Anniversaire de Mamie"

    find("[aria-label='Mark as read']").click

    assert_no_selector "[aria-label='Mark as read']"
    assert_current_path root_path
  end
end
