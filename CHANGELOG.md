# Changelog

All notable changes to Hestia are documented in this file.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
The project hasn't reached a stable v1.0.0 yet: the `1.0.0-betaN` versions
correspond to the successive scaffolding milestones of the functional scope,
now described by [`app/models/roadmap.rb`](app/models/roadmap.rb) and rendered
at `/roadmap`. Entries below 2026-07-06 cite a Specification and an
Implementation Plan: both were deleted once their content had been absorbed
into the roadmap, and the links are left as they were written rather than
rewritten after the fact.

## [Unreleased] — 2026-08-07

Execution of `TODO.md`, waves 0 to 4. The backlog was itself the product of
checking two ~800-line audit documents line by line against the code: roughly
60% of their factual claims described work already shipped, and `TODO.md` §2
records the refuted ones so they are not re-implemented. What follows is what
survived that check.

### Security

- **A Content-Security-Policy that is actually sent.** The initializer was
  commented out in full, so the app shipped no CSP at all. Now enforcing in
  every environment, with a per-request nonce on `script-src` — generated
  with `SecureRandom` rather than Rails' suggested `session.id`, which emits
  an empty nonce to a first-time visitor and would block the anti-FOUC script
  on every cold visit. `style-src` keeps `unsafe-inline` and takes no nonce:
  17 views set dynamic inline `style` attributes, which a nonce cannot cover,
  and adding one makes browsers ignore `unsafe-inline` entirely.
- **Module gating on the JSON API.** A household could switch Shopping off,
  watch it disappear from the web UI, and still read and write every list
  through an API token. Both surfaces now share one mapping (the `api/v1/`
  prefix is stripped before lookup), and `ModuleGatingTest` walks the route
  set so that a controller in neither the map nor the explicit exemption list
  is a red build. That found five live holes on the web side too:
  `recipe_catalog`, `plant_care_tasks`, `workout_templates`,
  `workout_template_exercises` and `trips/meal_plan_entries`.
- **Rate limiting on the public gift list**, browse and write separately,
  with a 429 page in the site's own dress. It was the only unauthenticated
  route with no limit.
- **No more never-expiring API token**: three durations, 90 days by default.
  Tokens created before this keep working.
- `force_ssl` / `assume_ssl` restored behind `FORCE_SSL`, so a
  reverse-proxied deployment can enable HSTS without breaking plain-HTTP
  access on a home network.

### Performance

- **`Rails.cache` has call sites.** It had none in the whole app while
  `solid_cache` sat configured and unused. Open Food Facts and Nominatim
  lookups are cached, and the first one documents the conventions the rest
  follow. Failures are never cached: "unknown product" and "the network was
  down" both arrive as `nil`, and pinning the second for 30 days turns a blip
  into a lasting wrong answer.
- **The dashboard narrows in SQL.** Every widget keeps five rows and used to
  get there by loading the whole relation and filtering in Ruby. The
  predicates are date arithmetic, so no `includes` would have helped and
  Bullet would never have seen it — the cost simply grew with the age of the
  household. Each model now owns the scope stating its own threshold, sharing
  constants with the status method beside it.
- **Recurrence expansion is bounded by the window, not by the age of the
  series.** The old expansion walked a recurring event from its first
  occurrence and gave up at a 1,000-iteration guard: a weekly event more than
  about 19 years old silently stopped appearing. Occurrences are also now
  counted from the start rather than accumulated, so a monthly series
  beginning on the 31st no longer collapses onto the 28th at the first
  February and stays there.
- **Eager loading where it was missing**, enumerated with `BULLET_RAISE=1`
  rather than by reading eleven controllers. The widest fix: the notification
  partial, rendered by the sidebar popover on *every* page, asked "does this
  user belong to more than one household?" once per line.

### Design system

- `Ui::ItemComponent` put back on the 4px grid (it carried `py-2.5`, and 51
  views render it) without moving every list in the app: a `min-h-11` floor
  keeps the common row pixel-identical while the padding returns to the grid.
- A **named z-index scale** — `z-sticky` / `z-floating` / `z-overlay` /
  `z-toast` — replacing twelve hand-picked numbers, with a test that refuses
  any raw one. Tailwind v4 gives z-index no `@theme` namespace, so it is
  spelled as utilities.
- **Loading skeletons** in the four lazy turbo-frames.
  `Ui::SkeletonComponent` existed, was tested, and was used by nothing but
  its own preview.
- `icon:` / `icon_position:` on `Ui::ButtonComponent`, with the glyph sized
  from the button rather than from the call site.
- The design-system documentation is usable on mobile: it rendered its 256px
  sidebar at every width, so at 390px the page was 470px wide and scrolled
  sideways — on the pages that document the type scale, while using
  `text-[10px]` instead of it.

