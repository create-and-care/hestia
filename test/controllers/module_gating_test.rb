require "test_helper"

class ModuleGatingTest < ActionDispatch::IntegrationTest
  test "a disabled module redirects away from its controller" do
    households(:alpha).update!(disabled_modules: [ "shopping" ])
    sign_in_as(users(:one))

    get shopping_lists_path

    assert_redirected_to root_path
    follow_redirect!
    assert_match I18n.t("modules.disabled_alert"), @response.body
  end

  test "a disabled module redirects away from a nested controller under the same module" do
    households(:alpha).update!(disabled_modules: [ "trips" ])
    sign_in_as(users(:one))
    trip = households(:alpha).trips.create!(name: "Ski")

    assert_no_difference -> { trip.tasks.count } do
      post trip_tasks_path(trip), params: { task: { title: "Pack skis" } }
    end

    assert_redirected_to root_path
  end

  test "a disabled messages module blocks reacting to a message" do
    households(:alpha).update!(disabled_modules: [ "messages" ])
    sign_in_as(users(:one))

    assert_no_difference -> { MessageReaction.count } do
      post react_message_path(messages(:alpha_hello), emoji: "❤️")
    end

    assert_redirected_to root_path
  end

  test "a disabled notes module blocks the quick capture endpoint" do
    households(:alpha).update!(disabled_modules: [ "notes" ])
    sign_in_as(users(:one))

    assert_no_difference -> { Note.count } do
      post quick_capture_path, params: { quick_capture: { text: "Acheter du pain" } }
    end

    assert_redirected_to root_path
  end

  test "an enabled module is reachable as usual" do
    sign_in_as(users(:one))

    get shopping_lists_path

    assert_response :success
  end

  test "the household settings page is never gated, even if every module is disabled" do
    households(:alpha).update!(disabled_modules: Household::MODULE_KEYS)
    sign_in_as(users(:one))

    get household_path(households(:alpha))

    assert_response :success
  end

  test "disabling the Pool switch redirects away from pool controllers but not the garden" do
    households(:alpha).update!(pool_enabled: false)
    sign_in_as(users(:one))

    post pools_path, params: { pool: { name: "Spa", treatment_type: "brome" } }
    assert_redirected_to root_path

    post plants_path, params: { plant: { name: "Basilic" } }
    assert_redirected_to exterior_path
  end

  test "the Pool switch does not affect other households' access to pools" do
    households(:beta).update!(pool_enabled: false)
    sign_in_as(users(:one)) # member of :alpha, whose pool_enabled defaults to true

    post pools_path, params: { pool: { name: "Spa", treatment_type: "brome" } }

    assert_redirected_to exterior_path
  end

  # ── Completeness ────────────────────────────────────────────────────────
  # CONTROLLER_MODULES is a hand-maintained hash, and a controller missing from
  # it fails open: no entry means no gate, silently. This walks the route set
  # so that adding a module controller without classifying it is a red build.
  # It found five live holes when it was written — plant_care_tasks,
  # workout_templates, workout_template_exercises, trips/meal_plan_entries and
  # recipe_catalog were all reachable with their module switched off.
  test "every app controller is either mapped to a module or explicitly exempted" do
    unclassified = app_controller_paths.reject do |path|
      ModuleGating::CONTROLLER_MODULES.key?(path) || ModuleGating::UNGATED_CONTROLLERS.include?(path)
    end

    assert_empty unclassified, <<~MESSAGE
      These controllers are in neither ModuleGating::CONTROLLER_MODULES nor
      ModuleGating::UNGATED_CONTROLLERS, so they are ungated by omission:

        #{unclassified.join("\n  ")}

      Add each to CONTROLLER_MODULES with its module key, or to
      UNGATED_CONTROLLERS if it genuinely belongs to no module.
    MESSAGE
  end

  test "no entry maps a controller that no longer exists" do
    mapped = ModuleGating::CONTROLLER_MODULES.keys + ModuleGating::UNGATED_CONTROLLERS

    assert_empty mapped - app_controller_paths, "mapped but unrouted controllers"
  end

  test "every module key used in the map is a real household module" do
    assert_empty ModuleGating::CONTROLLER_MODULES.values.uniq - Household::MODULE_KEYS
  end

  # The JSON API reuses the web entries with its namespace stripped, so every
  # api/v1 controller has to resolve through that map — otherwise it is gated
  # by nothing at all, which is the state SEC-06 found it in.
  test "every api/v1 controller resolves to a module through the shared map" do
    api_paths = routed_controller_paths.select { |path| path.start_with?("api/v1/") }
    assert_operator api_paths.size, :>, 20, "expected the API surface to be routed"

    ungated = api_paths.reject { |path| ModuleGating.module_for(path) }
    assert_empty ungated, "api/v1 controllers with no module mapping: #{ungated.join(", ")}"
  end

  private
    def routed_controller_paths
      Rails.application.routes.routes.filter_map { |route| route.defaults[:controller] }.uniq
    end

    # Only the app's own controllers — Rails' engines (Active Storage, Action
    # Mailbox, /rails/*, Turbo) hold no household data and own no module.
    def app_controller_paths
      routed_controller_paths.select { |path| Rails.root.join("app/controllers/#{path}_controller.rb").exist? }
        .map { |path| ModuleGating.gated_path(path) }
        .uniq
        .sort
    end
end
