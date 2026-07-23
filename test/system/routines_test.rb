require "application_system_test_case"

class RoutinesTest < ApplicationSystemTestCase
  def sign_in_to_alpha
    visit new_session_path
    fill_in "email_address", with: users(:one).email_address
    fill_in "password", with: "password"
    click_on "Sign in"
    assert_text households(:alpha).name
  end

  test "the routines board only shows the signed-in household's routines" do
    sign_in_to_alpha
    visit routines_path
    assert_text routines(:alpha_vacuum).name
    assert_no_text routines(:beta_routine).name
  end

  # The updated name doesn't appear on the board within this test: the card
  # refresh travels over ActionCable, which the test environment's cable.yml
  # (adapter: test) never actually delivers to a real browser — same reason
  # no Fridge/Tasks system test asserts on its own modal-edit's live refresh
  # either. What's genuinely verifiable end-to-end here is the interactive
  # path: the lazy-loaded frame renders real data, the modal closes on a
  # successful submit, and the record was actually persisted.
  test "editing a routine through the modal submits successfully and closes" do
    sign_in_to_alpha
    routine = routines(:alpha_vacuum)
    visit routines_path

    within "##{ActionView::RecordIdentifier.dom_id(routine)}" do
      page.execute_script("arguments[0].click()", find("[aria-label='Edit routine']").native)
    end
    assert_selector "dialog[data-state='open']"
    assert_field "Name", with: "Passer l'aspirateur"

    fill_in "Name", with: "Passer l'aspirateur du salon"
    submit_button_to "Save"

    assert_no_selector "dialog[data-state='open']"
    assert_equal "Passer l'aspirateur du salon", routine.reload.name
  end

  test "viewing a routine's history through the modal shows past completions" do
    sign_in_to_alpha
    routine = routines(:alpha_vacuum)
    routine.complete!(author: users(:one), on: Date.current)
    visit routines_path

    within "##{ActionView::RecordIdentifier.dom_id(routine)}" do
      page.execute_script("arguments[0].click()", find("[aria-label='View completion history']").native)
    end
    assert_selector "dialog[data-state='open']"
    assert_text "Alice"
  end

  test "deleting a routine shows the design-system alert dialog and removes the card" do
    sign_in_to_alpha
    routine = routines(:alpha_overdue)
    visit routines_path

    within "##{ActionView::RecordIdentifier.dom_id(routine)}" do
      page.execute_script("arguments[0].click()", find("[aria-label='Delete routine']").native)
    end
    assert_selector "dialog[role='alertdialog'][data-state='open']"
    submit_button_to "Delete"

    assert_no_text routine.name
  end
end
