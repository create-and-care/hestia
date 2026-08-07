require "application_system_test_case"

class WasteTest < ApplicationSystemTestCase
  def sign_in_to_alpha
    visit new_session_path
    fill_in "email_address", with: users(:one).email_address
    fill_in "password", with: "password"
    click_on "Sign in"
    assert_text households(:alpha).name
  end

  test "adding a one-time collection via the modal" do
    sign_in_to_alpha
    visit waste_path

    click_element(find(:button, "Add"))
    assert_dialog_open
    within "dialog[data-state='open']" do
      select "Compost", from: "waste_collection_event_waste_type"
      submit_button_to "Add"
    end

    assert_text "Compost"
  end

  test "deleting a one-time collection asks for confirmation via the design-system alert dialog" do
    sign_in_to_alpha
    event = waste_collection_events(:alpha_event)
    visit waste_path

    within "##{ActionView::RecordIdentifier.dom_id(event)}" do
      click_element(find("[aria-label='Delete the \"Household waste\" collection']"))
    end
    assert_dialog_open "dialog[role='alertdialog'][data-state='open']"
    within "dialog[data-state='open']" do
      submit_button_to "Delete"
    end

    assert_text "No collections scheduled."
    assert_not WasteCollectionEvent.exists?(event.id)
  end

  test "switching the upcoming collections to a grid view keeps the series list in its own mode" do
    sign_in_to_alpha
    visit waste_path

    click_element(find("a[href*='events_view=grid']"))

    assert_selector "#waste_events.grid"
    assert_no_selector "#waste_series.grid"
  end
end
