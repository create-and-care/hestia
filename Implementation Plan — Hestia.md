# Implementation Plan — Hestia

**Version:** 1.2 — derived from *Specification — Hestia.md* (the Spec) **Status:** living document, updated after each shipped wave

This document turns the Spec into an ordered implementation backlog, based on **the code's actual state**. Major update on July 5, 2026: beyond the foundation (Phase 1) and the 25 modules (Phase 2, waves 2.a to 2.d) already scaffolded, this session ships most of the cross-cutting work that was still open (section 0, v1.1): reminders/notifications, external integrations (Open Food Facts, Nominatim), reference content (Loyalty, Outdoor, public holidays), an external calendar sync scaffold, the `api/v1` API (wave 2.a), a Flutter mobile skeleton, and governance (`LICENSE`/`README`/`CONTRIBUTING`/`CHANGELOG`). The precise per-version detail lives in `CHANGELOG.md`. The remaining backlog (section 0 below) is now about extending this work (the API to the other 20 modules, mobile parity, a real OAuth/CalDAV flow) and Hest.AI.

---

## 0. Repository status (as of July 5, 2026)

**Already in place:**

- **Technical foundation** matching Spec §4: Rails 8.1, PostgreSQL, `solid_queue` / `solid_cable` / `solid_cache`, `turbo-rails` + `stimulus-rails`, `view_component`, Tailwind v4 (+ esbuild), Docker / Kamal, CI (`.github/workflows/ci.yml`: tests + RuboCop omakase + Brakeman + bundler-audit).
- **Authentication (Rails 8 generator)**: `User` (`email_address`, `password_digest`) and `Session` models, `Current` (`session` + delegated `user` + `household`), the `Authentication` concern (signed session cookie, `require_authentication`, `start_new_session_for`, etc.), `SessionsController` (login), `PasswordsController` + `PasswordsMailer` (forgot password), fixtures and associated tests.
- **Phase 1 — Application foundation, complete**: `Household` (name, generated unique `invite_code`), `Membership` (`member`/`admin` role, `[user_id, household_id]` uniqueness), the `HouseholdScoped` model concern, the `HouseholdScoping` controller concern, `RegistrationsController`, `OnboardingController`, `HouseholdsController` (create/show/activate), `MembershipsController` (join via code), `DashboardController#show` as `root`. See section 2 for detail (kept below as a record of what was built).
- **All 25 Phase 2 modules (waves 2.a to 2.d)**: each has its DB schema, model(s) scoped via `HouseholdScoped` (or `user_id` for Wellbeing, or independent of the household for Circles — the section 5 deviations honored), a controller, views built on `Ui::*` components, and most of the real-time layer (`broadcasts_to` / `broadcasts_refreshes_to` / explicit Turbo Stream broadcasts). Detail per wave in sections 4 and 5.
- **Per-domain business services** (`app/services/`): `Courses::AddItem`, `Courses::ToggleItem`, `Frigo::AddItem`, `Frigo::AddFromShoppingListItem`, `Frigo::MoveToShoppingList`, `Tasks::CreateTask`, `Tasks::ToggleTask`, `Recipes::ImportFromUrl`, `Recipes::RecipeParser`, `Recipes::AddIngredientsToShoppingList`, `Calendar::CreateEvent`, `Budget::Summary`, `Budget::SettleProject`, `Waste::GenerateSeries`, `Notes::PromoteToTask`, `Recurrence` (shared between Calendar/Routines, matching the sharing planned in §11.2), `Reordering`, `Pdf::ShoppingListDocument`, `Pdf::CalendarMonthDocument`, `Reminders::DeliverDue`, `Reminders::DailyDigest`, `OpenFoodFacts::LookupProduct`, `Geocoding::SearchAddress`, `HolidayReference`. Covers some modules; the others carry their logic directly in models/controllers — to be generalized if Hest.AI (Phase 3) needs it.
- **Reminders and notifications** (a cross-cutting effort, formerly missing): `Notification`, `NotificationPreference`, `TaskReminder`, `EventReminder`, Solid Queue jobs `Reminders::DeliverDue` (Tasks/Calendar due dates) and `Reminders::DailyDigest` (daily recap, scheduled via `config/recurring.yml`), an unread-notifications badge (`shared/_notifications`), a `/notification_preferences` page. Covers Tasks, Calendar, Fridge (expiration); the Birthdays same-day notification still needs to be wired onto this same infrastructure (see section 6).
- **External integrations** (formerly missing): `OpenFoodFacts::LookupProduct` (Shopping/Fridge barcode scanning, `barcode_lookup_controller.js`), `Geocoding::SearchAddress` (Nominatim search, Addresses, `geocode_lookup_controller.js`).
- **Reference content** (formerly missing): `LoyaltyBrand` (Loyalty catalog, seeded), `PlantReference` (Outdoor care sheets, seeded), `HolidayReference` (FR/BE/CH public holidays, `Household#holiday_country`).
- **External calendar sync — scaffold**: `ExternalCalendarConnection` (provider, tokens, CalDAV), `ExternalCalendarConnectionsController` (index/connect/callback/destroy). The real OAuth/CalDAV flow isn't implemented (it requires application credentials on the host's side) — see the explicit warning on the connection screen rather than a fake success.
- **API `api/v1`** (formerly a blocking gap): `ApiToken` (opaque token, HMAC-SHA256 fingerprint), `Api::V1::BaseController` (token auth, server-side household scoping, pagination), REST/JSON endpoints for Shopping, Fridge, Recipes, Tasks, Calendar (wave 2.a only — 20 modules remaining).
- **Flutter mobile skeleton** (`mobile/`, formerly missing): `ApiClient`, a token-based login screen, a read-only Shopping screen. Not functional, not tested, no parity — a starting point documented in `mobile/README.md`.
- **Governance** (formerly missing): `LICENSE` (AGPLv3), a real `README.md`, `CONTRIBUTING.md`, `CHANGELOG.md`.
- **Tests**: 83+ files (`test/models`, `test/controllers`, `test/services`) covering the models, controllers, and services listed above, including the cross-cutting work shipped this session.
- **UI component library** (shadcn-style, ~50 ViewComponents: `Ui::ButtonComponent`, `DialogComponent`, `CalendarComponent`, `ChartComponent`, `ComboboxComponent`…) exposed on the `/design-system` route. **Not mentioned in Spec v1.0** — has sped up every view shipped since.

