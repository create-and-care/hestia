# Changelog

Toutes les évolutions notables d'Hestia sont documentées dans ce fichier.

Le format s'inspire de [Keep a Changelog](https://keepachangelog.com/fr/1.1.0/).
Le projet n'a pas encore atteint une v1.0.0 stable : les versions `1.0.0-betaN`
correspondent aux étapes successives de scaffolding du périmètre fonctionnel
décrit dans le [Cahier des charges](<Cahier des charges — Hestia.md>).

## [Non publié] — 2026-07-05

Neuf chantiers transversaux identifiés dans le
[Plan d'implémentation](<Plan d'implémentation — Hestia.md>) §6 comme
manquants sont livrés dans cette session :

### Ajouté

- **Rappels et notifications** : `Notification`, `NotificationPreference`,
  `TaskReminder`, `EventReminder`, jobs `Reminders::DeliverDue` et
  `Reminders::DailyDigest` (Solid Queue, `config/recurring.yml`), badge de
  notifications non lues dans le layout, page de préférences par utilisateur.
  Couvre Tâches, Calendrier, Frigo (péremption) et pose la structure pour
  les autres modules à venir.
- **Open Food Facts** (Courses, Frigo) : `OpenFoodFacts::LookupProduct`,
  pré-remplissage du formulaire d'article/produit au scan de code-barres via
  Stimulus (`barcode_lookup_controller.js`).
- **Géocodage Nominatim** (Adresses) : `Geocoding::SearchAddress`, recherche
  de lieu avec pré-remplissage nom/adresse/coordonnées GPS dans le formulaire
  (`geocode_lookup_controller.js`), en complément du lien OpenStreetMap
  statique déjà existant.
- **Référentiel des jours fériés** (Calendrier) : `HolidayReference`
  (France/Belgique/Suisse), pays configurable par foyer
  (`Household#holiday_country`), affichage en surbrillance dans le calendrier.
- **Catalogue d'enseignes de fidélité** (Fidélité) : `LoyaltyBrand`, une
  dizaine d'enseignes de départ en seed, sélecteur pré-remplissant
  nom/format de code dans le formulaire de carte ; la carte hors catalogue
  reste possible.
- **Catalogue de fiches d'entretien de plantes** (Extérieur) :
  `PlantReference`, six fiches de départ en seed (basilic, tomate, lavande,
  monstera, rosier, orchidée), sélecteur optionnel à l'ajout d'une plante.
- **Synchronisation calendrier externe — scaffold** (Calendrier) :
  `ExternalCalendarConnection` (Google/Microsoft/CalDAV), écran de connexion
  par fournisseur. Le flux OAuth/CalDAV réel reste à implémenter par
  l'hébergeur (identifiants d'application requis) — cf. avertissement en
  page de connexion.
- **API `api/v1`** : `ApiToken` (jeton opaque, empreinte HMAC-SHA256),
  `Api::V1::BaseController` (auth par jeton, scoping foyer serveur,
  pagination standardisée), endpoints REST/JSON pour Courses, Frigo,
  Recettes, Tâches, Calendrier — préalable bloquant levé pour le mobile.
  Gestion des jetons depuis `/api_tokens`.
- **Squelette du client mobile Flutter** (`mobile/`) : `ApiClient` (HTTP vers
  `api/v1`, jeton en en-tête Bearer), écran de connexion par jeton API, écran
  Courses en lecture seule. Non fonctionnel en l'état (Flutter SDK non
  disponible dans cet environnement, pas de parité fonctionnelle, pas de
  temps réel) — point de départ pour un chantier dédié.

### Documentation

- LICENSE (AGPLv3), README.md réel, CONTRIBUTING.md.
- Mise à jour du Cahier des charges et du Plan d'implémentation pour refléter
  les livraisons ci-dessus.

## [1.0.0-beta35] — 2026-07-03

### Corrigé

- Alignement des dépendances (`Gemfile`/`Gemfile.lock`) et de la CI GitHub
  Actions.

## [1.0.0-beta34] — 2026-07-03

### Corrigé

- Corrections d'affichage sur les listes d'envies (Cadeaux) et la fiche
  recette ; ajout du dossier `test/system`.

## [1.0.0-beta33] — 2026-07-02

### Ajouté

- Réorganisation par glisser-déposer (`Reordering`, `sortable_controller.js`)
  sur les articles de courses, les tâches et les cartes de fidélité.

## [1.0.0-beta32] — 2026-07-02

### Ajouté

- Export PDF de la liste de courses et du mois affiché du calendrier
  (`Pdf::ShoppingListDocument`, `Pdf::CalendarMonthDocument`, Prawn).

## [1.0.0-beta31] — 2026-07-02

### Ajouté

