# Plan d'implémentation — Hestia

**Version :** 1.0 — dérivé du *Cahier des charges — Hestia.md* (CDC) **Statut :** document vivant, mis à jour à chaque vague livrée

Ce document traduit le CDC en backlog d'implémentation ordonné, à partir de **l'état réel du code** (et non de l'hypothèse « rien n'est encore codé » du CDC v1.0). Il sert de fil conducteur : on déroule les sections dans l'ordre, module par module.

---

## 0. État des lieux du dépôt (au démarrage)

**Déjà en place :**

- **Socle technique** conforme au CDC §4 : Rails 8.1, PostgreSQL, `solid_queue` / `solid_cable` / `solid_cache`, `turbo-rails` + `stimulus-rails`, `view_component`, Tailwind v4 (+ esbuild), Docker / Kamal, CI (`bin/ci`), RuboCop omakase, Brakeman, bundler-audit.
- **Authentification (générateur Rails 8)** : modèles `User` (`email_address`, `password_digest`) et `Session`, `Current` (`session` + `user` délégué), concern `Authentication` (cookie de session signé, `require_authentication`, `start_new_session_for`, etc.), `SessionsController` (login), `PasswordsController` + `PasswordsMailer` (mot de passe oublié), fixtures et tests associés.
- **Bibliothèque de composants UI** (style shadcn, ~50 composants ViewComponent : `Ui::ButtonComponent`, `DialogComponent`, `CalendarComponent`, `ChartComponent`, `ComboboxComponent`…) exposée sur la route `/design-system`. **Non mentionnée dans le CDC v1.0** — c'est un atout pour accélérer toutes les vues à venir.

**Manquant par rapport au CDC :**

- **Phase 1 incomplète** : pas de `Household`, pas de `Membership`, pas de code d'invitation, pas de scoping multi-foyer, **pas d'inscription** (le générateur Rails 8 ne crée que login + reset, pas le signup), pas d'onboarding, pas de tableau de bord, pas de `root`.
- **Aucun des 25 modules** fonctionnels.
- Les vues d'auth sont les gabarits bruts du générateur (styles inline), **non câblées** au design system.

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

## 2. Phase 1 — Socle (préalable bloquant)

> Objectif : poser `Household` / `Membership` / invitations / scoping multi-foyer + parcours inscription→onboarding→tableau de bord. Rien en Phase 2 ne démarre avant validation de ce socle.

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

## 3. Patron de module réutilisable (à figer pendant la 2.a)

Chaque module de Phase 2 suit, sauf exception, le même gabarit — à standardiser dès Courses puis réutiliser :

1. **Modèle(s)** scopé(s) foyer via `HouseholdScoped`.
2. **Service objects par domaine** (ex. `Courses::AddItem`) — exigé par le CDC §5 pt 5 pour que Hest.IA (Phase 3) puisse les invoquer comme « tools » ; la logique métier ne vit pas dans le contrôleur.
3. **Contrôleur** mince + **vues** sur les composants `Ui::*`.
4. **Temps réel** : `broadcasts_to ->(record) { record.household }` + `turbo_stream_from Current.household` dans les vues (Solid Cable). Valider le patron temps réel ici.
5. **Recherche** texte simple sur les modules à fort volume (CDC §6).
6. **API** `api/v1` + sérialiseur (cf. §6 ci-dessous), montée en parallèle.
7. **Tests** modèle + flux + temps réel + autorisation de scope.

---

## 4. Phase 2.a — Modules prioritaires (valident le patron)

Ordre conseillé pour exploiter les interconnexions (Recettes ↔ Courses ↔ Frigo ↔ Menu) :

1. **Courses** (CDC §9.1) — `ShoppingList`, `ShoppingListItem`, `Product` (catalogue foyer). Classement par rayon, coche, export PDF, scan code-barres. **Dépendance** : Open Food Facts (§16). Premier module = on y fige le patron §3 + le temps réel.
2. **Frigo** (§9.4) — `FridgeItem`, `PreparedDish`. Code couleur de péremption **calculé serveur**, 3 emplacements. Passerelle bidirectionnelle avec Courses.
3. **Recettes** (§9.5) — `Recipe`, `RecipeIngredient`, `RecipeStep`, `NutritionEstimate` (vide en P2). Import URL via schema.org/Recipe, ajout simple aux courses (sans fusion intelligente → P3).
4. **Tâches** (§9.3) — `Task`, `TaskCategory`, `TaskReminder`. Drag & drop, kanban par catégorie, code couleur d'échéance.
5. **Calendrier** (§9.2) — `CalendarEvent`, `EventParticipant`, `EventReminder`, `ExternalCalendarConnection`. **Moteur de récurrence à mutualiser avec Routines** (§11.2). **Sync externe** : OAuth Google / MSAL / CalDAV (§16). Le plus lourd de la vague → en dernier.

---

## 5. Phase 2.b/c/d — Vagues suivantes