**Missing relative to the Spec (current backlog — detail in sections 6 and 8):**

- **External calendar sync — real flow**: the scaffold (`ExternalCalendarConnection`, connection screen) exists, but no OAuth Google/MSAL or CalDAV flow is actually wired up — it requires application credentials supplied by the host.
- **Birthdays same-day notification**: the notification infrastructure exists (Tasks/Calendar/Fridge); the daily trigger specific to birthdays is missing.
- **API `api/v1` — 20 remaining modules**: only wave 2.a is exposed via the API (Shopping, Fridge, Recipes, Tasks, Calendar).
- **Flutter mobile — functional parity**: only a skeleton (login + read-only Shopping) exists; 24 modules, camera, dictation, push, offline, real-time are still to build.
- **Hest.AI (Phase 3)**: not started.
- **Marketing site / user documentation**: beyond governance (`LICENSE`/`README`/`CONTRIBUTING`/`CHANGELOG`) and the Roadmap page (section 9), there's no public marketing site nor a per-module user documentation hub.

---

## 1. Spec ↔ code reconciliation decisions

Spec §17.1 is an "illustrative" diagram. Where it diverges from the actual code, here's the call we made (and the Spec was updated accordingly):

| Point | Spec v1.0 | Decision | Reason |
|---|---|---|---|
| Email identifier | `User.email` | **`email_address`** | Already the Rails 8 generator's convention; renaming would touch the whole auth layer for zero gain. |
| Primary key type | `uuid` | **`bigint`** (Rails default) | `users`/`sessions` are already `bigint`; mixing uuid/bigint complicates FKs. To revisit only if a security need (non-enumerable ids) emerges. |
| Member name | `User.name` | **added `User.name`** | Needed to display members (avatars, Task/Calendar assignments). |
| Roles | "flat permissions" (§6) + `role` in the schema | **`Membership.role`** (`member` / `admin`), the creator is `admin` | Lets invitations / deleting the household eventually be reserved to an admin (§6 anticipates this need) without blocking anything else. |
| Active household | implicit | **`Session.active_household_id`** + `Current.household` | Multi-household, multi-device: each session remembers its active household. |

