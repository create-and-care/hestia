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

  test "week view renders" do
    get calendar_path(view: :week)
    assert_response :success
  end

  test "day view renders" do
    get calendar_path(view: :day)
    assert_response :success
  end

  test "the last view visited is remembered as the user's default" do
    get calendar_path(view: :list)
    assert_equal "list", users(:one).reload.calendar_view

    get calendar_path # no explicit view param this time — should still resolve to "list"
    assert_response :success
    assert_includes @response.body, "Agenda"
  end

  test "month grid links a day cell to pre-fill a new event on that date" do
    get calendar_path(view: :month, month: "2026-08")
    assert_response :success
    assert_includes @response.body, "starts_at=2026-08-15T09%3A00%3A00"
  end

  test "surfaces a contact's birthday in the list view" do
    households(:alpha).contacts.create!(name: "Mamie", born_on: 2.days.from_now.change(year: 1950))
    get calendar_path(view: :list)
    assert_includes @response.body, "Mamie"
  end

  test "surfaces overdue tasks in the list view" do
    households(:alpha).tasks.create!(title: "Tâche en retard", due_on: 2.days.ago.to_date)
    get calendar_path(view: :list)
    assert_includes @response.body, "Tâche en retard"
  end

  test "does not surface tasks that are not overdue" do
    households(:alpha).tasks.create!(title: "Pas en retard", due_on: 2.days.from_now.to_date)
    get calendar_path(view: :list)
    assert_not_includes @response.body, "Pas en retard"
  end

  test "PDF export does not crash when a birthday falls within the month" do
    households(:alpha).contacts.create!(name: "Papi", born_on: Date.current.change(year: 1945))
    get calendar_path(format: :pdf)
    assert_response :success
  end
end
