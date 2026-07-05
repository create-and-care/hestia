# Plan d'implémentation — Hestia

**Version :** 1.2 — dérivé du *Cahier des charges — Hestia.md* (CDC) **Statut :** document vivant, mis à jour à chaque vague livrée

Ce document traduit le CDC en backlog d'implémentation ordonné, à partir de **l'état réel du code**. Mise à jour majeure au 5 juillet 2026 : au-delà du socle (Phase 1) et des 25 modules (Phase 2, vagues 2.a à 2.d) déjà scaffoldés, cette session livre l'essentiel des chantiers transversaux qui restaient ouverts (section 0 v1.1) : rappels/notifications, intégrations externes (Open Food Facts, Nominatim), contenus de référence (Fidélité, Extérieur, jours fériés), scaffold de synchronisation calendrier externe, API `api/v1` (vague 2.a), squelette mobile Flutter, et gouvernance (`LICENSE`/`README`/`CONTRIBUTING`/`CHANGELOG`). Le détail précis par version vit dans `CHANGELOG.md`. Le backlog restant (section 0 ci-dessous) porte désormais sur l'extension de ces chantiers (API aux 20 autres modules, parité mobile, flux OAuth/CalDAV réel) et sur Hest.IA.

---

## 0. État des lieux du dépôt (au 5 juillet 2026)

**Déjà en place :**

