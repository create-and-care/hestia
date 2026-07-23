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

    page.execute_script("arguments[0].click()", find(:button, "Add").native)
    assert_selector "dialog[data-state='open']"
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
      page.execute_script("arguments[0].click()", find("[aria-label='Delete the \"Household waste\" collection']").native)
    end
    assert_selector "dialog[role='alertdialog'][data-state='open']"
    within "dialog[data-state='open']" do
      submit_button_to "Delete"
    end

    assert_text "No collections scheduled."
    assert_not WasteCollectionEvent.exists?(event.id)
  end

  test "switching the upcoming collections to a grid view keeps the series list in its own mode" do
    sign_in_to_alpha
    visit waste_path

    find("a[href*='events_view=grid']").click

    assert_selector "#waste_events.grid"
    assert_no_selector "#waste_series.grid"
  end
end
