require "application_system_test_case"

class TasksTest < ApplicationSystemTestCase
  def sign_in_to_alpha
    visit new_session_path
    fill_in "email_address", with: users(:one).email_address
    fill_in "password", with: "password"
    click_on "Sign in"
    assert_text households(:alpha).name
  end

  test "the tasks board only shows the signed-in household's tasks" do
    sign_in_to_alpha

    visit tasks_path

    assert_text tasks(:alpha_dishes).title
    assert_no_text tasks(:beta_report).title
  end

  # The updated title doesn't appear on the board within this test: the card
  # refresh travels over ActionCable, which the test environment's cable.yml
  # (adapter: test) never actually delivers to a real browser — same reason
  # no Fridge system test asserts on its own modal-edit's live refresh either.
  # What's genuinely verifiable end-to-end here is the interactive path: the
  # lazy-loaded frame renders real data, the modal closes on a successful
  # submit, and the record was actually persisted.
  test "editing a task through the modal submits successfully and closes" do
    sign_in_to_alpha
    task = tasks(:alpha_dishes)

    visit tasks_path

    within "##{ActionView::RecordIdentifier.dom_id(task)}" do
      page.execute_script("arguments[0].click()", find("[aria-label='Edit']").native)
    end
    assert_selector "dialog[data-state='open']"
    assert_field "Title", with: "Faire la vaisselle"

    fill_in "Title", with: "Faire la vaisselle du soir"
    submit_button_to "Save"

    assert_no_selector "dialog[data-state='open']"
    assert_equal "Faire la vaisselle du soir", task.reload.title
  end

  test "deleting a task shows the design-system alert dialog and removes the card" do
    sign_in_to_alpha
    task = tasks(:alpha_call)

    visit tasks_path

    within "##{ActionView::RecordIdentifier.dom_id(task)}" do
      page.execute_script("arguments[0].click()", find("[aria-label='Delete']").native)
    end
    assert_selector "dialog[role='alertdialog'][data-state='open']"
    submit_button_to "Delete"

    assert_no_text task.title
  end
end