### Added — the app is installable

- The PWA manifest and service worker had been on disk since the app was
  generated, with their routes and the layout's `<link rel="manifest">`
  commented out. Beyond uncommenting them: the manifest was still the
  scaffold's, with `"theme_color": "red"` and a 480×360 file declared as
  512×512; `public/icon.svg` was Rails' red circle, which is what the favicon
  in every browser tab actually was. Square 192/512 and maskable icons are
  generated from the logo, and the worker is served by the app's own
  controller because `Rails::PwaController` cannot set
  `Service-Worker-Allowed` — without which a worker at `/service-worker` may
  control `/service-worker/*` and nothing else. It caches exactly one thing:
  an offline page.

### Internationalization

- **51 display `strftime` calls migrated to `l()`.** They hard-coded
  `"%d/%m/%Y"`, so an English-speaking user was shown `07/08/2026` for
  7 August and read it as 8 July — a wrong date, not an untranslated one.
  `date:` / `time:` `formats:` blocks now exist in both locales; there were
  none, and the eleven existing `l()` calls were running on `rails-i18n`'s
  defaults.
- **Two guards**, because a migration without one comes undone one pull
  request at a time: `bin/rails i18n:check` (also a CI job) fails on a
  missing translation and on any key present in one locale but not the other,
  and a test refuses any new display `strftime`.

### Fixed

- `TasksController#swap_with_sibling` selected siblings with no `ORDER BY`,
  so move up/down swapped against Postgres heap order rather than the order
  the column is displayed in — sometimes the wrong task, sometimes nothing.
- `bin/rails visual:check` injected its measurement script with
  `page.addScriptTag()`, which the new CSP correctly refused.

### Documentation

- `amelioration.md` and `design-system.md` deleted. They were harmful rather
  than merely stale: their false claims named files and proposed diffs, which
  is worse than no document at all. Their reusable product ideation was
  harvested into `TODO.md` §8.3 and the roadmap first, each line re-checked
  against the code.
