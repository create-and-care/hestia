require "test_helper"

class DashboardControllerTest < ActionDispatch::IntegrationTest
  test "redirects to login when unauthenticated" do
    get root_path
    assert_redirected_to new_session_path
  end

  test "redirects to onboarding when the user has no household" do
    user = User.create!(name: "Dan", email_address: "dan@example.com", password: "secret123")
    sign_in_as(user)

    get root_path
    assert_redirected_to onboarding_path
  end

  test "shows the active household and its members for a member" do
    sign_in_as(users(:one))

    get root_path
    assert_response :success
    assert_select "h2", text: households(:alpha).name
    assert_select "code", text: households(:alpha).invite_code
  end

  test "two households do not share members" do
    assert_not_includes households(:alpha).users, users(:two)
    assert_not_includes households(:beta).users, users(:one)
  end

  test "surfaces a vehicle with an urgent or expired inspection" do
    sign_in_as(users(:one))
    households(:alpha).vehicles.create!(name: "Urgent Car", inspection_expires_on: 10.days.from_now.to_date)

    get root_path

    assert_response :success
    assert_includes @response.body, "Urgent Car"
  end

  test "does not surface a vehicle with an up-to-date inspection" do
    sign_in_as(users(:one))
    households(:alpha).vehicles.create!(name: "Fine Car", inspection_expires_on: 200.days.from_now.to_date)

    get root_path

    assert_response :success
    assert_not_includes @response.body, "Fine Car"
  end

  test "surfaces a plant with overdue or soon-due care" do
    sign_in_as(users(:one))

    get root_path

    assert_response :success
    assert_includes @response.body, "Rosier"
  end

  test "does not surface a plant with up-to-date care" do
    sign_in_as(users(:one))
    plant = households(:alpha).plants.create!(name: "Bien entretenue")
    plant.plant_care_tasks.create!(care_type: "watering", frequency: "weekly", next_due_on: 3.weeks.from_now.to_date)

    get root_path

    assert_response :success
    assert_not_includes @response.body, "Bien entretenue"
  end

  test "hides plants needing attention when the outdoor module is disabled" do
    households(:alpha).update!(disabled_modules: [ "outdoor" ])
    sign_in_as(users(:one))

    get root_path

    assert_response :success
    assert_not_includes @response.body, "Rosier"
  end

  test "the sidebar hides a module the household has disabled" do
    households(:alpha).update!(disabled_modules: [ "shopping" ])
    sign_in_as(users(:one))

    get root_path

    assert_response :success
    assert_no_match %r{href="/shopping_lists"}, @response.body
    assert_match %r{href="/fridge"}, @response.body
  end

  test "surfaces a fridge item close to expiring" do
    sign_in_as(users(:one))
    households(:alpha).fridge_items.create!(name: "Yaourts", location: "refrigerateur", expires_on: 1.day.from_now.to_date)

    get root_path

    assert_response :success
    assert_includes @response.body, "Yaourts"
  end

  test "does not surface a fridge item far from expiring" do
    sign_in_as(users(:one))
    households(:alpha).fridge_items.create!(name: "Conserve", location: "garde_manger", expires_on: 200.days.from_now.to_date)

    get root_path

    assert_response :success
    assert_not_includes @response.body, "Conserve"
  end

  test "hides fridge items when the fridge module is disabled" do
    households(:alpha).update!(disabled_modules: [ "fridge" ])
    sign_in_as(users(:one))
    households(:alpha).fridge_items.create!(name: "Yaourts", location: "refrigerateur", expires_on: 1.day.from_now.to_date)

    get root_path

    assert_response :success
    assert_not_includes @response.body, "Yaourts"
  end

  test "surfaces an overdue task" do
    sign_in_as(users(:one))
    households(:alpha).tasks.create!(title: "Appeler le plombier", due_on: 3.days.ago.to_date, done: false)

    get root_path

    assert_response :success
    assert_includes @response.body, "Appeler le plombier"
  end

  test "does not surface a completed overdue task" do
    sign_in_as(users(:one))
    households(:alpha).tasks.create!(title: "Déjà fait", due_on: 3.days.ago.to_date, done: true)

    get root_path

    assert_response :success
    assert_not_includes @response.body, "Déjà fait"
  end

  test "hides overdue tasks when the tasks module is disabled" do
    households(:alpha).update!(disabled_modules: [ "tasks" ])
    sign_in_as(users(:one))
    households(:alpha).tasks.create!(title: "Appeler le plombier", due_on: 3.days.ago.to_date, done: false)

    get root_path

    assert_response :success
    assert_not_includes @response.body, "Appeler le plombier"
  end

  test "surfaces a birthday within the next week" do
    sign_in_as(users(:one))
    households(:alpha).contacts.create!(name: "Mamie", born_on: 3.days.from_now.to_date - 80.years)

    get root_path

    assert_response :success
    assert_includes @response.body, "Mamie"
  end

  test "does not surface a birthday far in the future" do
    sign_in_as(users(:one))
    households(:alpha).contacts.create!(name: "Lointain", born_on: (Date.current + 6.months) - 30.years)

    get root_path

    assert_response :success
    assert_not_includes @response.body, "Lointain"
  end

  test "hides birthdays when the birthdays module is disabled" do
    households(:alpha).update!(disabled_modules: [ "birthdays" ])
    sign_in_as(users(:one))
    households(:alpha).contacts.create!(name: "Mamie", born_on: 3.days.from_now.to_date - 80.years)

    get root_path

    assert_response :success
    assert_not_includes @response.body, "Mamie"
  end

  test "surfaces an upcoming calendar event" do
    sign_in_as(users(:one))
    # Not "Anniversaire": that is also the French label of the Birthdays
    # module in the sidebar, so the assertion passed for the wrong reason in
    # one locale and failed in the other.
    households(:alpha).calendar_events.create!(title: "Zorglub", starts_at: 2.days.from_now, ends_at: 2.days.from_now + 1.hour)

    get root_path

    assert_response :success
    assert_includes @response.body, "Zorglub"
  end

  test "does not surface a past calendar event" do
    sign_in_as(users(:one))
    households(:alpha).calendar_events.create!(title: "Passé", starts_at: 2.days.ago, ends_at: 2.days.ago + 1.hour)

    get root_path

    assert_response :success
    assert_not_includes @response.body, "Passé"
  end

  test "hides upcoming events when the calendar module is disabled" do
    households(:alpha).update!(disabled_modules: [ "calendar" ])
    sign_in_as(users(:one))
    households(:alpha).calendar_events.create!(title: "Zorglub", starts_at: 2.days.from_now, ends_at: 2.days.from_now + 1.hour)

    get root_path

    assert_response :success
    assert_not_includes @response.body, "Zorglub"
  end

  test "surfaces a recipe suggestion built from fridge contents" do
    sign_in_as(users(:one))
    households(:alpha).fridge_items.create!(name: "Farine", location: "garde_manger")
    recipe = households(:alpha).recipes.create!(title: "Crêpes")
    recipe.recipe_ingredients.create!(name: "Farine")

    get root_path

    assert_response :success
    assert_includes @response.body, "Crêpes"
  end

  test "hides recipe suggestions when the recipes module is disabled" do
    households(:alpha).update!(disabled_modules: [ "recipes" ])
    sign_in_as(users(:one))
    households(:alpha).fridge_items.create!(name: "Farine", location: "garde_manger")
    recipe = households(:alpha).recipes.create!(title: "Crêpes")
    recipe.recipe_ingredients.create!(name: "Farine")

    get root_path

    assert_response :success
    assert_not_includes @response.body, "Crêpes"
  end

  # ── Bounded loading (PERF-04/PERF-05) ────────────────────────────────────
  # Every widget keeps five rows. It used to get there by loading the whole
  # relation and filtering in Ruby, so the page's cost grew with the age of the
  # household rather than with what it displays. These tests fail if that ever
  # comes back: they watch the SQL, because the rendered output is identical
  # either way.
  test "the widgets narrow in SQL rather than loading whole relations" do
    sign_in_as(users(:one))
    seed_a_busy_household

    queries = capture_sql { get root_path }
    assert_response :success

    %w[fridge_items tasks calendar_events contacts vehicles].each do |table|
      unbounded = queries.grep(/FROM "#{table}"/).reject { |sql| bounded?(sql) }
      assert_empty unbounded, "#{table} is still read without a bound:\n#{unbounded.join("\n")}"
    end
  end

  test "an old recurring event is not expanded from its first occurrence" do
    sign_in_as(users(:one))
    # Weekly since 2015: ~570 past occurrences, none of which any window
    # starting today can contain. The previous expansion walked all of them
    # and gave up at its 1 000-iteration guard.
    households(:alpha).calendar_events.create!(title: "Poubelles", starts_at: Time.zone.local(2015, 1, 5, 8),
      frequency: "weekly", recurrence_interval: 1)

    get root_path

    assert_response :success
    assert_includes @response.body, "Poubelles"
  end

  test "a series that ended long ago is never loaded at all" do
    sign_in_as(users(:one))
    households(:alpha).calendar_events.create!(title: "Cours de piano", starts_at: 5.years.ago,
      frequency: "weekly", recurrence_interval: 1, recurrence_until: 4.years.ago.to_date)

    get root_path

    assert_response :success
    assert_not_includes @response.body, "Cours de piano"
  end

  private
    # A query is bounded when it caps the rows (LIMIT), narrows on a date or a
    # set of values (the widgets' scopes), or reads a single column.
    #
    # That last case is Frigo::SuggestRecipes, which plucks every fridge item's
    # name to match against recipe ingredients. It is unbounded by nature — the
    # match needs the whole larder — but one text column is not the same cost as
    # instantiating every row, so it is out of PERF-04's scope rather than an
    # oversight.
    def bounded?(sql)
      sql.match?(/LIMIT|IN \(|EXTRACT|>=|<=|<|>/) || sql.match?(/\ASELECT "\w+"\."\w+" FROM/)
    end

    def seed_a_busy_household
      household = households(:alpha)
      50.times do |index|
        household.fridge_items.create!(name: "Yaourt #{index}", location: "refrigerateur", expires_on: index.days.from_now.to_date)
        household.tasks.create!(title: "Tâche #{index}", due_on: (index - 25).days.from_now.to_date)
        household.contacts.create!(name: "Ami #{index}", born_on: Date.new(1990, 1, 1) + index.days)
        household.calendar_events.create!(title: "RDV #{index}", starts_at: (index - 25).days.from_now, frequency: "none")
      end
    end

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
