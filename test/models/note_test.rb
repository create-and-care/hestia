require "test_helper"
require "turbo/broadcastable/test_helper"

class NoteTest < ActiveSupport::TestCase
  include Turbo::Broadcastable::TestHelper

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

  test "defaults to the default color" do
    assert_equal "default", households(:alpha).notes.build(title: "X").color
  end

  test "rejects an unknown color" do
    note = households(:alpha).notes.build(title: "X", color: "chartreuse")
    assert_not note.valid?
    assert_includes note.errors[:color], error_message(:inclusion)
  end

  test "rejects a recipe from another household" do
    note = households(:alpha).notes.build(title: "X", recipe: recipes(:beta_soup))
    assert_not note.valid?
    assert_includes note.errors[:recipe], error_message(:invalid)
  end

  test "rejects a document from another household" do
    note = households(:alpha).notes.build(title: "X", document: documents(:beta_doc))
    assert_not note.valid?
    assert_includes note.errors[:document], error_message(:invalid)
  end

  test "accepts a recipe and a document from the same household" do
    note = households(:alpha).notes.build(title: "X", recipe: recipes(:alpha_pancakes), document: documents(:alpha_doc))
    assert note.valid?
  end

  test "broadcasts a page refresh when favorite changes" do
    note = notes(:alpha_idea)
    streams = capture_turbo_stream_broadcasts note.household do
      note.update!(favorite: !note.favorite)
    end
    assert_includes streams.map { |stream| stream["action"] }, "refresh"
  end

  test "broadcasts a page refresh when archived changes" do
    note = notes(:alpha_idea)
    streams = capture_turbo_stream_broadcasts note.household do
      note.update!(archived: true)
    end
    assert_includes streams.map { |stream| stream["action"] }, "refresh"
  end

  test "does not broadcast a refresh for a plain content edit" do
    note = notes(:alpha_idea)
    streams = capture_turbo_stream_broadcasts note.household do
      note.update!(content: "Contenu modifié")
    end
    assert_not_includes streams.map { |stream| stream["action"] }, "refresh"
  end
end
