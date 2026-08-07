require "application_system_test_case"

class NotificationsTest < ApplicationSystemTestCase
  test "opening the popover shows an unread notification, and marking it read updates it in place" do
    Notification.create!(user: users(:one), household: households(:alpha), kind: "birthday", title: "Anniversaire de Mamie")

    visit new_session_path
    fill_in "email_address", with: users(:one).email_address
    fill_in "password", with: "password"
    click_on "Sign in"
    assert_text households(:alpha).name

    click_element(find("[aria-label='Notifications']"))
    assert_text "Anniversaire de Mamie"

    click_element(find("[aria-label='Mark as read']"))

    assert_no_selector "[aria-label='Mark as read']"
    assert_current_path root_path
  end
end
