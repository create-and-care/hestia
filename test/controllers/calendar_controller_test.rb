require "test_helper"

class CalendarControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as(users(:one)) }

  test "requires authentication" do
    sign_out
    get calendar_path
    assert_redirected_to new_session_path
  end

  test "month view renders and wires the real-time stream" do
    get calendar_path
    assert_response :success
    assert_select "turbo-cable-stream-source"
  end

  test "list view shows the household's upcoming events only" do
    get calendar_path(view: :list)
    assert_response :success
    assert_includes @response.body, "Réunion"
    assert_not_includes @response.body, "Événement Beta"
  end
end