**2.b — Satellites simples (11)** : Notes, Anniversaires, Adresses, Prestataires, Fidélité, Animaux, Véhicules, Cave à vin, Déchets, Bébé, Messages. Tous sur le patron liste + fiche + recherche + scope foyer. Spécificités : géocodage (Adresses, §16), entité `Contact` partagée Anniversaires↔Cadeaux, import contacts (mobile), catalogue d'enseignes Fidélité, séries récurrentes Déchets, `BabyProfile` (membre « bébé »).

**2.c — Logique métier riche (5)** : Menu (`MealPlanEntry`), Routines (**moteur de récurrence commun avec Calendrier**), Extérieur (`PlantReference`/`Plant`/`Pool`/relevés), Budget (catégories typées, enveloppes, **moteur de répartition** projets partagés), Documents (capture→PDF, **stockage fichiers** Active Storage : volume Docker / S3, §16).

**2.d — Écarts d'architecture (4)** — à traiter en dernier car ils dérogent au scope foyer (CDC §5) :

- **Cadeaux** — partage **public non authentifié** par token (`GiftListShare`), route hors périmètre auth. Contact mutualisé avec Anniversaires.
- **Cercles** — **rupture du scoping foyer** : `Circle` indépendant du `Household`, membres = utilisateurs (potentiellement multi-foyers), visibilité par cercle.
- **Voyage** — **sous-contexte transverse** : entité `Trip` + colonne `trip_id` nullable sur `ShoppingListItem`/`Note`/`Task`/`Address`/`MealPlanEntry`/`BudgetExpense` (concept générique de contexte réutilisable), plutôt que dupliquer chaque module.
- **Bien-être** — **confidentialité stricte par utilisateur** (`user_id`, jamais le foyer) : exception la plus sensible → **tests d'autorisation dédiés en priorité**, et accès interdit à Hest.IA pour le compte d'autrui (§13).

> Idéalement, poser les fondations transverses (concept `Trip`/contexte, entité `Contact`, scoping `user_id` du Bien-être) **tôt** si elles touchent des modèles créés avant — pour éviter des migrations coûteuses ultérieures (CDC §5, étape 2 de la roadmap).

---

## 6. Chantiers transversaux (en parallèle des vagues)

- **API `api/v1`** (CDC §15) : REST/JSON versionnée, **auth par jeton** pour le mobile (JWT ou jeton opaque — à trancher), scoping foyer **toujours côté serveur**, pagination + filtrage standardisés, canal temps réel par foyer. Montée endpoint par endpoint, en suivant les modules.
- **Temps réel** : valider Turbo Streams + Solid Cable dès Courses, puis généraliser.
- **Dépendances externes (§16)** : Open Food Facts (2.a), géocodage Nominatim (2.b), sync calendrier OAuth/CalDAV (2.a), parseur schema.org/Recipe (2.a), SMTP (déjà requis par le reset de mot de passe), stockage fichiers (2.c), LLM Ollama/API (P3).
- **Mobile Flutter** (CDC §14) : démarre une fois l'API `api/v1` stabilisée sur 2.a ; parité fonctionnelle + caméra/scan, dictée, push, import contacts, hors-ligne lecture.
- **Site vitrine / doc / gouvernance (CDC §8)** : `LICENSE` (AGPLv3), `README`, `CONTRIBUTING`, changelog, doc utilisateur Markdown, mentions légales — après les premières vagues.
- **Qualité continue** : `bin/ci` (tests + RuboCop + Brakeman + bundler-audit) maintenu vert à chaque module.

---

## 7. Phase 3 — Hest.IA

Après une masse critique de modules stables (CDC §13). Couche « tools » côté Rails : le LLM (Ollama self-host ou API externe, configurable) **n'écrit jamais en base directement** — il invoque les **service objects par domaine** posés dès la Phase 2 (§3 pt 2). Point d'entrée unique (header), mémoire de conversation, contexte foyer, **validation explicite avant toute action**, journalisation. **Bien-être reste inaccessible** à l'assistant pour le compte d'un autre membre.

Capacités cibles : création conversationnelle de recettes + adaptation des portions + image + nutrition (Recettes), ajout intelligent aux courses (fusion/conversion), calcul de date d'expiration des plats préparés (Frigo), dictée/création assistée (Notes/Tâches), suggestions contextuelles transverses.

---

## 8. Séquencement résumé

1. **Phase 1 — Socle** *(en cours via ce plan)* : Household, Membership, invitations, scoping, inscription→onboarding→tableau de bord, tests.
2. Figer le **patron de module** (+temps réel) sur **Courses**, brancher **Open Food Facts**.
3. Dérouler **2.a** (Frigo, Recettes, Tâches, Calendrier) en montant l'**API `api/v1`** en parallèle.
4. Démarrer le **mobile** une fois l'API 2.a stable.
5. **2.b**, puis **2.c**, puis **2.d** (écarts d'archi en dernier ; poser tôt les fondations transverses qui touchent des modèles précoces).
6. **Site vitrine / doc / gouvernance**.
7. **Phase 3 — Hest.IA**.

> Cahier des charges vivant : ce plan est réévalué après chaque vague selon les retours d'implémentation.