- **Socle technique** conforme au CDC §4 : Rails 8.1, PostgreSQL, `solid_queue` / `solid_cable` / `solid_cache`, `turbo-rails` + `stimulus-rails`, `view_component`, Tailwind v4 (+ esbuild), Docker / Kamal, CI (`.github/workflows/ci.yml` : tests + RuboCop omakase + Brakeman + bundler-audit).
- **Authentification (générateur Rails 8)** : modèles `User` (`email_address`, `password_digest`) et `Session`, `Current` (`session` + `user` délégué + `household`), concern `Authentication` (cookie de session signé, `require_authentication`, `start_new_session_for`, etc.), `SessionsController` (login), `PasswordsController` + `PasswordsMailer` (mot de passe oublié), fixtures et tests associés.
- **Phase 1 — Socle applicatif, complète** : `Household` (nom, `invite_code` unique généré), `Membership` (rôle `member`/`admin`, unicité `[user_id, household_id]`), concern `HouseholdScoped`, concern contrôleur `HouseholdScoping`, `RegistrationsController`, `OnboardingController`, `HouseholdsController` (créer/afficher/activer), `MembershipsController` (rejoindre via code), `DashboardController#show` en `root`. Voir détail section 2 (conservée ci-dessous comme référence de ce qui a été construit).
- **Les 25 modules de la Phase 2 (vagues 2.a à 2.d)** : chacun a son schéma de base, son ou ses modèle(s) scopé(s) `HouseholdScoped` (ou `user_id` pour Bien-être, ou indépendant du foyer pour Cercles — écarts de la section 5 respectés), son contrôleur, ses vues sur les composants `Ui::*`, et l'essentiel du temps réel (`broadcasts_to` / `broadcasts_refreshes_to` / diffusions Turbo Stream explicites). Détail par vague en sections 4 et 5.
- **Services métier par domaine** (`app/services/`) : `Courses::AddItem`, `Courses::ToggleItem`, `Frigo::AddItem`, `Frigo::AddFromShoppingListItem`, `Frigo::MoveToShoppingList`, `Tasks::CreateTask`, `Tasks::ToggleTask`, `Recipes::ImportFromUrl`, `Recipes::RecipeParser`, `Recipes::AddIngredientsToShoppingList`, `Calendar::CreateEvent`, `Budget::Summary`, `Budget::SettleProject`, `Waste::GenerateSeries`, `Notes::PromoteToTask`, `Recurrence` (partagé Calendrier/Routines, conforme à la mutualisation prévue §11.2), `Reordering`, `Pdf::ShoppingListDocument`, `Pdf::CalendarMonthDocument`, `Reminders::DeliverDue`, `Reminders::DailyDigest`, `OpenFoodFacts::LookupProduct`, `Geocoding::SearchAddress`, `HolidayReference`. Couvre une partie des modules ; les autres ont leur logique directement dans les modèles/contrôleurs — à généraliser si Hest.IA (Phase 3) en a besoin.
- **Rappels et notifications** (chantier transversal, ex-manque) : `Notification`, `NotificationPreference`, `TaskReminder`, `EventReminder`, jobs Solid Queue `Reminders::DeliverDue` (échéances Tâches/Calendrier) et `Reminders::DailyDigest` (récapitulatif quotidien, planifié via `config/recurring.yml`), badge de notifications non lues (`shared/_notifications`), page `/notification_preferences`. Couvre Tâches, Calendrier, Frigo (péremption) ; la notification jour J des Anniversaires reste à brancher sur cette même infrastructure (cf. section 6).
- **Intégrations externes** (ex-manques) : `OpenFoodFacts::LookupProduct` (scan code-barres Courses/Frigo, `barcode_lookup_controller.js`), `Geocoding::SearchAddress` (recherche Nominatim, Adresses, `geocode_lookup_controller.js`).
- **Contenus de référence** (ex-manques) : `LoyaltyBrand` (catalogue Fidélité, seed), `PlantReference` (fiches Extérieur, seed), `HolidayReference` (jours fériés FR/BE/CH, `Household#holiday_country`).
- **Synchronisation calendrier externe — scaffold** : `ExternalCalendarConnection` (fournisseur, jetons, CalDAV), `ExternalCalendarConnectionsController` (index/connect/callback/destroy). Le flux OAuth/CalDAV réel n'est pas implémenté (nécessite des identifiants d'application côté hébergeur) — voir avertissement explicite en page de connexion plutôt qu'un faux succès.
- **API `api/v1`** (ex-manque bloquant) : `ApiToken` (jeton opaque, empreinte HMAC-SHA256), `Api::V1::BaseController` (auth par jeton, scoping foyer serveur, pagination), endpoints REST/JSON pour Courses, Frigo, Recettes, Tâches, Calendrier (vague 2.a uniquement — 20 modules restants).
- **Squelette mobile Flutter** (`mobile/`, ex-manque) : `ApiClient`, écran de connexion par jeton, écran Courses en lecture seule. Non fonctionnel, non testé, sans parité — point de départ documenté dans `mobile/README.md`.
- **Gouvernance** (ex-manque) : `LICENSE` (AGPLv3), `README.md` réel, `CONTRIBUTING.md`, `CHANGELOG.md`.
- **Tests** : 83+ fichiers (`test/models`, `test/controllers`, `test/services`) couvrant modèles, contrôleurs et services listés ci-dessus, y compris les chantiers transversaux livrés cette session.
- **Bibliothèque de composants UI** (style shadcn, ~50 composants ViewComponent : `Ui::ButtonComponent`, `DialogComponent`, `CalendarComponent`, `ChartComponent`, `ComboboxComponent`…) exposée sur la route `/design-system`. **Non mentionnée dans le CDC v1.0** — accélère toutes les vues livrées depuis.

**Manquant par rapport au CDC (backlog actuel — détail sections 6 et 8) :**

- **Synchronisation calendrier externe — flux réel** : le scaffold (`ExternalCalendarConnection`, écran de connexion) existe, mais aucun flux OAuth Google/MSAL ni CalDAV n'est effectivement câblé — nécessite des identifiants d'application fournis par l'hébergeur.
- **Notification jour J Anniversaires** : l'infrastructure de notifications existe (Tâches/Calendrier/Frigo) ; il manque le déclencheur quotidien spécifique aux anniversaires.
- **API `api/v1` — 20 modules restants** : seule la vague 2.a est exposée en API (Courses, Frigo, Recettes, Tâches, Calendrier).
- **Mobile Flutter — parité fonctionnelle** : seul un squelette (connexion + Courses lecture seule) existe ; 24 modules, caméra, dictée, push, hors-ligne, temps réel restent à construire.
- **Hest.IA (Phase 3)** : non démarrée.
- **Site vitrine / documentation utilisateur** : au-delà de la gouvernance (`LICENSE`/`README`/`CONTRIBUTING`/`CHANGELOG`) et de la page Roadmap (section 9), pas de site vitrine public ni de centre de documentation utilisateur par module.

