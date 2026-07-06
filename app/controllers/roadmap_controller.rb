class RoadmapController < ApplicationController
  allow_without_household

  # Progress by phase (Spec §18) and list of planned improvements, derived from
  # the application analysis. Static data versioned with the code, similar to
  # the Spec and Implementation Plan that they summarize.
  PHASES = [
    { name: "Phase 1 — Foundation", detail: "User, Session, Household, Membership, multi-household scoping", status: :done },
    { name: "2.a — Priority modules", detail: "Shopping, Calendar, Tasks, Fridge, Recipes", status: :done },
    { name: "2.b — Satellite modules", detail: "Notes, Birthdays, Addresses, Service Providers, Loyalty, Pets, Vehicles, Wine Cellar, Waste, Baby, Messages", status: :done },
    { name: "2.c — Richer business logic", detail: "Menu, Routines, Outdoor, Budget, Documents", status: :done },
    { name: "2.d — Architecture deviations", detail: "Gifts, Circles, Trip, Wellbeing", status: :done },
    { name: "Reminders & notifications", detail: "Tasks, Calendar, Fridge — the Birthdays same-day notification remains", status: :partial },
    { name: "External integrations", detail: "Open Food Facts, Nominatim, public holidays, Loyalty/Outdoor catalogs done — calendar sync as a scaffold", status: :partial },
    { name: "API api/v1", detail: "5 modules exposed (wave 2.a) out of 25", status: :partial },
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
        "Enrich the dashboard with the widgets planned in Spec §7 (Fridge items close to expiring, upcoming birthdays, overdue tasks, upcoming events): it currently only shows the household, its members, and the invite code.",
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
        "Let a member leave a household and an admin remove another member: MembershipsController and HouseholdsController expose no destroy action today.",
        "Allow deleting a household (no destroy route on households): a household created by mistake stays permanent today.",
        "Add user account deletion and a personal-data export, for portability even when self-hosted (see the privacy-policy recommendation, Spec §8).",
        "Add expiration/rotation for API tokens: ApiToken has no expires_at, a token stays valid indefinitely until manually deleted from /api_tokens.",
        "Strengthen the password policy: User relies solely on has_secure_password, with no minimum length or complexity rule.",
        "Add rate limiting to the public, unauthenticated gift-reservation route (g/:token/reserve/:idea_id), which has none unlike login and forgot-password.",
        "Write the dedicated authorization tests for the Wellbeing module recommended as a priority by Spec §5.4: neither WellbeingController, WeightEntriesController, WorkoutEntriesController, nor their models have a test today — yet it's the module whose isolation is most sensitive.",
        "Extend test coverage to the least-covered architecture-deviation modules: Circles (circle_memberships_controller, circle_posts_controller, circle_post_reactions_controller) and Gifts (gift_ideas_controller, gift_list_shares_controller) deviate from standard household scoping with no dedicated controller test."
      ]
    },
    {
      category: "Reliability, quality & observability",
      emoji: "🧪",
      items: [
        "Write real system tests (Capybara): test/system only contains a .keep file, even though the CI system-test job exists and so passes trivially without checking anything.",
        "Close the overall coverage gap: 42 out of 93 controllers and 48 out of 80 models have no dedicated test file.",
        "Add a coverage measurement tool (SimpleCov) to CI to keep these gaps continuously visible rather than discovering them via one-off audits.",
        "Add an N+1 query detection tool (Bullet): the risk grows with 25 modules and their nested associations.",
        "Add a production error-tracking tool (Sentry/Honeybadger/self-hostable GlitchTip): a silently failing Solid Queue job (e.g. Reminders::DeliverDue) wouldn't surface anywhere today.",
        "Add a Solid Queue admin interface (mission_control-jobs) to inspect failed or pending jobs, especially now that reminders/notifications are critical.",
        "Explicitly configure the application's time zone (config.time_zone is commented out, defaulting to UTC): several \"today\" calculations (Fridge expiration, Task due dates, the daily digest) are sensitive to the household's actual time zone.",
        "Add https://github.com/SigNoz/signoz to bring metrics and logs to the project."
      ]
    },
    {
      category: "Functional modules — identified gaps",
      emoji: "🧩",
      items: [
        "Wire the Birthdays same-day notification onto the reminders infrastructure now in place (Spec §10.2).",
        "Implement the real OAuth/CalDAV flow for external calendar sync: the ExternalCalendarConnection scaffold exists, not the actual connection.",
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
        "Extend the api/v1 API to the 20 remaining modules: only Shopping, Fridge, Recipes, Tasks, Calendar are exposed today.",
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
        "Build a public marketing site (a home page, one page per module, a Hest.AI presentation page, emphasizing the free/open-source nature of the project): not started, distinct from this in-app Roadmap page.",
        "Build a per-module user documentation hub (usage guides), beyond the governance files already in place.",
        "Write a privacy policy suited to the self-hosted context, recommended as soon as a household hosts third-party data (public Gift links, Circles).",
        "Translate the Specification and Implementation Plan to other languages, now that the project's code and docs are English-first — **the English translation itself is done this session**."
      ]
    },
    {
      category: "Hest.AI (Phase 3)",
      emoji: "🤖",
      items: [
        "Start Hest.AI only once the work above is consolidated (Birthdays notification, real OAuth/CalDAV flow, API extension, Wellbeing tests): otherwise the assistant would inherit the same gaps (Spec §13, Plan §7).",
        "Generalize the per-domain service-object layer to the modules that don't have one yet, a condition set out in Spec section 5 so Hest.AI can invoke them as tools."
      ]
    }
  ].freeze

  def show
    @phases = PHASES
    @improvements = IMPROVEMENTS
  end
end
