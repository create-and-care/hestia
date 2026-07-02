require "test_helper"

class NotesControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as(users(:one)) }

  test "index requires authentication" do
    sign_out
    get notes_path
    assert_redirected_to new_session_path
  end

  test "index shows active notes of the household only" do
    get notes_path
    assert_response :success
    assert_includes @response.body, "Idée cadeau"
    assert_not_includes @response.body, "Vieille note" # archived
    assert_not_includes @response.body, "Note Beta"     # other household
  end

  test "archived filter" do
    get notes_path(archived: 1)
    assert_response :success
    assert_includes @response.body, "Vieille note"
  end

  test "search" do
    get notes_path(q: "cadeau")
    assert_response :success
    assert_includes @response.body, "Idée cadeau"
  end

  test "create" do
    assert_difference -> { households(:alpha).notes.count }, 1 do
      post notes_path, params: { note: { title: "Nouvelle", content: "Texte" } }, as: :turbo_stream
    end
    assert_response :success
    assert_equal users(:one), Note.find_by(title: "Nouvelle").author
  end

  test "toggle favorite and archive" do
    note = notes(:alpha_idea)
    patch toggle_favorite_note_path(note)
    assert_not note.reload.favorite
    patch toggle_archive_note_path(note)
    assert note.reload.archived
  end

  test "promote to task" do
    assert_difference -> { households(:alpha).tasks.count }, 1 do
      post promote_to_task_note_path(notes(:alpha_idea))
    end
    assert_redirected_to notes_path
  end

  test "destroy" do
    note = notes(:alpha_idea)
    delete note_path(note), as: :turbo_stream
    assert_response :success
    assert_not Note.exists?(note.id)
  end

  test "cannot touch another household's note" do
    delete note_path(notes(:beta_note))
    assert_response :not_found
  end
end
