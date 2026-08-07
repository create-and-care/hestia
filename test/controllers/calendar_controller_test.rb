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

  test "the member and public-holiday filters live inside a sheet" do
    get calendar_path
    assert_response :success
    assert_select "[data-controller='dialog'] select#calendar_member_id"
    assert_select "[data-controller='dialog'] select#household_holiday_country"
  end

  # The filter form used to submit only `view`, so filtering by member from any
  # month but the current one snapped the calendar back to today.
  test "the member filter keeps the month being displayed" do
    get calendar_path(view: "month", month: "2030-03")
    assert_response :success
    assert_select "form[action=?] input[name='month'][value=?]", calendar_path, "2030-03"
  end

  test "the list view clips its rows to the container's rounded corners" do
    get calendar_path(view: :list)
    assert_response :success
    assert_select "div.overflow-hidden.rounded-lg.border"
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

  test "surfaces an overdue pet vaccine booster in the list view" do
    pet = households(:alpha).pets.create!(name: "Rex")
    pet.pet_vaccinations.create!(name: "Rage", booster_on: 2.days.ago.to_date)
    get calendar_path(view: :list)
    assert_includes @response.body, "Rex"
    assert_includes @response.body, "Rage"
  end

  test "does not surface a pet vaccine booster that is not overdue" do
    pet = households(:alpha).pets.create!(name: "Milo")
    pet.pet_vaccinations.create!(name: "Rage", booster_on: 2.days.from_now.to_date)
    get calendar_path(view: :list)
    assert_not_includes @response.body, "Milo"
  end

  test "surfaces an overdue plant care task in the list view" do
    get calendar_path(view: :list)
    assert_includes @response.body, "Rosier"
  end

  test "does not surface a plant care task that is not overdue" do
    plant = households(:alpha).plants.create!(name: "Pas en retard")
    plant.plant_care_tasks.create!(care_type: "watering", frequency: "weekly", next_due_on: 3.days.from_now.to_date)
    get calendar_path(view: :list)
    assert_not_includes @response.body, "Pas en retard"
  end

  test "surfaces an upcoming waste collection in the list view" do
    households(:alpha).waste_collection_events.create!(waste_type: "recyclage", collected_on: 2.days.from_now.to_date)
    get calendar_path(view: :list)
    assert_body_includes I18n.t("waste.types.recyclage")
  end

  test "PDF export excludes waste collections (they aren't CalendarEvent records)" do
    households(:alpha).waste_collection_events.create!(waste_type: "recyclage", collected_on: Date.current + 2.days)
    get calendar_path(format: :pdf)
    assert_response :success
  end

  test "surfaces every day of a trip in the list view" do
    households(:alpha).trips.create!(name: "Chalet", starts_on: 2.days.from_now.to_date, ends_on: 4.days.from_now.to_date)
    get calendar_path(view: :list)
    assert_includes @response.body, "Chalet"
  end

  test "PDF export excludes trips (they aren't CalendarEvent records)" do
    households(:alpha).trips.create!(name: "Chalet", starts_on: Date.current + 2.days, ends_on: Date.current + 4.days)
    get calendar_path(format: :pdf)
    assert_response :success
  end

  test "PDF export does not crash when a birthday falls within the month" do
    households(:alpha).contacts.create!(name: "Papi", born_on: Date.current.change(year: 1945))
    get calendar_path(format: :pdf)
    assert_response :success
  end
end
