# Cross-module search powering the sidebar's command palette (Ui::CommandComponent).
# Plain per-model ILIKE queries (no pg_search/ransack) since every searchable
# table is household-scoped and small; group labels/icons reuse the sidebar's
# own taxonomy (SidebarHelper::SIDEBAR_GROUPS / dashboard.show.nav.*) so there
# is a single source of truth for how a module is named and drawn.
class GlobalSearch
  include Rails.application.routes.url_helpers

  RESULT_LIMIT_PER_MODEL = 5

  Definition = Struct.new(:model, :module_key, :icon, :label, :scope, :url, :scoped_by, keyword_init: true) do
    def scoped_by = self[:scoped_by] || :household
  end

  DEFINITIONS = [
    Definition.new(model: Task, module_key: "tasks", icon: "square-check",
      label: ->(r) { r.title },
      scope: ->(household, q) { Task.for_household(household).where("title ILIKE :q OR description ILIKE :q", q: q).limit(RESULT_LIMIT_PER_MODEL) },
      url: ->(r) { edit_task_path(r) }),

    Definition.new(model: Note, module_key: "notes", icon: "notebook-pen",
      label: ->(r) { r.title },
      scope: ->(household, q) { Note.for_household(household).where("title ILIKE :q OR content ILIKE :q", q: q).limit(RESULT_LIMIT_PER_MODEL) },
      url: ->(r) { edit_note_path(r) }),

    Definition.new(model: CalendarEvent, module_key: "calendar", icon: "calendar",
      label: ->(r) { r.title },
      scope: ->(household, q) { CalendarEvent.for_household(household).where("title ILIKE :q OR location ILIKE :q", q: q).limit(RESULT_LIMIT_PER_MODEL) },
      url: ->(r) { edit_calendar_event_path(r) }),

    Definition.new(model: Contact, module_key: "birthdays", icon: "cake",
      label: ->(r) { r.name },
      scope: ->(household, q) { Contact.for_household(household).where("name ILIKE :q", q: q).limit(RESULT_LIMIT_PER_MODEL) },
      url: ->(r) { edit_contact_path(r) }),

    Definition.new(model: Document, module_key: "documents", icon: "file-text",
      label: ->(r) { r.name },
      scope: ->(household, q) { Document.for_household(household).where("name ILIKE :q", q: q).limit(RESULT_LIMIT_PER_MODEL) },
      url: ->(r) { document_path(r) }),

    Definition.new(model: Recipe, module_key: "recipes", icon: "book-open",
      label: ->(r) { r.title },
      scope: ->(household, q) {
        Recipe.for_household(household)
          .where("title ILIKE :q OR category ILIKE :q OR EXISTS (SELECT 1 FROM unnest(tags) AS tag WHERE tag ILIKE :q)", q: q)
          .limit(RESULT_LIMIT_PER_MODEL)
      },
      url: ->(r) { recipe_path(r) }),

    Definition.new(model: Vehicle, module_key: "vehicles", icon: "car",
      label: ->(r) { r.name },
      scope: ->(household, q) { Vehicle.for_household(household).where("name ILIKE :q OR manufacturer ILIKE :q OR plate ILIKE :q", q: q).limit(RESULT_LIMIT_PER_MODEL) },
      url: ->(r) { vehicle_path(r) }),

    Definition.new(model: Pet, module_key: "pets", icon: "paw-print",
      label: ->(r) { r.name },
      scope: ->(household, q) { Pet.for_household(household).where("name ILIKE :q OR breed ILIKE :q OR species ILIKE :q OR identifier ILIKE :q", q: q).limit(RESULT_LIMIT_PER_MODEL) },
      url: ->(r) { pet_path(r) }),

    Definition.new(model: Address, module_key: "addresses", icon: "map-pin",
      label: ->(r) { r.name },
      scope: ->(household, q) { Address.for_household(household).where("name ILIKE :q OR full_address ILIKE :q OR address_type ILIKE :q", q: q).limit(RESULT_LIMIT_PER_MODEL) },
      url: ->(r) { edit_address_path(r) }),

    Definition.new(model: ServiceProvider, module_key: "service_providers", icon: "wrench",
      label: ->(r) { r.name },
      scope: ->(household, q) { ServiceProvider.for_household(household).where("name ILIKE :q OR address ILIKE :q OR email ILIKE :q OR phone ILIKE :q", q: q).limit(RESULT_LIMIT_PER_MODEL) },
      url: ->(r) { edit_service_provider_path(r) }),

    Definition.new(model: LoyaltyCard, module_key: "loyalty", icon: "credit-card",
      label: ->(r) { r.name },
      scope: ->(household, q) { LoyaltyCard.for_household(household).where("name ILIKE :q OR number ILIKE :q", q: q).limit(RESULT_LIMIT_PER_MODEL) },
      url: ->(r) { loyalty_card_path(r) }),

    Definition.new(model: GiftList, module_key: "gifts", icon: "gift",
      label: ->(r) { r.name },
      scope: ->(household, q) { GiftList.for_household(household).where("name ILIKE :q", q: q).limit(RESULT_LIMIT_PER_MODEL) },
      url: ->(r) { gift_list_path(r) }),

    Definition.new(model: Trip, module_key: "trips", icon: "luggage",
      label: ->(r) { r.name },
      scope: ->(household, q) { Trip.for_household(household).where("name ILIKE :q", q: q).limit(RESULT_LIMIT_PER_MODEL) },
      url: ->(r) { trip_path(r) }),

    Definition.new(model: Routine, module_key: "routines", icon: "repeat",
      label: ->(r) { r.name },
      scope: ->(household, q) { Routine.for_household(household).where("name ILIKE :q OR description ILIKE :q OR list_name ILIKE :q", q: q).limit(RESULT_LIMIT_PER_MODEL) },
      url: ->(r) { edit_routine_path(r) }),

    # Architectural deviation (see Circle model comment): a Circle is NOT
    # household-scoped, so it's searched via the current user's own
    # memberships rather than `for_household`.
    Definition.new(model: Circle, module_key: "circles", icon: "users", scoped_by: :user,
      label: ->(r) { r.name },
      scope: ->(user, q) { user.circles.where("circles.name ILIKE :q OR circles.theme ILIKE :q", q: q).limit(RESULT_LIMIT_PER_MODEL) },
      url: ->(r) { circle_path(r) }),

    Definition.new(model: Conversation, module_key: "messages", icon: "message-circle",
      label: ->(r) { r.name },
      scope: ->(household, q) { Conversation.for_household(household).where("name ILIKE :q", q: q).limit(RESULT_LIMIT_PER_MODEL) },
      url: ->(r) { conversation_path(r) }),

    Definition.new(model: ShoppingList, module_key: "shopping", icon: "shopping-cart",
      label: ->(r) { r.name },
      scope: ->(household, q) { ShoppingList.for_household(household).where("name ILIKE :q", q: q).limit(RESULT_LIMIT_PER_MODEL) },
      url: ->(r) { shopping_list_path(r) }),

    Definition.new(model: SharedProject, module_key: "budget", icon: "euro",
      label: ->(r) { r.name },
      scope: ->(household, q) { SharedProject.for_household(household).where("name ILIKE :q", q: q).limit(RESULT_LIMIT_PER_MODEL) },
      url: ->(r) { shared_project_path(r) })
  ].freeze

  def self.call(query:, household:, user:)
    new(query: query, household: household, user: user).call
  end

  def initialize(query:, household:, user:)
    @query = query.to_s.strip
    @household = household
    @user = user
  end

  def call
    return [] if @query.blank? || @household.nil?

    wildcard = "%#{ActiveRecord::Base.sanitize_sql_like(@query)}%"

    DEFINITIONS.filter_map do |definition|
      next unless @household.module_enabled?(definition.module_key)

      subject = definition.scoped_by == :user ? @user : @household
      records = definition.scope.call(subject, wildcard)
      next if records.empty?

      {
        module_key: definition.module_key,
        icon: definition.icon,
        # instance_exec (not .call) so the url lambda's `self` is this
        # instance — that's what carries the included url_helpers methods
        # (edit_task_path, recipe_path, ...); the lambdas are defined in the
        # class body, so their captured `self` is otherwise the class itself.
        records: records.map { |r| { label: definition.label.call(r), url: instance_exec(r, &definition.url) } }
      }
    end
  end
end