---

## 2. Phase 1 — Foundation (blocking prerequisite) — ✅ DONE

> Goal: lay down `Household` / `Membership` / invitations / multi-household scoping + the sign-up→onboarding→dashboard flow. Nothing in Phase 2 starts before this foundation is validated.
>
> **Status: shipped.** The list below is kept as a record of what was built (see section 0); it's no longer an open backlog.

### 2.1 Data & models

- `add_name_to_users` migration (`name:string`).
- `create_households` migration: `name`, `invite_code` (unique index), timestamps.
- `create_memberships` migration: `user`, `household`, `role` (default `member`), unique index `[user_id, household_id]`.
- `add_active_household_to_sessions` migration: `active_household` (nullable FK).
- `Household`: `has_many :memberships`/`:users`, `invite_code` generation + uniqueness (`before_create`, readable base32, 8 chars), `validates :name`.
- `Membership`: `belongs_to :user`/`:household`, `validates :user_id, uniqueness: { scope: :household_id }`, `role` enum.
- `User`: `has_many :memberships`/`:households`, `validates :name`.
- `Session`: `belongs_to :active_household, optional: true`.
- `Current`: `attribute :household`.

### 2.2 Multi-household scoping

- A `before_action` in `ApplicationController`: `set_current_household` (resolves `Current.household = session.active_household || user.households.first`) then `require_household` (redirects to onboarding if the user has no household).
- The `HouseholdScoped` model concern (reusable across Phase 2): `belongs_to :household` + a documented default scope + a scoped-creation helper. **Filtering always goes through `Current.household`, never a client parameter** (Spec §15).

### 2.3 Flows & screens

- `RegistrationsController` (sign-up: `name` + `email_address` + password → opens a session → onboarding).
- `OnboardingController`: choosing "create a household" / "join via code".
- `HouseholdsController`: `new`/`create` (the creator becomes `admin`), `show`, `activate` (switching the active household).
- `MembershipsController`: `new`/`create` (join via `invite_code`).
- `DashboardController#show` → **`root`**: a minimal dashboard (household name, members, invite code to share, a household switcher if there are several). It will grow wave after wave (Spec §7).
- Rewiring the auth views + new views onto `Ui::*` components (visual consistency with `/design-system`).

### 2.4 Tests (Minitest)

- Models: invite-code generation/uniqueness, membership uniqueness, the creator's role.
- Flows: sign-up, creating a household, joining via code (valid / invalid), redirecting to onboarding when household-less, switching the active household, isolation between two households.
- Fixtures: `households`, `memberships`, an update to `users` (adding `name`).

**Phase 1 definition of done:** a green suite (`bin/rails test`), RuboCop + Brakeman clean, a user can sign up → create/join a household → see their dashboard, and two households don't see each other's data.

---

## 3. Reusable module pattern — ✅ VALIDATED

Every Phase 2 module follows, with rare exceptions, the same template, actually observed in the shipped code:

1. **Model(s)** scoped to the household via `HouseholdScoped` (or `user_id`/independent of the household for the 4 architecture deviations — see section 5).
2. **Per-domain service objects** (e.g. `Courses::AddItem`) — required by Spec §5 pt 5 so Hest.AI (Phase 3) can invoke them as "tools"; business logic doesn't live in the controller. **Status: present for some modules only** (list in section 0) — to be generalized to the others before starting Hest.AI.
3. A thin **controller** + **views** built on `Ui::*` components. Done for all 25 modules.
4. **Real-time**: `broadcasts_to` / `broadcasts_refreshes_to` (Solid Cable). Done for most modules (see the list of models concerned in section 0); to check case by case for the remaining ones.
5. Simple text **search** on high-volume modules (Spec §6) — to audit module by module, not exhaustively verified at this stage.
6. **API** `api/v1` + serializer (see §6 below) — **not started**, still entirely to build.
7. Model + flow + service **tests** — 83 test files present; real-time/scope-authorization coverage to audit module by module.