---

## 1. Décisions de réconciliation CDC ↔ code

Le CDC §17.1 est un schéma « illustratif ». Quand il diverge du code réel, on tranche ainsi (et on met le CDC à jour) :

| Point | CDC v1.0 | Décision | Raison |
|---|---|---|---|
| Identifiant e-mail | `User.email` | **`email_address`** | Convention du générateur Rails 8 déjà en place ; renommer toucherait toute la couche auth pour zéro gain. |
| Type de clé primaire | `uuid` | **`bigint`** (défaut Rails) | `users`/`sessions` sont déjà en `bigint` ; mélanger uuid/bigint complique les FK. À réévaluer seulement si un besoin de sécurité (non-énumérabilité des ids) émerge. |
| Nom de membre | `User.name` | **ajout de `User.name`** | Requis pour l'affichage des membres (avatars, assignations Tâches/Calendrier). |
| Rôles | « permissions plates » (§6) + `role` au schéma | **`Membership.role`** (`member` / `admin`), créateur = `admin` | Permet de réserver invitations / suppression de foyer à un admin (§6 anticipe ce besoin) sans bloquer le reste. |
| Foyer actif | implicite | **`Session.active_household_id`** + `Current.household` | Multi-foyer multi-appareil : chaque session mémorise le foyer actif. |

---

## 2. Phase 1 — Socle (préalable bloquant) — ✅ TERMINÉE

> Objectif : poser `Household` / `Membership` / invitations / scoping multi-foyer + parcours inscription→onboarding→tableau de bord. Rien en Phase 2 ne démarre avant validation de ce socle.
>
> **Statut : livrée.** La liste ci-dessous est conservée comme référence de ce qui a été construit (cf. section 0) ; elle ne constitue plus un backlog à faire.

### 2.1 Données & modèles

- Migration `add_name_to_users` (`name:string`).
- Migration `create_households` : `name`, `invite_code` (index unique), timestamps.
- Migration `create_memberships` : `user`, `household`, `role` (défaut `member`), index unique `[user_id, household_id]`.
- Migration `add_active_household_to_sessions` : `active_household` (FK nullable).
- `Household` : `has_many :memberships`/`:users`, génération + unicité de `invite_code` (`before_create`, base32 lisible 8 car.), `validates :name`.
- `Membership` : `belongs_to :user`/`:household`, `validates :user_id, uniqueness: { scope: :household_id }`, enum `role`.
- `User` : `has_many :memberships`/`:households`, `validates :name`.
- `Session` : `belongs_to :active_household, optional: true`.
- `Current` : `attribute :household`.

### 2.2 Scoping multi-foyer

