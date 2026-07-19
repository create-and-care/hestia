class HouseholdsController < ApplicationController
  allow_without_household only: %i[new create]

  # Progress by phase (Spec §18) and list of planned improvements, derived from
  # the application analysis. Static data versioned with the code, similar to
  # the Spec and Implementation Plan that they summarize. Rendered in the
  # "Roadmap" tab of household settings (show).
  PHASES = [
    { name: "Phase 1 — Foundation", detail: "User, Session, Household, Membership, multi-household scoping", status: :done },
    { name: "2.a — Priority modules", detail: "Shopping, Calendar, Tasks, Fridge, Recipes", status: :done },
    { name: "2.b — Satellite modules", detail: "Notes, Birthdays, Addresses, Service Providers, Loyalty, Pets, Vehicles, Wine Cellar, Waste, Baby, Messages", status: :done },
    { name: "2.c — Richer business logic", detail: "Menu, Routines, Outdoor, Budget, Documents", status: :done },
    { name: "2.d — Architecture deviations", detail: "Gifts, Circles, Trip, Wellbeing", status: :done },
    { name: "Reminders & notifications", detail: "Tasks, Calendar, Fridge, and the Birthdays same-day notification are all wired to Reminders::DailyDigest / DeliverDue", status: :done },
    { name: "External integrations", detail: "Open Food Facts, Nominatim, public holidays, Loyalty/Outdoor catalogs, and a real Google/Microsoft OAuth + CalDAV calendar sync", status: :done },
    { name: "API api/v1", detail: "All 25 modules exposed", status: :done },
    { name: "Mobile application", detail: "Flutter skeleton — login + read-only Shopping", status: :partial },
    { name: "Governance & documentation", detail: "LICENSE, README, CONTRIBUTING, CHANGELOG, Roadmap page", status: :done },
    { name: "Marketing site & user docs", detail: "Not started", status: :todo },
    { name: "Hest.AI (Phase 3)", detail: "Not started — needs the work above consolidated first", status: :todo }
  ].freeze

  IMPROVEMENTS = [
    {
      category: "Dashboard & cross-cutting experience",
      emoji: "🧭",
      items: [
        "Wire up a global search/navigation component (Ui::CommandComponent, already in the library but used nowhere outside /design-system) instead of navigating via the dashboard's 25-link grid.",
        "Finish adopting the Ui:: component library in business views: 730 occurrences of hardcoded gray classes (gray-100, bg-gray-50…) versus only 16 uses of semantic tokens (bg-container, text-primary…) outside the library itself. Dark mode exists at the token level (the .dark class) but isn't functionally exercised by nearly any module view.",
        "Add a household activity feed (who did what, when) — useful for trust in multi-member use and reusable as a logging building block for Hest.AI (Spec §13).",
        "Allow exporting household data (JSON/CSV): no personal-data portability feature exists at this stage."
      ]
    },
    {
      category: "Security & account management",
      emoji: "🔐",
      items: [
        "Add user account deletion and a personal-data export, for portability even when self-hosted (see the privacy-policy recommendation, Spec §8).",
        "Add rate limiting to the public, unauthenticated gift-reservation route (g/:token/reserve/:idea_id), which has none unlike login, forgot-password, and (now) registration."
      ]
    },
    {
      category: "Reliability, quality & observability",
      emoji: "🧪",
      items: [
        "Extend system test (Capybara) coverage beyond sign-in/out and the two read-only checks written so far (Shopping, Tasks): multi-step Turbo-navigation flows proved flaky in this environment for reasons not fully root-caused (suspected Puma/ActionCable interaction under Capybara's test server) — worth a dedicated investigation before writing more of them.",
        "Add https://github.com/SigNoz/signoz to bring metrics and logs to the project."
      ]
    },
    {
      category: "Functional modules — identified gaps",
      emoji: "🧩",
      items: [
        "Expand the plant reference catalog beyond the 6 starter sheets (PlantReference).",
        "Expand the loyalty brand catalog beyond the starter dozen (LoyaltyBrand).",
        "Import contacts from the phone's address book (Birthdays, Service Providers) once mobile is far enough along.",
        "Add smart ingredient merging (duplicates, unit conversion) when adding a recipe to shopping — currently a raw add with no merging (a target Hest.AI capability).",
        "Look into the cross-household recipe community floated as out-of-scope for V1 (Spec §19), once a critical mass of active households is reached."
      ]
    },
    {
      category: "API & Mobile",
      emoji: "📡",
      items: [
        "Open a real-time channel for external clients (WebSocket to Solid Cable): mobile currently only does one-off HTTP, no live updates.",
        "Build the mobile client's functional parity across the 24 remaining modules: only a read-only Shopping screen exists.",
        "Add native camera access on mobile (Shopping/Fridge barcode scanning, document capture).",
        "Add native voice dictation on mobile (Notes, Tasks).",
        "Add native push notifications on mobile, building on the Notification/NotificationPreference infrastructure already in place on the web.",
        "Add a read-only offline mode on mobile for already-synced data.",
        "Add transparent API token renewal on mobile: currently a static token, with no expiration or refresh flow."
      ]
    },
    {
      category: "Internationalization & accessibility",
      emoji: "🌍",
      items: [
        "Structure interface text with I18n — **done this session**: English is now the default UI language, with French available as a per-user preference (config/locales/{en,fr}/*.yml, one pair of files per module).",
        "Enable the PWA: the manifest and service worker exist under app/views/pwa/ but stay commented out in config/routes.rb and the layout, even though they'd let the web app be installed on mobile/desktop while waiting for full Flutter client parity.",
        "Audit keyboard and screen-reader accessibility for the custom Stimulus components (combobox, dialog, dropdown, command…): no automated accessibility test exists at this stage."
      ]
    },
    {
      category: "Site, documentation & governance",
      emoji: "📚",
      items: [
        "Build a public marketing site (a home page, one page per module, a Hest.AI presentation page, emphasizing the free/open-source nature of the project): not started, distinct from this household-settings Roadmap tab.",
        "Build a per-module user documentation hub (usage guides), beyond the governance files already in place.",
        "Write a privacy policy suited to the self-hosted context, recommended as soon as a household hosts third-party data (public Gift links, Circles).",
        "Translate the Specification and Implementation Plan to other languages, now that the project's code and docs are English-first — **the English translation itself is done this session**."
      ]
    },
    {
      category: "Hest.AI (Phase 3)",
      emoji: "🤖",
      items: [
        "Start Hest.AI only once the remaining reliability gaps above are closed: otherwise the assistant would inherit the same gaps (Spec §13, Plan §7).",
        "Generalize the per-domain service-object layer to the modules that don't have one yet, a condition set out in Spec section 5 so Hest.AI can invoke them as tools."
      ]
    }
  ].freeze

  def new
    @household = Household.new
  end

  def create
    @household = Household.new(household_params)

    if @household.valid?
      ActiveRecord::Base.transaction do
        @household.save!
        @household.memberships.create!(user: Current.user, role: :admin)
        @household.shopping_lists.create!(name: t("shopping_lists.default_list_name"))
      end
      switch_household(@household)
      redirect_to root_path, notice: t(".created", name: @household.name)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @household = Current.household
    @memberships = @household.memberships.includes(:user).order(:role)
    @other_households = Current.user.households.where.not(id: @household.id)
    @notification_preference = NotificationPreference.for_user(Current.user)
    @api_tokens = Current.user.api_tokens.order(created_at: :desc)
    @api_token = ApiToken.new
    @sessions = Current.user.sessions.order(created_at: :desc)
    @phases = PHASES
    @improvements = IMPROVEMENTS
  end

  # Used in particular to enable/change the public holiday reference (Spec §9.2)
  # and the household's time zone (Spec §9.2, §9.3 — day-boundary calculations).
  def update
    if Current.household.update(household_update_params)
      redirect_back fallback_location: household_path(Current.household), notice: t(".updated")
    else
      redirect_back fallback_location: household_path(Current.household), alert: t(".failed")
    end
  end

  # Enables/disables sidebar modules for the household (admins only, Household#module_enabled?).
  def update_modules
    unless current_membership&.admin?
      return redirect_to household_path(Current.household), alert: t(".not_authorized")
    end

    enabled_modules = Array(params.dig(:household, :enabled_modules))
    disabled_modules = Household::MODULE_KEYS - enabled_modules

    if Current.household.update(disabled_modules: disabled_modules)
      redirect_to household_path(Current.household), notice: t("households.update.updated")
    else
      redirect_to household_path(Current.household), alert: t("households.update.failed")
    end
  end

  # Switches the active household (multi-household).
  def activate
    membership = Current.user.memberships.find_by(household_id: params[:id])

    if membership
      switch_household(membership.household)
      redirect_to root_path, notice: t(".switched", name: membership.household.name)
    else
      redirect_to root_path, alert: t(".not_found")
    end
  end

  def regenerate_invite_code
    unless current_membership&.admin?
      return redirect_to household_path(Current.household), alert: t(".not_authorized")
    end

    Current.household.regenerate_invite_code!
    redirect_to household_path(Current.household), notice: t(".regenerated")
  end

  # A household created by mistake shouldn't stay permanent (admin only).
  # Every session with this household set as active — this user's and every
  # other member's — must be cleared first: `sessions.active_household_id`
  # has no ON DELETE clause, so destroying the household would otherwise hit
  # a foreign key violation for anyone still "on" it.
  def destroy
    household = Current.household
    unless current_membership&.admin?
      return redirect_to household_path(household), alert: t(".not_authorized")
    end

    Session.where(active_household: household).update_all(active_household_id: nil)
    household.destroy!

    next_household = Current.user.households.reload.first
    if next_household
      switch_household(next_household)
      redirect_to root_path, notice: t(".deleted")
    else
      Current.household = nil
      redirect_to onboarding_path, notice: t(".deleted")
    end
  end

  private
    def household_params
      params.require(:household).permit(:name)
    end

    def household_update_params
      params.require(:household).permit(:holiday_country, :time_zone, required_meal_types: [])
    end
end
