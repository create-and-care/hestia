require "test_helper"

class NoteTest < ActiveSupport::TestCase
  test "requires a title" do
    note = households(:alpha).notes.build
    assert_not note.valid?
    note.title = "X"
    assert note.valid?
  end

  test "active and archived scopes" do
    assert_includes Note.active, notes(:alpha_idea)
    assert_includes Note.archived, notes(:alpha_old)
    assert_not_includes Note.active, notes(:alpha_old)
  end

  test "is scoped to its household" do
    assert_not_includes households(:alpha).notes, notes(:beta_note)
  end
end