- Test infrastructure worth naming: rate limits were silently inert in the
  test environment (the null cache store's `#increment` returns `nil`), so
  the three pre-existing auth limits had never actually been exercised
  either.

## [1.0.0-beta37] — 2026-08-02

The month this file went unwritten. Recorded here from the commit history
rather than left as a gap, since the entry above it is what made the gap
visible.

### Added

- **Design System v2, "Terre cuite"**: a full rebrand onto a clay/amber
  palette, carried by semantic tokens (`--brand` / `--accent` through an
  indirection) rather than by literal colours, and applied across all 75
  `Ui::` components and every view. `/design-system` became navigable
  component documentation with per-component previews, usage notes and
  source.
- **Global search**, a ⌘K command palette spanning every module, gating its
  results per module rather than per request.
- **Responsive sidebar**: collapsible to a rail on desktop, relocated into a
  drawer below `md`, with `Ui::SidebarItemComponent` and one nav rendered
  once for both mounts.
- **Breadcrumbs** replacing the "back to dashboard" links across every module
  view.
- **`bin/rails visual:check`**: a headless pass (Puppeteer, in-process Puma)
  over 273 routes × 2 themes × 2 viewports, measuring contrast, touch-target
  size, font size, spacing scale and horizontal overflow. It is what waves 2
  and 3 above were fixed against.
- The **Lucide icon set** replacing emoji throughout, vendored and rendered
  inline; `Ui::CopyButtonComponent`, `Ui::FileUploadComponent`, an
  illustrations page.
- **Recipe catalog and discovery** (95 hand-authored recipes), fridge-based
  recipe suggestions, aisle guessing for shopping items, and a Menu that
  flags a day missing a required meal.
- **Plant care management** (Outdoor): `PlantCareTask` mirroring the Routine
  shape, wired into the Calendar, the dashboard and notifications.
- **Household settings as tabs**, with admin-only module toggles, and the
  roadmap moved in as one of them.
- **Reliability tooling**: SimpleCov, Bullet, Sentry, `mission_control-jobs`,
  explicit time zones, real system tests, and 77 new test files.

### Changed

- **Internationalization of the project itself**: English as the default
  locale with a per-user French preference, all 25 modules migrated, and
  English documentation and code comments throughout. `rails-i18n` added for
  translated ActiveRecord defaults.
- `api/v1` extended from five modules to all 25.
- External calendar sync went from scaffold to real Google/Microsoft OAuth
  and CalDAV.

### Fixed

- An SSRF hole in the recipe URL import, alongside a batch of code-review
  findings.
- Assorted flaky system tests, a toast race on sign-in, and a `pg` segfault
  on arm64-darwin caused by forking parallel test workers.

## [1.0.0-beta36] — 2026-07-05

Nine cross-cutting efforts identified in the Implementation Plan §6 as
missing are shipped in this session:

### Added

- **Reminders and notifications**: `Notification`, `NotificationPreference`,
  `TaskReminder`, `EventReminder`, `Reminders::DeliverDue` and
  `Reminders::DailyDigest` jobs (Solid Queue, `config/recurring.yml`), an
  unread-notifications badge in the layout, a per-user preferences page.
  Covers Tasks, Calendar, Fridge (expiration) and lays the groundwork for
  the remaining modules.
- **Open Food Facts** (Shopping, Fridge): `OpenFoodFacts::LookupProduct`,
  pre-filling the item/product form on barcode scan via Stimulus
  (`barcode_lookup_controller.js`).
- **Nominatim geocoding** (Addresses): `Geocoding::SearchAddress`, place
  search with name/address/GPS-coordinate pre-fill in the form
  (`geocode_lookup_controller.js`), alongside the already-existing static
  OpenStreetMap link.
- **Public holiday reference data** (Calendar): `HolidayReference`
  (France/Belgium/Switzerland), a country configurable per household
  (`Household#holiday_country`), highlighted display on the calendar.
- **Loyalty brand catalog** (Loyalty): `LoyaltyBrand`, about ten brands
  seeded to start, a picker that pre-fills the name/code format in the card
  form; the out-of-catalog card is still available.
- **Plant care-sheet catalog** (Outdoor): `PlantReference`, six sheets
  seeded to start (basil, tomato, lavender, monstera, rose, orchid), an
  optional picker when adding a plant.
- **External calendar sync — scaffold** (Calendar):
  `ExternalCalendarConnection` (Google/Microsoft/CalDAV), a per-provider
  connection screen. The real OAuth/CalDAV flow is still to be implemented
  by the host (application credentials required) — see the warning on the
  connection screen.
- **API `api/v1`**: `ApiToken` (opaque token, HMAC-SHA256 fingerprint),
  `Api::V1::BaseController` (token auth, server-side household scoping,
  standardized pagination), REST/JSON endpoints for Shopping, Fridge,
  Recipes, Tasks, Calendar — the blocking prerequisite for mobile is
  lifted. Token management from `/api_tokens`.
- **Flutter mobile client skeleton** (`mobile/`): `ApiClient` (HTTP to
  `api/v1`, a Bearer token header), an API-token login screen, a read-only
  Shopping screen. Not functional as-is (no Flutter SDK available in this
  environment, no functional parity, no real-time) — a starting point for
  a dedicated effort.

### Documentation

- LICENSE (AGPLv3), a real README.md, CONTRIBUTING.md.
- Updated the Specification and the Implementation Plan to reflect the
  above.

## [1.0.0-beta35] — 2026-07-03

### Fixed

- Aligned dependencies (`Gemfile`/`Gemfile.lock`) and the GitHub Actions CI.

## [1.0.0-beta34] — 2026-07-03

### Fixed

- Display fixes on gift lists (Gifts) and the recipe page; added the
  `test/system` directory.

## [1.0.0-beta33] — 2026-07-02

### Added

- Drag-and-drop reordering (`Reordering`, `sortable_controller.js`) on
  shopping items, tasks, and loyalty cards.

## [1.0.0-beta32] — 2026-07-02

### Added

- PDF export of the shopping list and the displayed calendar month
  (`Pdf::ShoppingListDocument`, `Pdf::CalendarMonthDocument`, Prawn).

## [1.0.0-beta31] — 2026-07-02

### Added

- **Wellbeing module** (architecture deviation): `WellbeingProfile`,
  `WeightEntry`, `WorkoutEntry`, scoped per user (not per household).

## [1.0.0-beta30] — 2026-07-02

### Added

- **Trip module** (architecture deviation): `Trip`, a `trip_id`
  column on Addresses/Notes/Tasks/Shopping, a `Trips::` namespace for
  trip-dedicated sub-resources.

## [1.0.0-beta29] — 2026-07-02

### Added

- **Circles module** (architecture deviation): `Circle` independent
  of the household, `CircleMembership`, `CirclePost`, `CirclePostReaction`.

## [1.0.0-beta28] — 2026-07-02

### Added

- **Gifts module** (architecture deviation): `GiftList`, `GiftIdea`,
  `GiftListShare` (public token-based sharing), `GiftReservation`, an
  unauthenticated public `public_gift_lists` route.

## [1.0.0-beta27] — 2026-07-02

### Added

- **Documents module**: `Document`, `DocumentFolder`, file storage via
  Active Storage.

## [1.0.0-beta26] — 2026-07-02

### Added

- **Budget module**: `BudgetCategory`, `BudgetEntry`, `SavingsEnvelope`,
  `SharedProject`, `SharedExpense`, `Budget::Summary` and
  `Budget::SettleProject` services (split calculation).

## [1.0.0-beta25] — 2026-07-02

### Added

- **Outdoor module**: `Plant`, `Pool`, `PoolReading`, `PoolAction` (garden +
  pools).

## [1.0.0-beta24] — 2026-07-02

### Added

- **Routines module**: `Routine`, `RoutineCompletion`, a `Recurrence`
  engine shared with Calendar.

## [1.0.0-beta23] — 2026-07-02

### Added

- **Menu module**: `MealPlanEntry`, weekly meal planning linked to Recipes.

## [1.0.0-beta22] — 2026-07-02

### Added

- **Messages module**: `Conversation`, `ConversationParticipant`,
  `Message`.

## [1.0.0-beta21] — 2026-07-02

### Added

- **Baby module**: `BabyProfile`, `FeedingSession`, `FoodIntroduction`,
  `AllergenTest`.

## [1.0.0-beta20] — 2026-07-02

### Added

- **Waste module**: `WasteCollectionSeries`, `WasteCollectionEvent`, the
  `Waste::GenerateSeries` service.

## [1.0.0-beta19] — 2026-07-02

### Added

- **Wine Cellar module**: `WineCellar`, `Bottle`.

## [1.0.0-beta18] — 2026-07-02

### Added

- **Vehicles module**: `Vehicle`, `VehicleMaintenanceEntry`.

## [1.0.0-beta17] — 2026-07-02

### Added

- **Pets module**: `Pet`, `PetVaccination`, `PetTreatment`, `PetSupply`.

## [1.0.0-beta16] — 2026-07-02

### Added

- **Loyalty module**: `LoyaltyCard` (a free-form card, out of catalog).

## [1.0.0-beta15] — 2026-07-02

### Added

- **Service Providers module**: `ServiceProvider`, `ServiceProviderType`.

## [1.0.0-beta14] — 2026-07-02

### Added

- **Addresses module**: `Address` (fourteen types), an OpenStreetMap
  directions link.

## [1.0.0-beta13] — 2026-07-02

### Added

- **Birthdays module**: `Contact`, `ContactTag`, `ContactTagging`.

## [1.0.0-beta12] — 2026-07-02

### Added

- **Notes module**: `Note`, the `Notes::PromoteToTask` service.

## [1.0.0-beta11] — 2026-07-02

### Added

- **Calendar module**: `CalendarEvent`, `EventParticipant`, the
  `Calendar::CreateEvent` service.

## [1.0.0-beta10] — 2026-07-02

### Added

- **Tasks module**: `Task`, `TaskCategory`, the `Tasks::CreateTask` and
  `Tasks::ToggleTask` services.

## [1.0.0-beta9] — 2026-07-02

### Added

- **Recipes module**: `Recipe`, `RecipeIngredient`, `RecipeStep`, importing
  from a URL (schema.org/Recipe) via `Recipes::ImportFromUrl`.

## [1.0.0-beta8] — 2026-07-02

### Added

- **Fridge module**: `FridgeItem`, `PreparedDish`, the `Perishable`
  concern, a two-way bridge with Shopping.

## [1.0.0-beta7] — 2026-06-30

### Added

- **Shopping module**: `ShoppingList`, `ShoppingListItem`, `Product`
  (household catalog), the `Courses::AddItem` and `Courses::ToggleItem`
  services.

## [1.0.0-beta6] — 2026-06-30

### Added

- **Application foundation**: `Household`, `Membership` (roles,
  invite codes), multi-household scoping (`HouseholdScoped`,
  `Current.household`), sign-up, onboarding, dashboard.
- First versions of the Specification and the Implementation Plan.

## [1.0.0-beta5] — 2026-06-26

### Fixed

- Adjustments to the DB schema and `.gitignore`.

## [1.0.0-beta4] — 2026-06-26

### Added

- The `Ui::*` UI component library (shadcn-style, ~50 ViewComponents) and
  its associated Stimulus controllers, exposed on `/design-system`.

## [1.0.0-beta3] — 2026-06-26

### Added

- The `/design-system` route (a component showcase page).

## [1.0.0-beta2] — 2026-06-25

### Added

- Rails 8-generated authentication: `User`, `Session`, login, forgot
  password (`PasswordsMailer`).

## [1.0.0-beta1] — 2026-06-25

### Added

- Initial Rails 8.1 app skeleton (PostgreSQL, Solid Queue/Cable/Cache,
  Hotwire, Tailwind v4, Docker/Kamal, GitHub Actions CI).