- `before_action` dans `ApplicationController` : `set_current_household` (résout `Current.household = session.active_household || user.households.first`) puis `require_household` (redirige vers l'onboarding si l'utilisateur n'a aucun foyer).
- Concern modèle `HouseholdScoped` (réutilisable Phase 2) : `belongs_to :household` + scope par défaut documenté + helper de création scopée. **Le filtrage se fait toujours via `Current.household`, jamais via un paramètre client** (CDC §15).

### 2.3 Parcours & écrans

- `RegistrationsController` (inscription : `name` + `email_address` + mot de passe → ouverture de session → onboarding).
- `OnboardingController` : choix « créer un foyer » / « rejoindre via code ».
- `HouseholdsController` : `new`/`create` (le créateur devient `admin`), `show`, `activate` (bascule de foyer actif).
- `MembershipsController` : `new`/`create` (rejoindre via `invite_code`).
- `DashboardController#show` → **`root`** : tableau de bord minimal (nom du foyer, membres, code d'invitation à partager, sélecteur de foyer si plusieurs). Il s'enrichira vague après vague (CDC §7).
- Recâbler les vues d'auth + nouvelles vues sur les composants `Ui::*` (cohérence visuelle avec `/design-system`).

### 2.4 Tests (Minitest)

- Modèles : génération/unicité du code d'invitation, unicité de l'adhésion, rôle du créateur.
- Flux : inscription, création de foyer, adhésion via code (valide / invalide), redirection onboarding quand sans foyer, bascule de foyer actif, isolation entre deux foyers.
- Fixtures : `households`, `memberships`, mise à jour `users` (ajout `name`).

**Définition de fini Phase 1 :** suite verte (`bin/rails test`), RuboCop + Brakeman OK, un utilisateur peut s'inscrire → créer/rejoindre un foyer → voir son tableau de bord, et deux foyers ne voient pas leurs données respectives.

---

## 3. Patron de module réutilisable — ✅ VALIDÉ

Chaque module de Phase 2 suit, sauf exception, le même gabarit, effectivement observé dans le code livré :

1. **Modèle(s)** scopé(s) foyer via `HouseholdScoped` (ou `user_id`/indépendant du foyer pour les 4 écarts d'architecture — cf. section 5).
2. **Service objects par domaine** (ex. `Courses::AddItem`) — exigé par le CDC §5 pt 5 pour que Hest.IA (Phase 3) puisse les invoquer comme « tools » ; la logique métier ne vit pas dans le contrôleur. **Statut : présent pour une partie des modules seulement** (liste section 0) — à généraliser aux autres avant de démarrer Hest.IA.
3. **Contrôleur** mince + **vues** sur les composants `Ui::*`. Fait pour les 25 modules.
4. **Temps réel** : `broadcasts_to` / `broadcasts_refreshes_to` (Solid Cable). Fait pour la majorité des modules (voir liste des modèles concernés en section 0) ; à vérifier au cas par cas pour les modules restants.
5. **Recherche** texte simple sur les modules à fort volume (CDC §6) — à auditer module par module, non vérifié exhaustivement à ce stade.
6. **API** `api/v1` + sérialiseur (cf. §6 ci-dessous) — **non démarré**, reste entièrement à construire.
7. **Tests** modèle + flux + service — 83 fichiers de tests présents ; couverture temps réel/autorisation de scope à auditer module par module.

---

## 4. Phase 2.a — Modules prioritaires — ✅ IMPLÉMENTÉS

Les 5 modules ci-dessous ont leur modèle, contrôleur, vues et temps réel de base en place. Statut détaillé et manques restants :

1. **Courses** (CDC §9.1) — `ShoppingList`, `ShoppingListItem`, `Product` (catalogue foyer avec `barcode`). Classement par rayon, coche (`Courses::ToggleItem`), export PDF (`Pdf::ShoppingListDocument`), ajout (`Courses::AddItem`), lookup Open Food Facts au scan (`OpenFoodFacts::LookupProduct`, §16 — **fait**). Exposé en API `api/v1` (§6).
2. **Frigo** (§9.4) — `FridgeItem`, `PreparedDish`, concern `Perishable`. Code couleur de péremption calculé côté modèle, 3 emplacements. Passerelle bidirectionnelle avec Courses (`Frigo::AddFromShoppingListItem`, `Frigo::MoveToShoppingList`), lookup Open Food Facts (partagé avec Courses), notifications de péremption (`Notification`, `Reminders::DeliverDue` — **fait**). Exposé en API `api/v1`.
3. **Recettes** (§9.5) — `Recipe`, `RecipeIngredient`, `RecipeStep`. Import URL via schema.org/Recipe (`Recipes::RecipeParser`, `Recipes::ImportFromUrl`), ajout aux courses (`Recipes::AddIngredientsToShoppingList`, sans fusion intelligente → conforme à la P2, fusion en P3). Pas de `NutritionEstimate` (attendu vide en P2, conforme au CDC). Exposé en API `api/v1` (lecture).
4. **Tâches** (§9.3) — `Task`, `TaskCategory` (`Tasks::CreateTask`, `Tasks::ToggleTask`, `Reordering`). Drag & drop, kanban par catégorie (`board_column_id`), code couleur d'échéance (`due_status`), `TaskReminder` + notifications (`Reminders::DeliverDue` — **fait**). Exposé en API `api/v1`.
5. **Calendrier** (§9.2) — `CalendarEvent`, `EventParticipant` (`Calendar::CreateEvent`, moteur `Recurrence` partagé avec Routines conformément à §11.2). Export PDF (`Pdf::CalendarMonthDocument`), `EventReminder` + notifications (**fait**), jours fériés FR/BE/CH (`HolidayReference` — **fait**). Exposé en API `api/v1` (lecture). **Manque** : flux OAuth/CalDAV réel de `ExternalCalendarConnection` (scaffold posé, §16, §6).

---

## 5. Phase 2.b/c/d — ✅ IMPLÉMENTÉES

**2.b — Satellites simples (11)** : Notes, Anniversaires (`Contact`/`ContactTag`), Adresses, Prestataires, Fidélité, Animaux, Véhicules, Cave à vin, Déchets (`Waste::GenerateSeries`), Bébé, Messages. Tous ont modèle + contrôleur + vues + scope foyer. Statut des manques précédemment identifiés :
- **Adresses** : géocodage Nominatim intégré (`Geocoding::SearchAddress`, pré-remplissage nom/adresse/GPS — **fait**), en complément du lien OpenStreetMap statique déjà existant.
- **Fidélité** : `LoyaltyBrand` (catalogue d'enseignes, seed d'une dizaine d'enseignes — **fait**) ; la carte libre hors catalogue reste possible.
- **Anniversaires** : **manque toujours** la notification légère le jour J (l'infrastructure `Notification`/`Reminders::*` existe pour d'autres modules, reste à y brancher un déclencheur quotidien anniversaires).
- Import de contacts (répertoire téléphone) : non applicable côté web, à couvrir côté mobile (§14) quand la parité fonctionnelle mobile démarrera.

**2.c — Logique métier riche (5)** : Menu (`MealPlanEntry`), Routines (moteur `Recurrence` commun avec Calendrier — fait), Extérieur (`Plant`/`Pool`/`PoolReading`/`PoolAction`), Budget (`BudgetCategory`/`BudgetEntry`/`SavingsEnvelope`/`SharedProject`/`SharedExpense`, `Budget::Summary`, `Budget::SettleProject` pour le moteur de répartition), Documents (`Document`/`DocumentFolder`, stockage via Active Storage). Statut du manque précédemment identifié :
- **Extérieur** : `PlantReference` (catalogue de fiches d'entretien, 6 fiches de départ en seed — **fait**) ; `Plant` reste pleinement fonctionnelle sans référence associée.

**2.d — Écarts d'architecture (4)** — implémentés conformément aux dérogations actées CDC §5 :

- **Cadeaux** — partage **public non authentifié** par token en place (`GiftListShare`, `PublicGiftListsController`, routes `g/:token`). Contact mutualisé avec Anniversaires (`Contact`).
- **Cercles** — **rupture du scoping foyer** en place : `Circle` indépendant du `Household`, `CircleMembership` (utilisateurs, potentiellement multi-foyers), `CirclePost`/`CirclePostReaction`.
- **Voyage** — **sous-contexte transverse** en place : `Trip` + colonne `trip_id` nullable sur `Address`/`Task` (et namespace `Trips::` pour les sous-ressources notes/tâches/adresses/courses dédiées au voyage).
- **Bien-être** — **confidentialité stricte par utilisateur** en place : `WellbeingProfile`/`WeightEntry`/`WorkoutEntry` scopés par `user_id` (pas `household_id`), conforme à l'exigence de la section 5 point 4. **Point de vigilance non vérifié dans ce plan** : confirmer par un test d'autorisation dédié qu'aucune fuite inter-utilisateur n'existe (recommandation CDC §5 « à tester en priorité ») avant d'ouvrir ce module plus largement.

---

## 6. Chantiers transversaux — statut

- **Rappels et notifications** : **fait**, en un chantier transversal unique plutôt que module par module — `Notification`, `NotificationPreference`, `TaskReminder`, `EventReminder`, jobs Solid Queue `Reminders::DeliverDue` (échéances) et `Reminders::DailyDigest` (récapitulatif quotidien, `config/recurring.yml`). Couvre Tâches, Calendrier, Frigo. **Reste** : brancher la notification jour J des Anniversaires sur cette même infrastructure plutôt que d'en écrire une nouvelle.
- **API `api/v1`** (CDC §15) : **démarrée** sur la vague 2.a. `ApiToken` (jeton opaque, authentification par en-tête `Authorization: Bearer`, empreinte HMAC-SHA256 indexée), `Api::V1::BaseController` (scoping foyer **toujours côté serveur**, pagination `?page`/`?per_page`, gestion uniforme 401/404/422), endpoints Courses/Frigo/Recettes/Tâches/Calendrier. **Reste** : étendre le patron aux 20 modules restants, canal temps réel par foyer côté API (le mobile ne fait pour l'instant que du HTTP ponctuel, pas de WebSocket).
- **Temps réel** : **validé.** Turbo Streams + Solid Cable en place sur la majorité des modules (`broadcasts_to` / `broadcasts_refreshes_to`) — patron réutilisé de façon cohérente, cf. section 0.
- **Dépendances externes (§16)** : parseur schema.org/Recipe (Recettes, **fait**), SMTP mot de passe oublié (**fait**), Open Food Facts (Courses/Frigo, **fait**), géocodage Nominatim (Adresses, **fait**), catalogue d'enseignes Fidélité (**fait**), catalogue de plantes Extérieur (**fait**), jours fériés FR/BE/CH (**fait**). **Reste** : flux OAuth/CalDAV réel pour la sync calendrier externe (le modèle `ExternalCalendarConnection` et l'écran de connexion existent, mais `connect` informe explicitement l'utilisateur que des identifiants d'application côté hébergeur sont requis, plutôt que de simuler un succès), LLM Ollama/API (Phase 3).
- **Mobile Flutter** (CDC §14) : **squelette livré** (`mobile/` : `ApiClient`, écran de connexion par jeton API, écran Courses en lecture seule), non fonctionnel — pas testé (Flutter SDK absent de l'environnement où il a été créé), pas de parité fonctionnelle. **Reste** : écrans des 24 autres modules, caméra/scan natif, dictée, push, import contacts, mode hors-ligne, connexion temps réel (WebSocket vers Solid Cable), renouvellement de jeton transparent.
- **Site vitrine / doc / gouvernance (CDC §8)** : `LICENSE` (AGPLv3), `README.md` réel, `CONTRIBUTING.md`, `CHANGELOG.md` **faits**. Page **Roadmap** intégrée à l'application **faite** (section 9). **Reste** : site vitrine public, centre de documentation utilisateur par module, mentions légales/politique de confidentialité.
- **Qualité continue** : `.github/workflows/ci.yml` (tests + RuboCop + Brakeman + bundler-audit) en place et à maintenir vert à chaque ajout.

---

## 7. Phase 3 — Hest.IA

**Statut : non démarrée**, conformément au séquencement (elle nécessite une masse critique de modules stables, désormais atteinte en surface — cf. section 0 pour les manques à combler avant que ce soit réellement utile). Couche « tools » côté Rails : le LLM (Ollama self-host ou API externe, configurable) **n'écrit jamais en base directement** — il invoque les **service objects par domaine** posés en partie dès la Phase 2 (§3 pt 2, à généraliser). Point d'entrée unique (header), mémoire de conversation, contexte foyer, **validation explicite avant toute action**, journalisation. **Bien-être reste inaccessible** à l'assistant pour le compte d'un autre membre.

Capacités cibles : création conversationnelle de recettes + adaptation des portions + image + nutrition (Recettes), ajout intelligent aux courses (fusion/conversion), calcul de date d'expiration des plats préparés (Frigo), dictée/création assistée (Notes/Tâches), suggestions contextuelles transverses.

---

## 8. Page Roadmap (application)

Une page **Roadmap**, accessible aux membres connectés depuis l'application, publie l'état d'avancement par phase/module (reprenant la table du CDC §18) ainsi que la liste des évolutions envisagées (issue de l'analyse applicative, cf. CDC §19 et au-delà). Elle vit dans l'application plutôt que dans un site vitrine séparé (non démarré, cf. section 6), pour rester à jour sans dépendre d'un chantier distinct.

- **Route** : `GET /roadmap` (`resource :roadmap, only: :show`).
- **Contrôleur** : `RoadmapController#show`, sans logique métier propre (données statiques versionnées avec le code, à l'image du CDC/Plan eux-mêmes).
- **Vue** : `app/views/roadmap/show.html.erb`, construite sur les composants `Ui::*` existants pour rester cohérente avec le reste de l'application.
- **Contenu** : statut par phase/module (repris du CDC §18), et liste structurée des améliorations identifiées par domaine (UX, fiabilité, modules, technique/qualité, mobile, Hest.IA).

---

## 9. Séquencement résumé

1. ~~Phase 1 — Socle~~ ✅ **Terminée.**
2. ~~Figer le patron de module + temps réel sur Courses~~ ✅ **Fait**, et étendu aux 24 autres modules (2.a à 2.d) ✅ **Fait.**
3. ~~Combler les manques transversaux des modules déjà livrés~~ ✅ **Fait pour l'essentiel** :
   1. ~~Rappels et notifications (Tâches, Calendrier, Frigo)~~ ✅ **Fait** — reste la notification jour J Anniversaires.
   2. ~~Intégrations externes : Open Food Facts (Courses/Frigo), géocodage Nominatim (Adresses)~~ ✅ **Fait.** Sync calendrier OAuth/CalDAV (Calendrier) : scaffold posé, flux réel restant.
   3. ~~Contenus de référence : catalogue d'enseignes (Fidélité), fiches de plantes (Extérieur), jours fériés (Calendrier)~~ ✅ **Fait.**
   4. Test d'autorisation dédié pour l'étanchéité du module Bien-être (recommandation CDC §5 pt 4) — **toujours non vérifié dans ce plan.**
4. ~~Démarrer l'**API `api/v1`**~~ ✅ **Fait pour la vague 2.a** (Courses, Frigo, Recettes, Tâches, Calendrier) — reste à étendre aux 20 autres modules.
5. ~~Démarrer le **mobile**~~ ✅ **Squelette livré** (connexion + Courses lecture seule) — reste la parité fonctionnelle complète.
6. ~~**Site vitrine / doc / gouvernance.**~~ Gouvernance ✅ **faite** (`LICENSE`/`README`/`CONTRIBUTING`/`CHANGELOG`) + page **Roadmap** ✅ **faite** (section 8). Site vitrine public et documentation utilisateur : **restent à faire.**
7. **Phase 3 — Hest.IA**, une fois les manques transversaux restants comblés (notification Anniversaires, flux OAuth/CalDAV réel, extension API, test d'autorisation Bien-être) — sans quoi l'assistant hériterait des mêmes lacunes.

> Cahier des charges vivant : ce plan est réévalué après chaque vague selon les retours d'implémentation.