---

## 4. Phase 2.a — Priority modules — ✅ IMPLEMENTED

The 5 modules below have their model, controller, views, and basic real-time in place. Detailed status and remaining gaps:

1. **Shopping** (Spec §9.1) — `ShoppingList`, `ShoppingListItem`, `Product` (household catalog with `barcode`). Sorting by aisle, checking off (`Courses::ToggleItem`), PDF export (`Pdf::ShoppingListDocument`), adding (`Courses::AddItem`), an Open Food Facts lookup on scan (`OpenFoodFacts::LookupProduct`, §16 — **done**). Exposed via `api/v1` (§6).
2. **Fridge** (§9.4) — `FridgeItem`, `PreparedDish`, the `Perishable` concern. Expiration color code computed model-side, 3 locations. A two-way bridge with Shopping (`Frigo::AddFromShoppingListItem`, `Frigo::MoveToShoppingList`), the Open Food Facts lookup (shared with Shopping), expiration notifications (`Notification`, `Reminders::DeliverDue` — **done**). Exposed via `api/v1`.
3. **Recipes** (§9.5) — `Recipe`, `RecipeIngredient`, `RecipeStep`. URL import via schema.org/Recipe (`Recipes::RecipeParser`, `Recipes::ImportFromUrl`), adding to shopping (`Recipes::AddIngredientsToShoppingList`, no smart merging → matches P2, merging comes in P3). No `NutritionEstimate` yet (expected empty in P2, matches the Spec). Exposed via `api/v1` (read).
4. **Tasks** (§9.3) — `Task`, `TaskCategory` (`Tasks::CreateTask`, `Tasks::ToggleTask`, `Reordering`). Drag & drop, a kanban view per category (`board_column_id`), a due-date color code (`due_status`), `TaskReminder` + notifications (`Reminders::DeliverDue` — **done**). Exposed via `api/v1`.
5. **Calendar** (§9.2) — `CalendarEvent`, `EventParticipant` (`Calendar::CreateEvent`, the `Recurrence` engine shared with Routines per §11.2). PDF export (`Pdf::CalendarMonthDocument`), `EventReminder` + notifications (**done**), FR/BE/CH public holidays (`HolidayReference` — **done**). Exposed via `api/v1` (read). **Missing**: the real OAuth/CalDAV flow for `ExternalCalendarConnection` (scaffold in place, §16, §6).

---

## 5. Phase 2.b/c/d — ✅ IMPLEMENTED

**2.b — Simple satellites (11)**: Notes, Birthdays (`Contact`/`ContactTag`), Addresses, Service Providers, Loyalty, Pets, Vehicles, Wine Cellar, Waste (`Waste::GenerateSeries`), Baby, Messages. All have a model + controller + views + household scope. Status of previously identified gaps:
- **Addresses**: Nominatim geocoding integrated (`Geocoding::SearchAddress`, name/address/GPS pre-fill — **done**), alongside the already-existing static OpenStreetMap link.
- **Loyalty**: `LoyaltyBrand` (brand catalog, about ten brands seeded — **done**); the free-form out-of-catalog card is still available.
- **Birthdays**: **still missing** the light same-day notification (the `Notification`/`Reminders::*` infrastructure exists for other modules; a daily birthdays trigger still needs to be wired onto it).
- Contact import (phone address book): not applicable on the web, to be covered on mobile (§14) once mobile's functional parity work starts.