- **Module Bien-être** (écart d'architecture §5.4) : `WellbeingProfile`,
  `WeightEntry`, `WorkoutEntry`, scopés par utilisateur (pas par foyer).

## [1.0.0-beta30] — 2026-07-02

### Ajouté

- **Module Voyage** (écart d'architecture §5.3) : `Trip`, colonne `trip_id`
  sur Adresses/Notes/Tâches/Courses, namespace `Trips::` pour les
  sous-ressources dédiées au voyage.

## [1.0.0-beta29] — 2026-07-02

### Ajouté

- **Module Cercles** (écart d'architecture §5.1) : `Circle` indépendant du
  foyer, `CircleMembership`, `CirclePost`, `CirclePostReaction`.

## [1.0.0-beta28] — 2026-07-02

### Ajouté

- **Module Cadeaux** (écart d'architecture §5.2) : `GiftList`, `GiftIdea`,
  `GiftListShare` (partage public par token), `GiftReservation`, route
  publique non authentifiée `public_gift_lists`.

## [1.0.0-beta27] — 2026-07-02

### Ajouté

- **Module Documents** : `Document`, `DocumentFolder`, stockage de fichiers
  via Active Storage.

## [1.0.0-beta26] — 2026-07-02

### Ajouté

- **Module Budget** : `BudgetCategory`, `BudgetEntry`, `SavingsEnvelope`,
  `SharedProject`, `SharedExpense`, services `Budget::Summary` et
  `Budget::SettleProject` (calcul de répartition).

## [1.0.0-beta25] — 2026-07-02

### Ajouté

- **Module Extérieur** : `Plant`, `Pool`, `PoolReading`, `PoolAction`
  (jardin + piscines).

## [1.0.0-beta24] — 2026-07-02

### Ajouté

- **Module Routines** : `Routine`, `RoutineCompletion`, moteur `Recurrence`
  partagé avec le Calendrier.

## [1.0.0-beta23] — 2026-07-02

### Ajouté

- **Module Menu** : `MealPlanEntry`, planification hebdomadaire des repas
  liée aux Recettes.

## [1.0.0-beta22] — 2026-07-02

### Ajouté

- **Module Messages** : `Conversation`, `ConversationParticipant`, `Message`.

## [1.0.0-beta21] — 2026-07-02

### Ajouté

- **Module Bébé** : `BabyProfile`, `FeedingSession`, `FoodIntroduction`,
  `AllergenTest`.

## [1.0.0-beta20] — 2026-07-02

### Ajouté

- **Module Déchets** : `WasteCollectionSeries`, `WasteCollectionEvent`,
  service `Waste::GenerateSeries`.

## [1.0.0-beta19] — 2026-07-02

### Ajouté

- **Module Cave à vin** : `WineCellar`, `Bottle`.

## [1.0.0-beta18] — 2026-07-02

### Ajouté

- **Module Véhicules** : `Vehicle`, `VehicleMaintenanceEntry`.

## [1.0.0-beta17] — 2026-07-02

### Ajouté

- **Module Animaux** : `Pet`, `PetVaccination`, `PetTreatment`, `PetSupply`.

## [1.0.0-beta16] — 2026-07-02

### Ajouté

- **Module Fidélité** : `LoyaltyCard` (carte libre, hors catalogue).

## [1.0.0-beta15] — 2026-07-02

### Ajouté

- **Module Prestataires** : `ServiceProvider`, `ServiceProviderType`.

## [1.0.0-beta14] — 2026-07-02

### Ajouté

- **Module Adresses** : `Address` (quatorze types), lien d'itinéraire
  OpenStreetMap.

## [1.0.0-beta13] — 2026-07-02

### Ajouté

- **Module Anniversaires** : `Contact`, `ContactTag`, `ContactTagging`.

## [1.0.0-beta12] — 2026-07-02

### Ajouté

- **Module Notes** : `Note`, service `Notes::PromoteToTask`.

## [1.0.0-beta11] — 2026-07-02

### Ajouté

- **Module Calendrier** : `CalendarEvent`, `EventParticipant`, service
  `Calendar::CreateEvent`.

## [1.0.0-beta10] — 2026-07-02

### Ajouté

- **Module Tâches** : `Task`, `TaskCategory`, services `Tasks::CreateTask`
  et `Tasks::ToggleTask`.

## [1.0.0-beta9] — 2026-07-02

### Ajouté

- **Module Recettes** : `Recipe`, `RecipeIngredient`, `RecipeStep`, import
  depuis une URL (schema.org/Recipe) via `Recipes::ImportFromUrl`.

## [1.0.0-beta8] — 2026-07-02

### Ajouté

- **Module Frigo** : `FridgeItem`, `PreparedDish`, concern `Perishable`,
  passerelle bidirectionnelle avec Courses.

## [1.0.0-beta7] — 2026-06-30

### Ajouté

- **Module Courses** : `ShoppingList`, `ShoppingListItem`, `Product`
  (catalogue foyer), services `Courses::AddItem` et `Courses::ToggleItem`.

## [1.0.0-beta6] — 2026-06-30

### Ajouté

- **Phase 1 — Socle applicatif** : `Household`, `Membership` (rôles,
  codes d'invitation), scoping multi-foyer (`HouseholdScoped`,
  `Current.household`), inscription, onboarding, tableau de bord.
- Premières versions du Cahier des charges et du Plan d'implémentation.

## [1.0.0-beta5] — 2026-06-26

### Corrigé

- Ajustements du schéma de base et du `.gitignore`.

## [1.0.0-beta4] — 2026-06-26

### Ajouté

- Bibliothèque de composants UI `Ui::*` (style shadcn, ~50 composants
  ViewComponent) et contrôleurs Stimulus associés, exposée sur
  `/design-system`.

## [1.0.0-beta3] — 2026-06-26

### Ajouté

- Route `/design-system` (page de démonstration des composants).

## [1.0.0-beta2] — 2026-06-25

### Ajouté

- Authentification générée par Rails 8 : `User`, `Session`, connexion,
  mot de passe oublié (`PasswordsMailer`).

## [1.0.0-beta1] — 2026-06-25

### Ajouté

- Squelette initial de l'application Rails 8.1 (PostgreSQL, Solid
  Queue/Cable/Cache, Hotwire, Tailwind v4, Docker/Kamal, CI GitHub Actions).
