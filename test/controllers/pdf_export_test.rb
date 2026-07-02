require "test_helper"

class PdfExportTest < ActionDispatch::IntegrationTest
  setup { sign_in_as(users(:one)) }

  test "exports a shopping list as PDF" do
    get shopping_list_path(shopping_lists(:alpha_groceries), format: :pdf)
    assert_response :success
    assert_equal "application/pdf", @response.media_type
    assert @response.body.start_with?("%PDF")
  end

  test "exports the calendar month as PDF" do
    get calendar_path(format: :pdf)
    assert_response :success
    assert_equal "application/pdf", @response.media_type
    assert @response.body.start_with?("%PDF")
  end

  test "PDF export is scoped to the household" do
    get shopping_list_path(shopping_lists(:beta_groceries), format: :pdf)
    assert_response :not_found
  end
end
