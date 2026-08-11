require "test_helper"

class TodayControllerTest < ActionDispatch::IntegrationTest
  test "redirects to login when unauthenticated" do
    get today_path
    assert_redirected_to new_session_path
  end

  test "surfaces an overdue task" do
    sign_in_as(users(:one))
    households(:alpha).tasks.create!(title: "Appeler le plombier", due_on: 3.days.ago.to_date, done: false)

    get today_path

    assert_response :success
    assert_includes @response.body, "Appeler le plombier"
  end

  test "surfaces a fridge item close to expiring" do
    sign_in_as(users(:one))
    households(:alpha).fridge_items.create!(name: "Yaourts", location: "refrigerateur", expires_on: 1.day.from_now.to_date)

    get today_path

    assert_response :success
    assert_includes @response.body, "Yaourts"
  end

  test "hides fridge items when the fridge module is disabled" do
    households(:alpha).update!(disabled_modules: [ "fridge" ])
    sign_in_as(users(:one))
    households(:alpha).fridge_items.create!(name: "Yaourts", location: "refrigerateur", expires_on: 1.day.from_now.to_date)

    get today_path

    assert_response :success
    assert_not_includes @response.body, "Yaourts"
  end

  test "surfaces a plant with overdue or soon-due care" do
    sign_in_as(users(:one))

    get today_path

    assert_response :success
    assert_includes @response.body, "Rosier"
  end

  test "surfaces a calendar event happening today" do
    sign_in_as(users(:one))
    households(:alpha).calendar_events.create!(title: "Zorglub", starts_at: Time.current.middle_of_day, ends_at: Time.current.middle_of_day + 1.hour)

    get today_path

    assert_response :success
    assert_includes @response.body, "Zorglub"
  end

  test "does not surface a calendar event happening tomorrow" do
    sign_in_as(users(:one))
    households(:alpha).calendar_events.create!(title: "Demain", starts_at: 1.day.from_now, ends_at: 1.day.from_now + 1.hour)

    get today_path

    assert_response :success
    assert_not_includes @response.body, "Demain"
  end

  test "surfaces a birthday today" do
    sign_in_as(users(:one))
    households(:alpha).contacts.create!(name: "Mamie", born_on: Date.current - 80.years)

    get today_path

    assert_response :success
    assert_includes @response.body, "Mamie"
  end

  test "still surfaces a birthday today when the calendar module is disabled" do
    households(:alpha).update!(disabled_modules: [ "calendar" ])
    sign_in_as(users(:one))
    households(:alpha).contacts.create!(name: "Mamie", born_on: Date.current - 80.years)

    get today_path

    assert_response :success
    assert_includes @response.body, "Mamie"
  end

  test "hides a calendar event happening today when the calendar module is disabled" do
    households(:alpha).update!(disabled_modules: [ "calendar" ])
    sign_in_as(users(:one))
    households(:alpha).calendar_events.create!(title: "Zorglub", starts_at: Time.current.middle_of_day, ends_at: Time.current.middle_of_day + 1.hour)

    get today_path

    assert_response :success
    assert_not_includes @response.body, "Zorglub"
  end

  test "surfaces an overdue vaccine booster" do
    sign_in_as(users(:one))
    pets(:alpha_dog).pet_vaccinations.create!(name: "Rage", booster_on: 3.days.ago.to_date)

    get today_path

    assert_response :success
    assert_includes @response.body, "Rage"
  end

  test "surfaces a waste collection happening today" do
    sign_in_as(users(:one))
    households(:alpha).waste_collection_events.create!(waste_type: "verre", collected_on: Date.current)

    get today_path

    assert_response :success
    assert_includes @response.body, "Glass"
  end

  test "surfaces a trip spanning today and excludes one entirely outside the window" do
    sign_in_as(users(:one))
    households(:alpha).trips.create!(name: "Chalet", starts_on: 1.day.ago.to_date, ends_on: 1.day.from_now.to_date)
    households(:alpha).trips.create!(name: "Lointain", starts_on: 30.days.from_now.to_date, ends_on: 32.days.from_now.to_date)

    get today_path

    assert_response :success
    assert_includes @response.body, "Chalet"
    assert_not_includes @response.body, "Lointain"
  end

  test "does not claim there are no events when an overdue box is the only thing shown" do
    sign_in_as(users(:one))
    pets(:alpha_dog).pet_vaccinations.create!(name: "Rage", booster_on: 3.days.ago.to_date)

    get today_path

    assert_response :success
    assert_includes @response.body, "Rage"
    assert_not_includes @response.body, I18n.t("calendar.show.no_events")
  end

  test "date-only occurrences anchor in the household's time zone rather than the server's own" do
    previous_tz = ENV["TZ"]
    ENV["TZ"] = "America/Los_Angeles"

    household = households(:alpha)
    household.update!(time_zone: "Auckland")
    sign_in_as(users(:one))

    household_today = household.in_time_zone { Date.current }
    household.contacts.create!(name: "Mamie", born_on: household_today - 80.years)
    household.calendar_events.create!(title: "Reunion",
      starts_at: household.in_time_zone { Time.zone.now.middle_of_day },
      ends_at: household.in_time_zone { Time.zone.now.middle_of_day + 1.hour })

    get today_path

    assert_response :success
    assert_includes @response.body, "Mamie"
    assert_includes @response.body, "Reunion"
    # A birthday anchors at the start of the household's day, so it must sort
    # before a same-day timed event — regardless of what zone the server itself
    # runs in (ENV["TZ"] above is deliberately a different zone than Auckland).
    assert_operator @response.body.index("Mamie"), :<, @response.body.index("Reunion")
  ensure
    ENV["TZ"] = previous_tz
  end

  test "the calendar events query narrows to today rather than loading the whole household history" do
    sign_in_as(users(:one))
    households(:alpha).calendar_events.create!(title: "Zorglub", starts_at: Time.current.middle_of_day, ends_at: Time.current.middle_of_day + 1.hour)
    households(:alpha).calendar_events.create!(title: "Vieux", starts_at: 3.years.ago, ends_at: 3.years.ago + 1.hour)

    queries = capture_sql { get today_path }
    assert_response :success

    unbounded = queries.grep(/FROM "calendar_events"/).reject { |sql| sql.match?(/starts_at|recurrence_until/) }
    assert_empty unbounded, "calendar_events is still read without a bound:\n#{unbounded.join("\n")}"
  end

  private
    def capture_sql
      queries = []
      subscriber = ActiveSupport::Notifications.subscribe("sql.active_record") do |_, _, _, _, payload|
        queries << payload[:sql] unless payload[:name].in?([ "SCHEMA", "TRANSACTION" ])
      end
      yield
      queries
    ensure
      ActiveSupport::Notifications.unsubscribe(subscriber)
    end
end
