module SidebarHelper
  SIDEBAR_GROUPS = [
    { key: "daily", emoji: "📌", open: true, items: [
      [ "🛒", :shopping, -> { shopping_lists_path } ],
      [ "🧊", :fridge, -> { fridge_path } ],
      [ "📖", :recipes, -> { recipes_path } ],
      [ "🍽", :menu, -> { menu_path } ],
      [ "✅", :tasks, -> { tasks_path } ],
      [ "📅", :calendar, -> { calendar_path } ],
      [ "🔁", :routines, -> { routines_path } ]
    ] },
    { key: "home", emoji: "🏡", open: false, items: [
      [ "📝", :notes, -> { notes_path } ],
      [ "📍", :addresses, -> { addresses_path } ],
      [ "🧰", :service_providers, -> { service_providers_path } ],
      [ "🚗", :vehicles, -> { vehicles_path } ],
      [ "🍷", :wine_cellar, -> { wine_cellars_path } ],
      [ "🗑", :waste, -> { waste_path } ],
      [ "📄", :documents, -> { documents_path } ],
      [ "🌳", :outdoor, -> { exterior_path } ],
      [ "💶", :budget, -> { budget_path } ]
    ] },
    { key: "family", emoji: "👨‍👩‍👧", open: false, items: [
      [ "🎂", :birthdays, -> { contacts_path } ],
      [ "👶", :baby, -> { baby_profiles_path } ],
      [ "🐾", :pets, -> { pets_path } ],
      [ "🧘", :wellbeing, -> { wellbeing_path } ]
    ] },
    { key: "social", emoji: "🤝", open: false, items: [
      [ "💬", :messages, -> { conversations_path } ],
      [ "💳", :loyalty, -> { loyalty_cards_path } ],
      [ "🎁", :gifts, -> { gift_lists_path } ],
      [ "👥", :circles, -> { circles_path } ],
      [ "🧳", :trips, -> { trips_path } ]
    ] }
  ].freeze

  # Resolves the SIDEBAR_GROUPS route lambdas and translations lazily, so this
  # helper stays a plain data source (module labels reuse dashboard.show.nav.*
  # so there is a single source of truth for each module's display name).
  def sidebar_groups
    SIDEBAR_GROUPS.map do |group|
      {
        key: group[:key],
        emoji: group[:emoji],
        open: group[:open],
        label: t("sidebar.groups.#{group[:key]}"),
        items: group[:items].map { |emoji, nav_key, path|
          { emoji: emoji, label: t("dashboard.show.nav.#{nav_key}"), path: instance_exec(&path) }
        }
      }
    end
  end
end
