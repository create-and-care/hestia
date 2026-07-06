# Changelog

All notable changes to Hestia are documented in this file.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
The project hasn't reached a stable v1.0.0 yet: the `1.0.0-betaN` versions
correspond to the successive scaffolding milestones of the functional scope
described in the [Specification](<Specification — Hestia.md>).

## [Unreleased] — 2026-07-05

Nine cross-cutting efforts identified in the
[Implementation Plan](<Implementation Plan — Hestia.md>) §6 as missing are
shipped in this session:

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

- **Wellbeing module** (architecture deviation §5.4): `WellbeingProfile`,
  `WeightEntry`, `WorkoutEntry`, scoped per user (not per household).

## [1.0.0-beta30] — 2026-07-02

### Added

- **Trip module** (architecture deviation §5.3): `Trip`, a `trip_id`
  column on Addresses/Notes/Tasks/Shopping, a `Trips::` namespace for
  trip-dedicated sub-resources.

## [1.0.0-beta29] — 2026-07-02

### Added

- **Circles module** (architecture deviation §5.1): `Circle` independent
  of the household, `CircleMembership`, `CirclePost`, `CirclePostReaction`.

## [1.0.0-beta28] — 2026-07-02

### Added

- **Gifts module** (architecture deviation §5.2): `GiftList`, `GiftIdea`,
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

- **Phase 1 — Application foundation**: `Household`, `Membership` (roles,
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
