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

  test "search input is wired for debounced auto-submit" do
    get notes_path
    assert_select "form[data-controller='debounced-search']" do
      assert_select "input[data-action='input->debounced-search#submit']"
    end
  end

  test "create" do
    assert_difference -> { households(:alpha).notes.count }, 1 do
      post notes_path, params: { note: { title: "Nouvelle", content: "Texte" } }, as: :turbo_stream
    end
    assert_response :success
    assert_equal users(:one), Note.find_by(title: "Nouvelle").author
  end

  test "create accepts a color" do
    post notes_path, params: { note: { title: "Nouvelle", color: "pink" } }, as: :turbo_stream
    assert_equal "pink", Note.find_by(title: "Nouvelle").color
  end

  test "quick add form has a voice dictation button and accessible labels" do
    get notes_path
    assert_select "[data-controller='voice-dictation']" do
      assert_select "button[data-action='voice-dictation#toggle']"
      assert_select "textarea[data-voice-dictation-target='output']"
    end
    assert_select "label[for='note_title'].sr-only"
    assert_select "label[for='note_content'].sr-only"
  end

  test "the quick add form lives in a modal, and is hidden entirely while viewing archived notes" do
    get notes_path
    assert_response :success
    assert_select "dialog[role='dialog'] input#note_title"

    get notes_path(archived: 1)
    assert_response :success
    assert_select "input#note_title", count: 0
  end

  test "toggle favorite and archive" do
    note = notes(:alpha_idea)
    patch toggle_favorite_note_path(note)
    assert_not note.reload.favorite
    patch toggle_archive_note_path(note)
    assert note.reload.archived
  end

  test "quick actions preserve the current search and archived filter" do
    note = notes(:alpha_idea)
    patch toggle_favorite_note_path(note, q: "cadeau", archived: "1")
    assert_redirected_to notes_path(q: "cadeau", archived: "1")
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

  test "delete button uses the design-system alert dialog instead of a native confirm" do
    get notes_path
    assert_response :success
    assert_select "dialog[role='alertdialog']"
    assert_no_match(/data-turbo-confirm="#{Regexp.escape(I18n.t("notes.note.delete_confirm"))}"/, @response.body)
  end

  test "promoting a note to a task asks for confirmation via the design-system alert dialog" do
    get notes_path
    assert_response :success
    assert_select "dialog[role='alertdialog']", count: 2 # one per note fixture shown (delete + promote)
    assert_includes @response.body, I18n.t("notes.note.promote_confirm")
  end

  test "cannot touch another household's note" do
    delete note_path(notes(:beta_note))
    assert_response :not_found
  end

  test "edit form offers the household's recipes and documents" do
    get edit_note_path(notes(:alpha_idea))
    assert_response :success
    assert_select "select#note_recipe_id option", text: recipes(:alpha_pancakes).title
    assert_select "select#note_document_id option", text: documents(:alpha_doc).name
    assert_select "select#note_recipe_id option", text: recipes(:beta_soup).title, count: 0
  end

  test "edit shows a breadcrumb back to notes instead of a back link" do
    get edit_note_path(notes(:alpha_idea))
    assert_response :success
    assert_select "nav a[href=?]", notes_path
    assert_no_match(/← Notes/, @response.body)
  end

  test "update links a note to a recipe and a document from the same household" do
    note = notes(:alpha_idea)
    patch note_path(note), params: { note: {
      title: note.title, recipe_id: recipes(:alpha_pancakes).id, document_id: documents(:alpha_doc).id
    } }
    assert_redirected_to notes_path
    assert_equal recipes(:alpha_pancakes), note.reload.recipe
    assert_equal documents(:alpha_doc), note.reload.document
  end

  test "update rejects a recipe from another household" do
    note = notes(:alpha_idea)
    patch note_path(note), params: { note: { title: note.title, recipe_id: recipes(:beta_soup).id } }
    assert_response :unprocessable_entity
    assert_nil note.reload.recipe
  end

  test "index renders rich text formatting and escapes raw html" do
    households(:alpha).notes.create!(title: "Riche", content: "**gras** et *italique*\n# Titre\n- item")
    get notes_path
    assert_response :success
    assert_includes @response.body, "<strong>gras</strong>"
    assert_includes @response.body, "<em>italique</em>"
    assert_select "h3", text: "Titre"
    assert_select "li", text: "item"
  end

  test "index escapes html injected through note content" do
    households(:alpha).notes.create!(title: "XSS", content: "<script>alert(1)</script>")
    get notes_path
    assert_response :success
    assert_not_includes @response.body, "<script>alert(1)</script>"
    assert_includes @response.body, "&lt;script&gt;"
  end

  test "index paginates when there are more notes than the page size" do
    households(:alpha).notes.active.general.destroy_all
    (NotesController::PER_PAGE + 1).times { |i| households(:alpha).notes.create!(title: "Note #{'%02d' % i}") }

    get notes_path
    assert_select "#notes > div", count: NotesController::PER_PAGE

    get notes_path(page: 2)
    assert_select "#notes > div", count: 1
  end
end
