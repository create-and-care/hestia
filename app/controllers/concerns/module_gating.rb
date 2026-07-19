module ModuleGating
  extend ActiveSupport::Concern

  # Maps every module-owned web controller to the SidebarHelper::SIDEBAR_GROUPS
  # key an admin can disable it under (Household#module_enabled?). Controllers
  # not listed here (account/global pages, the household settings page itself,
  # the public unauthenticated gift-list routes) are never gated. The JSON API
  # (Api::V1::*) is a separate, token-authenticated surface and isn't covered.
  #
  # Add new module controllers here as they're introduced, or disabling that
  # module won't actually block direct access to them.
  CONTROLLER_MODULES = {
    "shopping_lists" => "shopping", "shopping_list_items" => "shopping", "products" => "shopping",
    "fridge" => "fridge", "fridge_items" => "fridge", "prepared_dishes" => "fridge",
    "recipes" => "recipes",
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
    # Garden and Pool share a single "outdoor" toggle (Spec §11.3 asks for a
    # separate Pool switch): both live on the same ExteriorController#show page
    # and template, so gating them independently would mean conditionally
    # rendering half of one controller's view rather than a second entry here
    # — a real architecture change, not a config tweak. Documented per the
    # audit's own fallback rather than attempted half-done.
    "exterior" => "outdoor", "plants" => "outdoor", "pools" => "outdoor", "pool_readings" => "outdoor", "pool_actions" => "outdoor",
    "budget" => "budget", "budget_categories" => "budget", "budget_entries" => "budget", "savings_envelopes" => "budget",
    "shared_projects" => "budget", "shared_project_participants" => "budget", "shared_expenses" => "budget",

    "contacts" => "birthdays", "contact_tags" => "birthdays",
    "baby_profiles" => "baby", "feeding_sessions" => "baby", "food_introductions" => "baby", "allergen_tests" => "baby",
    "pets" => "pets", "pet_vaccinations" => "pets", "pet_treatments" => "pets", "pet_supplies" => "pets",
    "wellbeing" => "wellbeing", "wellbeing_profiles" => "wellbeing", "weight_entries" => "wellbeing", "workout_entries" => "wellbeing",

    "conversations" => "messages", "messages" => "messages",
    "loyalty_cards" => "loyalty",
    "gift_lists" => "gifts", "gift_ideas" => "gifts", "gift_list_shares" => "gifts",
    # Circle data is cross-household (Spec §5, point 1), but access is still
    # gated on the *current* household's module toggle: this is the household
    # admin's control over which features their own members can use, not a
    # claim of ownership over the Circle itself — a member could belong to
    # several households and see this module gated differently in each.
    "circles" => "circles", "circle_memberships" => "circles", "circle_posts" => "circles", "circle_post_reactions" => "circles",
    "trips" => "trips", "trips/addresses" => "trips", "trips/notes" => "trips", "trips/shopping_lists" => "trips", "trips/tasks" => "trips"
  }.freeze

  included do
    before_action :ensure_module_enabled!
  end

  private
    def ensure_module_enabled!
      key = CONTROLLER_MODULES[controller_path]
      return if key.nil? || Current.household.nil? || Current.household.module_enabled?(key)

      redirect_to root_path, alert: t("modules.disabled_alert")
    end
end
