require "test_helper"

class QuickCapturesControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as(users(:one)) }

  test "create requires authentication" do
    sign_out
    post quick_capture_path, params: { quick_capture: { text: "Test" } }
    assert_redirected_to new_session_path
  end

  test "create saves the phrase as a note" do
    assert_difference -> { households(:alpha).notes.count }, 1 do
      post quick_capture_path, params: { quick_capture: { text: "Idée de cadeau pour Léa" } }, as: :turbo_stream
    end
    assert_equal "Idée de cadeau pour Léa", households(:alpha).notes.order(:created_at).last.title
  end

  test "a date-looking phrase is saved as a note and offers a task suggestion" do
    post quick_capture_path, params: { quick_capture: { text: "Rendez-vous lundi" } }, as: :turbo_stream
    assert households(:alpha).notes.exists?(title: "Rendez-vous lundi")
    assert_body_includes I18n.t("quick_capture.suggestion_task")
    assert_body_excludes I18n.t("quick_capture.suggestion_shopping")
  end

  test "a phrase naming a known product is saved as a note and offers a shopping suggestion" do
    post quick_capture_path, params: { quick_capture: { text: "Il faut du lait" } }, as: :turbo_stream
    assert households(:alpha).notes.exists?(title: "Il faut du lait")
    assert_body_includes I18n.t("quick_capture.suggestion_shopping")
    assert_body_excludes I18n.t("quick_capture.suggestion_task")
  end

  test "an ordinary phrase is saved as a note with no suggestion" do
    post quick_capture_path, params: { quick_capture: { text: "Idée de cadeau pour Léa" } }, as: :turbo_stream
    assert_response :success
    assert_body_excludes I18n.t("quick_capture.suggestion_task")
    assert_body_excludes I18n.t("quick_capture.suggestion_shopping")
  end

  test "a whitespace-only phrase is not saved and shows an error instead of crashing" do
    assert_no_difference -> { Note.count } do
      post quick_capture_path, params: { quick_capture: { text: "   " } }, as: :turbo_stream
    end
    assert_response :success
    assert_body_includes I18n.t("quick_capture.blank_error")
  end

  test "the turbo_stream response replaces the panel id the request was submitted for" do
    post quick_capture_path, params: { quick_capture: { text: "Test" }, panel_id: "quick_capture_panel_mobile" }, as: :turbo_stream
    assert_turbo_stream action: "replace", target: "quick_capture_panel_mobile"
  end
end
