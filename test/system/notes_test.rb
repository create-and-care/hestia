require "application_system_test_case"

class NotesTest < ApplicationSystemTestCase
  def sign_in_to_alpha
    visit new_session_path
    fill_in "email_address", with: users(:one).email_address
    fill_in "password", with: "password"
    click_on "Sign in"
    assert_text households(:alpha).name
  end

  test "the notes board only shows the signed-in household's notes" do
    sign_in_to_alpha
    visit notes_path
    assert_text notes(:alpha_idea).title
    assert_no_text notes(:beta_note).title
  end

  # The new note doesn't appear on the board within this test: the list
  # refresh travels over ActionCable, which the test environment's cable.yml
  # (adapter: test) never actually delivers to a real browser — same reason
  # no Tasks/Routines system test asserts on its own modal-create's live
  # refresh either. What's genuinely verifiable end-to-end here is the
  # interactive path: the modal opens, the submit closes it, and the note
  # was actually persisted.
  test "adding a note through the modal submits successfully and closes" do
    sign_in_to_alpha
    visit notes_path

    click_element(find(:button, "New note"))
    assert_dialog_open

    fill_in "Title", with: "Acheter du pain"
    submit_button_to "Add"

    assert_no_selector "dialog[data-state='open']"
    assert Note.exists?(title: "Acheter du pain")
  end

  test "promoting a note to a task asks for confirmation before creating the task" do
    sign_in_to_alpha
    note = notes(:alpha_idea)
    visit notes_path

    within "##{ActionView::RecordIdentifier.dom_id(note)}" do
      click_element(find(:button, "→ Task"))
    end
    assert_dialog_open "dialog[role='alertdialog'][data-state='open']"
    within "dialog[data-state='open']" do
      submit_button_to "Convert"
    end

    assert_text note.title # page reloaded back to the notes index
    assert households(:alpha).tasks.exists?(title: note.title)
  end

  test "deleting a note shows the design-system alert dialog and removes the card" do
    sign_in_to_alpha
    note = notes(:alpha_idea)
    visit notes_path

    within "##{ActionView::RecordIdentifier.dom_id(note)}" do
      click_element(find(:button, "Delete"))
    end
    assert_dialog_open "dialog[role='alertdialog'][data-state='open']"
    within "dialog[data-state='open']" do
      submit_button_to "Delete"
    end

    assert_no_text note.title
  end
end