**2.c — Richer business logic (5)**: Menu (`MealPlanEntry`), Routines (the `Recurrence` engine shared with Calendar — done), Outdoor (`Plant`/`Pool`/`PoolReading`/`PoolAction`), Budget (`BudgetCategory`/`BudgetEntry`/`SavingsEnvelope`/`SharedProject`/`SharedExpense`, `Budget::Summary`, `Budget::SettleProject` for the split engine), Documents (`Document`/`DocumentFolder`, storage via Active Storage). Status of the previously identified gap:
- **Outdoor**: `PlantReference` (care-sheet catalog, 6 sheets seeded to start — **done**); `Plant` stays fully functional with no reference attached.

**2.d — Architecture deviations (4)** — implemented per the deviations settled in Spec §5:

- **Gifts** — **unauthenticated public sharing** via token in place (`GiftListShare`, `PublicGiftListsController`, `g/:token` routes). A contact record shared with Birthdays (`Contact`).
- **Circles** — **breaking household scoping** in place: `Circle` independent of `Household`, `CircleMembership` (users, potentially across households), `CirclePost`/`CirclePostReaction`.
- **Trip** — **cross-cutting sub-context** in place: `Trip` + a nullable `trip_id` column on `Address`/`Task` (and a `Trips::` namespace for the notes/tasks/addresses/shopping sub-resources dedicated to a trip).
- **Wellbeing** — **strict per-user privacy** in place: `WellbeingProfile`/`WeightEntry`/`WorkoutEntry` scoped by `user_id` (not `household_id`), matching the requirement in section 5 point 4. **Caution point not verified in this plan**: confirm via a dedicated authorization test that no cross-user leak exists (Spec §5's "to be tested as a priority" recommendation) before opening this module up further.

---

## 6. Cross-cutting work — status

- **Reminders and notifications**: **done**, as a single cross-cutting effort rather than module by module — `Notification`, `NotificationPreference`, `TaskReminder`, `EventReminder`, Solid Queue jobs `Reminders::DeliverDue` (due dates) and `Reminders::DailyDigest` (daily recap, `config/recurring.yml`). Covers Tasks, Calendar, Fridge. **Remaining**: wire the Birthdays same-day notification onto this same infrastructure rather than writing a new one.
- **API `api/v1`** (Spec §15): **started** on wave 2.a. `ApiToken` (opaque token, `Authorization: Bearer` header authentication, an indexed HMAC-SHA256 fingerprint), `Api::V1::BaseController` (household scoping **always server-side**, `?page`/`?per_page` pagination, uniform 401/404/422 handling), Shopping/Fridge/Recipes/Tasks/Calendar endpoints. **Remaining**: extend the pattern to the 20 remaining modules, a per-household real-time channel on the API side (the mobile client currently only does one-off HTTP, no WebSocket).
- **Real-time**: **validated.** Turbo Streams + Solid Cable are in place on most modules (`broadcasts_to` / `broadcasts_refreshes_to`) — the pattern is reused consistently, see section 0.
- **External dependencies (§16)**: the schema.org/Recipe parser (Recipes, **done**), forgot-password SMTP (**done**), Open Food Facts (Shopping/Fridge, **done**), Nominatim geocoding (Addresses, **done**), the Loyalty brand catalog (**done**), the Outdoor plant catalog (**done**), FR/BE/CH public holidays (**done**). **Remaining**: a real OAuth/CalDAV flow for external calendar sync (the `ExternalCalendarConnection` model and connection screen exist, but `connect` explicitly tells the user that application credentials are required on the host's side, rather than faking success), the Ollama/API LLM (Phase 3).
- **Flutter mobile** (Spec §14): **skeleton shipped** (`mobile/`: `ApiClient`, an API-token login screen, a read-only Shopping screen), not functional — untested (no Flutter SDK in the environment where it was created), no functional parity. **Remaining**: screens for the other 24 modules, native camera/scan, dictation, push, contact import, offline mode, a real-time connection (WebSocket to Solid Cable), transparent token renewal.
- **Marketing site / docs / governance** (Spec §8): `LICENSE` (AGPLv3), a real `README.md`, `CONTRIBUTING.md`, `CHANGELOG.md` are **done**. The **Roadmap** page built into the app is **done** (section 9). **Remaining**: a public marketing site, a per-module user documentation hub, legal notice/privacy policy.
- **Continuous quality**: `.github/workflows/ci.yml` (tests + RuboCop + Brakeman + bundler-audit) is in place and should stay green with every addition.

---

## 7. Phase 3 — Hest.AI

**Status: not started**, per the planned sequencing (it needs a critical mass of stable modules, now reached on the surface — see section 0 for the gaps to close before it's genuinely useful). A "tools" architecture on the Rails side: the LLM (self-hosted Ollama or an external API, configurable) **never writes to the database directly** — it invokes the **per-domain service objects** partly laid down since Phase 2 (§3 pt 2, to be generalized). A single entry point (header), conversation memory, household context, **explicit approval before any action**, logging. **Wellbeing stays off-limits** to the assistant on behalf of another member.

Target capabilities: conversational recipe creation + serving-size adjustment + image + nutrition (Recipes), smart adding to shopping (merging/converting), computing a prepared dish's expiration date (Fridge), assisted dictation/creation (Notes/Tasks), cross-cutting contextual suggestions.

---

## 8. Roadmap page (in-app)

A **Roadmap** page, reachable by logged-in members from within the app, publishes phase-by-phase/module-by-module progress (reusing the table from Spec §18) as well as the list of planned improvements (from the codebase audit, see Spec §19 and beyond). It lives inside the app rather than in a separate marketing site (not started, see section 6), so it stays current without depending on a separate effort.

- **Route**: `GET /roadmap` (`resource :roadmap, only: :show`).
- **Controller**: `RoadmapController#show`, with no business logic of its own (static data versioned with the code, the same way the Spec/Plan themselves are).
- **View**: `app/views/roadmap/show.html.erb`, built on the existing `Ui::*` components to stay consistent with the rest of the app.
- **Content**: phase/module status (taken from Spec §18), and a structured list of improvements identified per area (UX, reliability, modules, tech/quality, mobile, Hest.AI).

---

## 9. Sequencing summary

1. ~~Phase 1 — Foundation~~ ✅ **Done.**
2. ~~Lock down the module pattern + real-time on Shopping~~ ✅ **Done**, and extended to the other 24 modules (2.a to 2.d) ✅ **Done.**
3. ~~Close the cross-cutting gaps in already-shipped modules~~ ✅ **Mostly done**:
   1. ~~Reminders and notifications (Tasks, Calendar, Fridge)~~ ✅ **Done** — the Birthdays same-day notification remains.
   2. ~~External integrations: Open Food Facts (Shopping/Fridge), Nominatim geocoding (Addresses)~~ ✅ **Done.** Calendar OAuth/CalDAV sync (Calendar): scaffold in place, real flow remaining.
   3. ~~Reference content: the brand catalog (Loyalty), plant sheets (Outdoor), public holidays (Calendar)~~ ✅ **Done.**
   4. A dedicated authorization test for the Wellbeing module's isolation (Spec §5 pt 4 recommendation) — **still not verified in this plan.**
4. ~~Start the **`api/v1`** API~~ ✅ **Done for wave 2.a** (Shopping, Fridge, Recipes, Tasks, Calendar) — still needs to extend to the other 20 modules.
5. ~~Start the **mobile client**~~ ✅ **Skeleton shipped** (login + read-only Shopping) — full functional parity remains.
6. ~~**Marketing site / docs / governance.**~~ Governance ✅ **done** (`LICENSE`/`README`/`CONTRIBUTING`/`CHANGELOG`) + the **Roadmap** page ✅ **done** (section 8). A public marketing site and user documentation: **still to do.**
7. **Phase 3 — Hest.AI**, once the remaining cross-cutting gaps are closed (the Birthdays notification, a real OAuth/CalDAV flow, the API extension, the Wellbeing authorization test) — otherwise the assistant would inherit the same gaps.

> A living spec: this plan gets reassessed after each wave based on implementation feedback.
