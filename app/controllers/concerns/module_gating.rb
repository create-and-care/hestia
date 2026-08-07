module ModuleGating
  extend ActiveSupport::Concern

  # Maps every module-owned controller to the SidebarHelper::SIDEBAR_GROUPS key
  # an admin can disable it under (Household#module_enabled?).
  #
  # One list, both surfaces. Keys are written unprefixed and the JSON API's
  # `api/v1/` prefix is stripped before lookup (see .module_for), so
  # Api::V1::TasksController is gated by the same "tasks" entry as
  # TasksController. Two parallel lists would drift, and the drift would be
  # invisible — a disabled module staying readable and writable by API token
  # while the web UI correctly refuses it.
  #
  # Nothing here is optional to maintain: ModuleGatingTest walks the route set
  # and fails on any app controller that is neither mapped here nor listed in
  # UNGATED_CONTROLLERS below. Adding a module controller without an entry is a
  # red build, not a silent hole.
  CONTROLLER_MODULES = {
    "shopping_lists" => "shopping", "shopping_list_items" => "shopping", "products" => "shopping",
    "fridge" => "fridge", "fridge_items" => "fridge", "prepared_dishes" => "fridge",
    # recipe_catalog is the "Découvrir" tab of the Recipes module, not a
    # separate feature — disabling Recipes has to close it too.
    "recipes" => "recipes", "recipe_catalog" => "recipes",
    "menu" => "menu", "meal_plan_entries" => "menu",
    "tasks" => "tasks", "task_categories" => "tasks", "task_reminders" => "tasks",
    "calendar" => "calendar", "calendar_events" => "calendar", "event_reminders" => "calendar", "external_calendar_connections" => "calendar",
    "routines" => "routines",

    "notes" => "notes",
    "addresses" => "addresses",
    "service_providers" => "service_providers", "service_provider_types" => "service_providers",
    "vehicles" => "vehicles", "vehicle_maintenance_entries" => "vehicles",
    "wine_cellars" => "wine_cellar", "bottles" => "wine_cellar",
    "waste" => "waste", "waste_collection_series" => "waste", "waste_collection_events" => "waste",
    "documents" => "documents", "document_folders" => "documents",
    # Garden and Pool share the "outdoor" toggle (both live on the same
    # ExteriorController#show page and template), but Pool also has its own
    # finer-grained Household#pool_enabled flag for households with no pool
    # — see POOL_GATED_CONTROLLERS/ensure_pool_enabled! below.
    "exterior" => "outdoor", "plants" => "outdoor", "plant_care_tasks" => "outdoor",
    "pools" => "outdoor", "pool_readings" => "outdoor", "pool_actions" => "outdoor",
    "budget" => "budget", "budget_categories" => "budget", "budget_entries" => "budget", "savings_envelopes" => "budget",
    "shared_projects" => "budget", "shared_project_participants" => "budget", "shared_expenses" => "budget",

    "contacts" => "birthdays", "contact_tags" => "birthdays",
    "baby_profiles" => "baby", "feeding_sessions" => "baby", "food_introductions" => "baby", "allergen_tests" => "baby",
    "pets" => "pets", "pet_vaccinations" => "pets", "pet_treatments" => "pets", "pet_supplies" => "pets",
    "wellbeing" => "wellbeing", "wellbeing_profiles" => "wellbeing", "weight_entries" => "wellbeing", "workout_entries" => "wellbeing",
    "workout_templates" => "wellbeing", "workout_template_exercises" => "wellbeing",

    "conversations" => "messages", "messages" => "messages",
    "loyalty_cards" => "loyalty",
    "gift_lists" => "gifts", "gift_ideas" => "gifts", "gift_list_shares" => "gifts",
    # Circle data is cross-household, but access is still
    # gated on the *current* household's module toggle: this is the household
    # admin's control over which features their own members can use, not a
    # claim of ownership over the Circle itself — a member could belong to
    # several households and see this module gated differently in each.
    "circles" => "circles", "circle_memberships" => "circles", "circle_posts" => "circles", "circle_post_reactions" => "circles",
    "trips" => "trips", "trips/addresses" => "trips", "trips/notes" => "trips", "trips/shopping_lists" => "trips",
    "trips/tasks" => "trips", "trips/meal_plan_entries" => "trips"
  }.freeze

  # Controllers that are deliberately never gated. Listing them is what lets
  # ModuleGatingTest treat "absent from both lists" as a failure rather than as
  # an implicit exemption — an unlisted controller is an unanswered question,
  # not a decision.
  UNGATED_CONTROLLERS = %w[
    accounts active_sessions api_tokens households locales memberships onboarding
    notifications notification_preferences
    passwords registrations sessions
    dashboard design_system roadmap
    public_gift_lists
    searches
  ].freeze
  # accounts/active_sessions/api_tokens/passwords/registrations/sessions — the
  #   account itself, which no household toggle may lock its owner out of.
  # households/memberships/locales/onboarding — including the settings page
  #   carrying the module toggles: gating it would make a module that got
  #   switched off impossible to switch back on.
  # dashboard/design_system/roadmap — global pages, not owned by a module.
  # public_gift_lists — unauthenticated by design, with no Current.household to
  #   consult; guarded by the share token and its own rate limits instead.
  # searches — spans every module at once, so it gates per *result* rather than
  #   per request: GlobalSearch skips any definition whose module_key is
  #   disabled (global_search.rb), which is the finer control, not a missing one.

  # Sits below the "outdoor" module toggle: even when Extérieur is enabled,
  # a household without a pool can turn Pool off on its own without also
  # hiding the garden.
  POOL_GATED_CONTROLLERS = %w[pools pool_readings pool_actions].freeze

  # The JSON API mirrors the web controllers one for one, so it reuses their
  # entries rather than duplicating them: api/v1/tasks is looked up as tasks.
  API_NAMESPACE = %r{\Aapi/v\d+/}

  included do
    before_action :ensure_module_enabled!
    before_action :ensure_pool_enabled!
  end

  def self.gated_path(controller_path)
    controller_path.sub(API_NAMESPACE, "")
  end

  def self.module_for(controller_path)
    CONTROLLER_MODULES[gated_path(controller_path)]
  end

  def self.pool_gated?(controller_path)
    POOL_GATED_CONTROLLERS.include?(gated_path(controller_path))
  end

  private
    def ensure_module_enabled!
      key = ModuleGating.module_for(controller_path)
      return if key.nil? || Current.household.nil? || Current.household.module_enabled?(key)

      deny_disabled_module
    end

    def ensure_pool_enabled!
      return unless ModuleGating.pool_gated?(controller_path)
      return if Current.household.nil? || Current.household.pool_enabled?

      deny_disabled_module
    end

    # The HTML answer. Api::V1::BaseController overrides this with a 403 JSON
    # body — same decision, rendered for whoever asked.
    def deny_disabled_module
      redirect_to root_path, alert: t("modules.disabled_alert")
    end
end
