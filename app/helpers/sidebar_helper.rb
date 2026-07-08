module SidebarHelper
  # Icon names are Lucide (https://lucide.dev) icon ids, rendered via
  # IconHelper#lucide_icon.
  SIDEBAR_GROUPS = [
    { key: "daily", icon: "list-checks", open: false, items: [
      [ "shopping-cart", :shopping, -> { shopping_lists_path } ],
      [ "refrigerator", :fridge, -> { fridge_path } ],
      [ "book-open", :recipes, -> { recipes_path } ],
      [ "utensils", :menu, -> { menu_path } ],
      [ "square-check", :tasks, -> { tasks_path } ],
      [ "calendar", :calendar, -> { calendar_path } ],
      [ "repeat", :routines, -> { routines_path } ]
    ] },
    { key: "home", icon: "house", open: false, items: [
      [ "notebook-pen", :notes, -> { notes_path } ],
      [ "map-pin", :addresses, -> { addresses_path } ],
      [ "wrench", :service_providers, -> { service_providers_path } ],
      [ "car", :vehicles, -> { vehicles_path } ],
      [ "wine", :wine_cellar, -> { wine_cellars_path } ],
      [ "trash-2", :waste, -> { waste_path } ],
      [ "file-text", :documents, -> { documents_path } ],
      [ "trees", :outdoor, -> { exterior_path } ],
      [ "euro", :budget, -> { budget_path } ]
    ] },
    { key: "family", icon: "users-round", open: false, items: [
      [ "cake", :birthdays, -> { contacts_path } ],
      [ "baby", :baby, -> { baby_profiles_path } ],
      [ "paw-print", :pets, -> { pets_path } ],
      [ "heart-pulse", :wellbeing, -> { wellbeing_path } ]
    ] },
    { key: "social", icon: "handshake", open: false, items: [
      [ "message-circle", :messages, -> { conversations_path } ],
      [ "credit-card", :loyalty, -> { loyalty_cards_path } ],
      [ "gift", :gifts, -> { gift_lists_path } ],
      [ "users", :circles, -> { circles_path } ],
      [ "luggage", :trips, -> { trips_path } ]
    ] }
  ].freeze

  # Resolves the SIDEBAR_GROUPS route lambdas and translations lazily, so this
  # helper stays a plain data source (module labels reuse dashboard.show.nav.*
  # so there is a single source of truth for each module's display name).
  def sidebar_groups
    SIDEBAR_GROUPS.filter_map do |group|
      items = group[:items].filter_map { |icon, nav_key, path|
        next unless current_household.nil? || current_household.module_enabled?(nav_key)

        resolved_path = instance_exec(&path)
        { icon: icon, label: t("dashboard.show.nav.#{nav_key}"), path: resolved_path, active: sidebar_item_active?(resolved_path) }
      }

      next if items.empty?

      {
        key: group[:key],
        icon: group[:icon],
        open: group[:open] || items.any? { |item| item[:active] },
        label: t("sidebar.groups.#{group[:key]}"),
        items: items
      }
    end
  end

  private

    # Matches the item's index path as well as any nested route beneath it
    # (e.g. a conversation show page at /conversations/5 should still count
    # as being on the Messages item), so the parent group stays expanded.
    def sidebar_item_active?(path)
      request.path == path || request.path.start_with?("#{path}/")
    end
end
