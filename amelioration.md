## 📌 **Présentation du projet**
**Hestia** est une application **open-source (AGPLv3)** de gestion de foyer **auto-hébergeable**, conçue comme une alternative gratuite aux applications freemium comme **Todoist, Notion, Google Calendar, ou YNAB**.
Elle couvre **25 modules** (courses, frigo, recettes, tâches, calendrier, budget, etc.) et vise à centraliser **toute la logistique familiale** en un seul endroit, avec :
- **Multi-utilisateurs** (famille, colocataires).
- **Temps réel** (Hotwire + Solid Cable).
- **API REST** pour un client mobile (Flutter).
- **Pas de dépendance à Redis** (PostgreSQL seul).
- **Docker/Kamal** pour le déploiement.

---

# ✅ **Points forts (ce qui marche bien)**

### 1. **Architecture technique solide**
- **Stack moderne** : Rails 8.1 + PostgreSQL + Hotwire (Turbo/Stimulus) + Tailwind v4.
  → **Performant, scalable, et maintenable**.
- **Pas de Redis** : Solid Queue/Cable/Cache tournent sur PostgreSQL.
  → **Simplifie l’auto-hébergement** (1 seul service à gérer).
- **Docker/Kamal** : Déploiement simplifié pour les non-experts.
- **CI/CD complète** : Tests (Minitest + Capybara), linting (RuboCop), sécurité (Brakeman, Bundler Audit).
- **API versionnée** (`api/v1`) : Prête pour le mobile et l’IA (Hest.AI).

### 2. **Fonctionnalités complètes**
- **25 modules** couvrant **tous les aspects du quotidien** :
  - **Gestion des courses** (listes, produits, catalogues).
  - **Frigo** (périssables, plats préparés, lien avec les courses).
  - **Recettes** (import depuis des URLs, étapes, ingrédients).
  - **Calendrier** (événements, rappels, synchronisation externe).
  - **Tâches** (catégories, rappels, réorganisation glisser-déposer).
  - **Budget** (catégories, dépenses, enveloppes, projets partagés).
  - **Santé/bébé** (profil, poids, allergies, tétées).
  - **Social** (cercles, cadeaux, messages, fidélité).
  - **Voyages** (contexte transversal pour les notes/tâches/adresses).
  - **Extérieur** (plantes, piscine).
  - **Documents** (stockage de fichiers).
  → **Rien ne manque** pour une famille ou des colocataires.

- **Fonctionnalités avancées** :
  - **Recherche globale** (across tous les modules).
  - **Notifications** (rappels, digest quotidien).
  - **PDF export** (listes de courses, calendrier).
  - **Géocodage** (Nominatim pour les adresses).
  - **Open Food Facts** (recherche de produits par code-barres).
  - **Synchronisation calendrier externe** (Google, Microsoft, CalDAV).
  - **Catalogues** (marques de fidélité, fiches de soins des plantes).

### 3. **Expérience utilisateur (UX)**
- **Design system cohérent** :
  - **~50 composants UI** (shadcn-style) réutilisables (`Ui::ButtonComponent`, `Ui::CardComponent`, etc.).
  - **Thème personnalisable** (couleurs, typographie).
  - **Responsive** (adapté mobile/desktop).
- **Navigation intuitive** :
  - **Sidebar groupée** (Quotidien, Maison, Famille, Social).
  - **Modules activables/désactivables** par foyer.
- **Temps réel** :
  - Mises à jour instantanées (ex: ajout d’un produit dans la liste de courses).
- **Multi-langues** : Français et Anglais (fichiers YAML bien structurés).

### 4. **Sécurité et confidentialité**
- **Chiffrement** :
  - Tokens OAuth (calendrier externe) chiffrés en base.
  - Mots de passe sécurisés (`has_secure_password`).
- **AGPLv3** :
  - **100% open-source**, pas de features payantes.
  - **Auto-hébergement possible** sans dépendre d’un tiers.
- **Gestion des sessions** :
  - Revocation des sessions actives.
  - Tokens API pour le mobile (HMAC-SHA256).

### 5. **Documentation**
- **README.md** : Clairs, exemples de commandes Docker.
- **CONTRIBUTING.md** : Guide pour les contributeurs (conventions, tests).
- **CHANGELOG.md** : Historique détaillé des versions.
- **Roadmap intégrée** (`/roadmap`) : Suivi des fonctionnalités en temps réel.

---

# ❌ **Points faibles (ce qui pose problème)**

## 🔴 **Problèmes critiques (à corriger en priorité)**

### 1. **Performances et scalabilité**
- **Requêtes N+1** :
  - Beaucoup de vues chargent des associations sans `includes`.
  - Exemple : Dans `app/views/dashboard/show.html.erb`, si on affiche les dernières tâches + courses + événements, chaque module fait une requête séparée.
  - **Solution** : Utiliser `includes` ou `preload` systématiquement dans les contrôleurs.
  - **Outils** : `bullet` gem pour détecter les N+1.

- **Chargement des assets** :
  - **Tailwind v4** est encore en beta (risque de breaking changes).
  - **JavaScript** : Pas de code splitting (tout est chargé en une fois).
  - **Solution** : Utiliser `importmap-rails` ou `esbuild` pour le code splitting.

- **Base de données** :
  - **120 migrations** : Certaines tables pourraient être optimisées (index manquants, colonnes inutiles).
  - **Exemple** : `Household` a une colonne `disabled_modules` (array) qui peut devenir lourde si beaucoup de modules sont désactivés.
  - **Solution** : Ajouter des index sur les colonnes fréquemment interrogées (ex: `user_id`, `household_id`).

- **Jobs Solid Queue** :
  - **Pas de priorisation** : Tous les jobs sont traités dans l’ordre FIFO.
  - **Solution** : Utiliser `priority` dans les jobs critiques (ex: notifications).

### 2. **Sécurité**
- **CSRF** :
  - L’API (`api/v1`) utilise des tokens Bearer, mais **pas de protection CSRF** pour les requêtes web classiques.
  - **Risque** : Attaques CSRF si l’utilisateur est connecté sur un site malveillant.
  - **Solution** : Activer `protect_from_forgery` dans `ApplicationController` (déjà présent, mais vérifier que toutes les routes web sont couvertes).

- **XSS** :
  - Certaines vues utilisent `raw` ou `html_safe` sans sanitization.
  - **Exemple** : Dans `app/views/recipes/show.html.erb`, si un utilisateur injecte du HTML dans une recette, il pourrait être exécuté.
  - **Solution** : Utiliser `sanitize` ou `ActionView::Helpers::SanitizeHelper`.

- **SQL Injection** :
  - Certaines requêtes utilisent des interpolations de strings au lieu de paramètres.
  - **Exemple** : `where("name = '#{params[:name]}'")` → **DANGER**.
  - **Solution** : Utiliser `where(name: params[:name])` ou `sanitize_sql`.

- **Authentification** :
  - **Pas de 2FA** : Compte tenu de la sensibilité des données (budget, santé, etc.), le 2FA devrait être obligatoire.
  - **Solution** : Intégrer `devise-two-factor` ou `rotp`.

- **Tokens API** :
  - Les tokens API ne sont **pas limités en durée de vie**.
  - **Solution** : Ajouter un `expires_at` et un mécanisme de rotation.

### 3. **Stabilité et bugs**
- **Flutter Mobile** :
  - **Squelette non fonctionnel** : Le client mobile (`mobile/`) est un squelette qui ne compile pas (pas de SDK Flutter dans l’environnement).
  - **Problème** : L’API est prête, mais le client mobile ne peut pas être testé.
  - **Solution** :
    - Soit **supprimer le dossier `mobile/`** si le projet se concentre sur le web.
    - Soit **le rendre fonctionnel** (ajouter un `pubspec.yaml` valide, implémenter les écrans manquants).

- **Synchronisation calendrier externe** :
  - **OAuth non implémenté** : Les connexions Google/Microsoft/CalDAV affichent un warning ("à implémenter par l’hôte").
  - **Problème** : La fonctionnalité est annoncée mais **non utilisable**.
  - **Solution** :
    - Soit **implémenter OAuth** (avec `omniauth-google`, `omniauth-microsoft`).
    - Soit **masquer la fonctionnalité** jusqu’à ce qu’elle soit prête.

- **Géocodage (Nominatim)** :
  - **Pas de cache** : Chaque recherche d’adresse fait un appel API à Nominatim.
  - **Risque** : Limite de requêtes (Nominatim bloque après trop de requêtes).
  - **Solution** : Cacher les résultats dans `Solid Cache` ou PostgreSQL.

- **Open Food Facts** :
  - **Pas de fallback** : Si l’API Open Food Facts est down, la recherche de produits échoue.
  - **Solution** : Ajouter un cache local ou un fallback vers une base de données interne.

- **PDF Export** :
  - **Prawn** : La génération de PDF peut planter avec des caractères spéciaux (UTF-8).
  - **Solution** : Utiliser `wicked_pdf` (basé sur wkhtmltopdf) pour une meilleure gestion du HTML/PDF.

### 4. **Expérience utilisateur (UX)**
- **Onboarding complexe** :
  - **Trop d’étapes** : Création de compte → Choix du foyer → Invitation des membres → Configuration des modules.
  - **Problème** : Un utilisateur lambda peut abandonner avant de comprendre comment ça marche.
  - **Solution** :
    - **Ajouter un tutoriel guidé** (ex: "Bienvenue dans Hestia ! Voici comment ajouter votre première liste de courses").
    - **Pré-remplir des données d’exemple** (ex: une liste de courses avec 3 produits, une recette simple).

- **Mobile non optimisé** :
  - **Pas de PWA** : L’application n’est pas installable sur mobile (pas de `manifest.json` ou `service-worker`).
  - **Problème** : Sur mobile, l’expérience est celle d’un site web, pas d’une app native.
  - **Solution** :
    - Activer les lignes commentées dans `config/routes.rb` pour la PWA.
    - Ajouter un `manifest.json` et un `service-worker.js`.

- **Notifications intrusives** :
  - **Pas de contrôle fin** : Les notifications sont soit activées, soit désactivées.
  - **Problème** : Un utilisateur peut vouloir recevoir des notifications pour les tâches mais pas pour le calendrier.
  - **Solution** : Permettre de configurer les notifications **par module**.

- **Recherche globale lente** :
  - **`GlobalSearch`** : La recherche across tous les modules peut être lente si la base est grosse.
  - **Solution** :
    - Ajouter un index **full-text** sur les colonnes pertinentes.
    - Utiliser **PostgreSQL `tsvector`** pour une recherche plus rapide.

- **Accessibilité (a11y)** :
  - **Manque de labels** : Certains boutons n’ont pas de `aria-label`.
  - **Contraste des couleurs** : Certains textes ont un contraste insuffisant (ex: gris clair sur fond blanc).
  - **Solution** :
    - Utiliser `axe-core` pour auditer l’accessibilité.
    - Corriger les contrastes avec Tailwind (ex: `text-gray-800` au lieu de `text-gray-400`).

### 5. **Internationalisation (i18n)**
- **Traductions incomplètes** :
  - Certains modules n’ont **pas de traduction française** (ex: `waste`, `outdoor`).
  - **Exemple** : Dans `config/locales/fr/`, il manque `waste.yml`, `outdoor.yml`, `wellbeing.yml`.
  - **Solution** : Compléter les fichiers de traduction pour tous les modules.

- **Dates et nombres** :
  - **Formatage non localisé** : Certaines dates sont affichées au format américain (`MM/DD/YYYY`) même en français.
  - **Solution** : Utiliser `I18n.l` systématiquement pour les dates.

### 6. **Gestion des erreurs**
- **Messages d’erreur peu clairs** :
  - Exemple : Si un utilisateur essaie d’ajouter un produit en double dans la liste de courses, le message d’erreur est générique ("Une erreur est survenue").
  - **Solution** : Personnaliser les messages d’erreur pour chaque cas.

- **500 Errors non gérées** :
  - Si une exception est levée, l’utilisateur voit une page blanche ou un stack trace.
  - **Solution** :
    - Créer une page `500.html.erb` personnalisée.
    - Utiliser `rescue_from` dans `ApplicationController`.

### 7. **Documentation utilisateur**
- **Pas de guide utilisateur** :
  - **Problème** : Un utilisateur lambda ne sait pas comment utiliser les modules avancés (ex: budget, routines).
  - **Solution** :
    - Ajouter une **section "Aide"** dans le menu.
    - Créer des **vidéos tutoriels** ou des **GIFs animés**.

- **Roadmap peu visible** :
  - La roadmap est accessible via `/roadmap`, mais **pas de lien dans le menu principal**.
  - **Solution** : Ajouter un lien "Roadmap" dans le footer ou le menu utilisateur.

---

# 🟡 **Opportunités d’amélioration (non critiques mais utiles)**

## 🚀 **Fonctionnalités manquantes (pour une famille)**

### 1. **Gestion des repas**
- **Idées de repas** :
  - **Problème** : Le module **Menu** permet de planifier des repas, mais il n’y a pas de **suggestions de recettes** basées sur les ingrédients disponibles dans le frigo.
  - **Solution** :
    - Ajouter un bouton **"Suggérer des recettes"** qui filtre les recettes du foyer en fonction des ingrédients dans le frigo.
    - Intégrer une API comme **Spoonacular** pour des suggestions externes.

- **Listes de courses automatiques** :
  - **Problème** : Quand on planifie un repas, il faut manuellement ajouter les ingrédients manquants à la liste de courses.
  - **Solution** :
    - Ajouter un bouton **"Ajouter les ingrédients manquants à la liste de courses"** dans le module Menu.

### 2. **Budget et finances**
- **Synchronisation bancaire** :
  - **Problème** : Il faut manuellement saisir les dépenses.
  - **Solution** :
    - Intégrer une API comme **Plaid** ou **Nordigen** pour importer automatiquement les transactions bancaires.
    - **Alternative open-source** : Utiliser **Firefly III** (auto-hébergé) et synchroniser les données via son API.

- **Budget par catégorie et par mois** :
  - **Problème** : Le module Budget permet de suivre les dépenses, mais il n’y a pas de **visualisation graphique** (camembert, histogramme).
  - **Solution** :
    - Ajouter des graphiques avec **Chart.js** ou **D3.js**.
    - Permettre de **comparer les dépenses mois par mois**.

- **Rappels de paiements** :
  - **Problème** : Pas de rappels pour les factures récurrentes (électricité, loyer, etc.).
  - **Solution** :
    - Ajouter un module **"Factures"** avec des rappels automatiques.
    - Intégrer un **calendrier de paiements** dans le module Budget.

### 3. **Santé et bien-être**
- **Suivi médical** :
  - **Problème** : Le module **Wellbeing** permet de suivre le poids et les workouts, mais il manque :
    - **Suivi des médicaments** (rappels de prise).
    - **Suivi des cycles menstruels** (pour les femmes).
    - **Suivi des vaccins** (pour les enfants).
  - **Solution** :
    - Étendre le module Wellbeing avec ces fonctionnalités.
    - Ou créer un module **Santé** dédié.

- **Allergies et intolérances** :
  - **Problème** : Les allergies sont gérées dans le module **Baby**, mais pas pour les adultes.
  - **Solution** :
    - Ajouter un **profil santé** pour chaque utilisateur (allergies, intolérances, médicaments).
    - **Filtrage des recettes** : Masquer les recettes contenant des allergènes.

### 4. **Éducation et enfants**
- **Suivi scolaire** :
  - **Problème** : Pas de module pour suivre les notes, les devoirs, ou les activités extrascolaires des enfants.
  - **Solution** :
    - Ajouter un module **"École"** avec :
      - Calendrier des devoirs.
      - Suivi des notes.
      - Rappels des réunions parents-professeurs.

- **Temps d’écran** :
  - **Problème** : Pas de moyen de limiter ou suivre le temps d’écran des enfants.
  - **Solution** :
    - Intégrer un **minuteur** dans le module Tasks (ex: "Temps d’écran : 1h/jour").
    - **Alternative** : Créer un module **"Parental Control"** (mais complexe à implémenter côté serveur).

### 5. **Maison et logistique**
- **Inventaire des biens** :
  - **Problème** : Pas de moyen de suivre les objets de la maison (meubles, électroménager, etc.) pour l’assurance ou la revente.
  - **Solution** :
    - Ajouter un module **"Inventaire"** avec :
      - Photos des objets.
      - Valeur estimée.
      - Date d’achat.
      - Rappels de garantie.

- **Maintenance de la maison** :
  - **Problème** : Le module **Vehicles** permet de suivre l’entretien des voitures, mais il n’y a rien pour la maison (chaudière, climatisation, etc.).
  - **Solution** :
    - Étendre le module **Service Providers** pour inclure les **prestataires de maintenance** (plombier, électricien).
    - Ajouter un **calendrier de maintenance** (ex: "Vider la chaudière tous les ans").

### 6. **Social et partage**
- **Partage externe** :
  - **Problème** : Le module **Gifts** permet de partager des listes de cadeaux via un lien public, mais :
    - Pas de **mot de passe** pour protéger le lien.
    - Pas de **date d’expiration** pour le lien.
  - **Solution** :
    - Ajouter un **mot de passe** et une **date d’expiration** pour les liens publics.
    - Permettre de **désactiver le partage** à tout moment.

- **Collaboration avec des non-utilisateurs** :
  - **Problème** : Impossible d’inviter des personnes qui n’ont pas de compte Hestia (ex: un parent qui veut voir la liste de courses).
  - **Solution** :
    - Ajouter un **mode "invité"** avec un lien temporaire (ex: 24h).
    - Permettre de **partager des listes de courses en lecture seule** via un lien.

### 7. **Automatisation et IA**
- **Suggestions intelligentes** :
  - **Problème** : Pas de suggestions automatiques (ex: "Vous avez souvent acheté du lait le lundi, voulez-vous l’ajouter à la liste ?").
  - **Solution** :
    - Utiliser **l’historique des achats** pour suggérer des produits.
    - Intégrer un **système de recommandation** (ex: "Les utilisateurs qui ont acheté X ont aussi acheté Y").

- **Détection des doublons** :
  - **Problème** : On peut ajouter plusieurs fois le même produit dans la liste de courses.
  - **Solution** :
    - Ajouter une **détection automatique des doublons** (ex: "Lait" et "lait" sont considérés comme identiques).
    - **Fusionner automatiquement** les doublons.

- **Rappels contextuels** :
  - **Problème** : Les rappels sont basiques (ex: "Rappel : Acheter du lait").
  - **Solution** :
    - Ajouter des **rappels contextuels** (ex: "Quand tu passes près du supermarché X, achète du lait").
    - Utiliser la **géolocalisation** (si l’utilisateur l’autorise).

### 8. **Intégrations externes**
- **IFTTT/Zapier** :
  - **Problème** : Pas d’intégration avec des outils comme IFTTT ou Zapier pour automatiser des tâches (ex: "Si un nouvel événement est ajouté dans Google Calendar, crée-le dans Hestia").
  - **Solution** :
    - Créer une **API webhook** pour recevoir des événements externes.
    - Documenter comment utiliser **Zapier** avec l’API de Hestia.

- **Alexa/Google Assistant** :
  - **Problème** : Impossible d’ajouter des éléments à la liste de courses via la voix.
  - **Solution** :
    - Créer une **skill Alexa** ou une **action Google Assistant**.
    - **Alternative** : Utiliser l’API pour créer un **bot Discord/Slack**.

- **Calendrier scolaire** :
  - **Problème** : Pas d’intégration avec les calendriers scolaires (ex: zones A/B/C en France).
  - **Solution** :
    - Ajouter un **calendrier scolaire pré-rempli** (via une API comme [Education Nationale](https://data.education.gouv.fr/)).
    - Permettre de **superposer** le calendrier scolaire avec le calendrier personnel.

### 9. **Personnalisation**
- **Thèmes personnalisés** :
  - **Problème** : Seuls 2 thèmes sont disponibles (clair/sombre).
  - **Solution** :
    - Permettre de **choisir des couleurs personnalisées** (ex: couleur principale, secondaire).
    - Ajouter des **thèmes prédéfinis** (ex: "Nature", "Minimaliste", "Arc-en-ciel").

- **Disposition des modules** :
  - **Problème** : L’ordre des modules dans la sidebar est fixe.
  - **Solution** :
    - Permettre de **réorganiser les modules** via glisser-déposer.
    - Sauvegarder la disposition **par utilisateur**.

- **Langues supplémentaires** :
  - **Problème** : Seuls le français et l’anglais sont disponibles.
  - **Solution** :
    - Ajouter l’**espagnol**, l’**allemand**, l’**italien** (langues courantes en Europe).
    - Utiliser **Crowdin** ou **Transifex** pour la traduction collaborative.

### 10. **Analytique et insights**
- **Statistiques d’utilisation** :
  - **Problème** : Pas de moyen de voir quels modules sont les plus utilisés.
  - **Solution** :
    - Ajouter un **tableau de bord d’analytique** (ex: "Vous avez ajouté 20 produits cette semaine").
    - **Anonymiser les données** pour respecter la vie privée.

- **Historique des modifications** :
  - **Problème** : Impossible de voir qui a modifié une tâche ou une liste de courses.
  - **Solution** :
    - Ajouter un **historique des changements** (ex: "Marie a ajouté 'Lait' à la liste de courses hier à 14h").
    - Utiliser **Paper Trail** pour suivre les modifications.

---

# 🗑️ **Suggestions de suppression ou de refonte**

## ❌ **À supprimer (ou à désactiver par défaut)**

### 1. **Module "Circles" (Cercles)**
- **Problème** :
  - **Architecture complexe** : Les cercles sont **indépendants des foyers**, ce qui casse la logique de scoping par défaut.
  - **Peu utile** : La plupart des utilisateurs n’ont pas besoin de cercles en plus des foyers.
  - **Duplication** : Les fonctionnalités de Cercles (posts, réactions) pourraient être intégrées dans le module **Messages** ou **Gifts**.
- **Solution** :
  - **Supprimer le module** et intégrer ses fonctionnalités ailleurs.
  - **Ou** : Le désactiver par défaut et le laisser comme option avancée.

### 2. **Module "Trip" (Voyages)**
- **Problème** :
  - **Trop complexe** : Le module Trip ajoute une couche de complexité avec des `trip_id` sur les notes, tâches, adresses, etc.
  - **Peu utilisé** : La plupart des utilisateurs n’ont pas besoin de gérer des voyages de manière aussi structurée.
  - **Duplication** : Les fonctionnalités de Trip pourraient être gérées via des **tags** ou des **catégories**.
- **Solution** :
  - **Remplacer par des tags** : Ajouter un champ `tags` aux modules existants (ex: `#vacances-ete-2025`).
  - **Ou** : Le désactiver par défaut.

### 3. **Module "Wellbeing" (Bien-être)**
- **Problème** :
  - **Scoping par utilisateur** : Contrairement aux autres modules (scopés par foyer), Wellbeing est **scopé par utilisateur**.
  - **Incohérence** : Cela casse la logique de partage entre membres d’un foyer.
  - **Peu intégré** : Le module est isolé et n’interagit pas avec les autres (ex: pas de lien entre le poids et les recettes).
- **Solution** :
  - **Intégrer dans le profil utilisateur** : Déplacer les données de bien-être dans le modèle `User`.
  - **Ou** : Le supprimer et recommander des apps dédiées (ex: **MyFitnessPal**).

### 4. **Client Mobile Flutter**
- **Problème** :
  - **Non fonctionnel** : Le squelette Flutter (`mobile/`) ne compile pas et n’est pas maintenu.
  - **Doublon** : L’API est déjà prête pour un client mobile, mais le client lui-même n’existe pas.
  - **Complexité** : Maintenir un client Flutter en plus du web est **coûteux en temps**.
- **Solution** :
  - **Supprimer le dossier `mobile/`** et se concentrer sur :
    - Une **PWA** (Progressive Web App) pour une expérience mobile optimisée.
    - Un **client natif** plus tard, si la communauté le demande.

### 5. **Module "Outdoor" (Extérieur)**
- **Problème** :
  - **Trop niche** : Le module Outdoor (plantes, piscine) est utile pour les propriétaires de jardin, mais **peu pertinent pour les citadins**.
  - **Peu intégré** : Pas de lien avec d’autres modules (ex: rappels d’arrosage dans le calendrier).
- **Solution** :
  - **Désactiver par défaut** et le laisser comme option avancée.
  - **Ou** : Le fusionner avec le module **Tasks** (ex: "Arroser les plantes" comme une tâche récurrente).

### 6. **Module "Wine Cellar" (Cave à vin)**
- **Problème** :
  - **Très niche** : Peu d’utilisateurs ont une cave à vin à gérer.
  - **Complexité inutile** : Le module ajoute des modèles (`WineCellar`, `Bottle`) qui ne sont pas essentiels.
- **Solution** :
  - **Supprimer le module** et recommander des apps dédiées (ex: **Vivino**).
  - **Ou** : Le désactiver par défaut.

---

## 🔄 **À refondre (améliorer l’existant)**

### 1. **Module "Budget"**
- **Problème** :
  - **Trop complexe** : Beaucoup de modèles (`BudgetCategory`, `BudgetEntry`, `SavingsEnvelope`, `SharedProject`, `SharedExpense`).
  - **Peu intuitif** : La logique de partage des dépenses entre membres du foyer est confuse.
- **Solution** :
  - **Simplifier** :
    - Fusionner `SharedProject` et `SharedExpense` en un seul modèle `SharedBudget`.
    - Utiliser des **catégories imbriquées** (ex: "Maison > Électricité").
  - **Ajouter des graphiques** pour visualiser les dépenses.

### 2. **Module "Calendar" (Calendrier)**
- **Problème** :
  - **Pas de vue "Semaine"** : Seule la vue "Mois" est disponible.
  - **Événements récurrents complexes** : La logique de récurrence (`Recurrence` service) est difficile à comprendre.
- **Solution** :
  - **Ajouter une vue "Semaine"** et une vue "Jour".
  - **Simplifier la récurrence** :
    - Utiliser un format standard (ex: `RRULE` comme dans iCalendar).
    - Ajouter un **éditeur visuel** pour les récurrences (ex: "Tous les lundis à 14h").

### 3. **Module "Recipes" (Recettes)**
- **Problème** :
  - **Import depuis URL limité** : L’import depuis des URLs ne fonctionne que pour les sites avec du **schema.org/Recipe**.
  - **Pas de recherche par ingrédient** : Impossible de chercher des recettes qui contiennent un ingrédient spécifique.
- **Solution** :
  - **Améliorer l’import** :
    - Ajouter un **scraper** pour les sites populaires (ex: Marmiton, 750g).
    - Permettre l’**import manuel** (copier-coller le texte de la recette).
  - **Ajouter une recherche par ingrédient** :
    - Indexer les ingrédients dans une table dédiée pour une recherche rapide.

### 4. **Module "Shopping" (Courses)**
- **Problème** :
  - **Pas de gestion des quantités** : Impossible de spécifier "2 litres de lait".
  - **Pas de catégories de produits** : Les produits sont tous dans une seule liste.
  - **Pas de prix** : Impossible de suivre le coût des courses.
- **Solution** :
  - **Ajouter des quantités** : Champ `quantity` dans `ShoppingListItem`.
  - **Ajouter des catégories** : Champ `category` dans `Product` (ex: "Fruits", "Légumes", "Produits laitiers").
  - **Ajouter des prix** :
    - Champ `price` dans `ShoppingListItem`.
    - **Calcul automatique du total** de la liste de courses.

### 5. **Module "Tasks" (Tâches)**
- **Problème** :
  - **Pas de sous-tâches** : Impossible de décomposer une tâche en sous-tâches.
  - **Pas de priorité** : Toutes les tâches ont la même importance.
  - **Pas de tags** : Impossible de taguer une tâche (ex: `#urgent`, `#maison`).
- **Solution** :
  - **Ajouter des sous-tâches** : Modèle `Subtask` lié à `Task`.
  - **Ajouter une priorité** : Champ `priority` (ex: "Faible", "Moyenne", "Haute").
  - **Ajouter des tags** : Champ `tags` (array de strings).

### 6. **Module "Fridge" (Frigo)**
- **Problème** :
  - **Pas de suivi des dates de péremption** : Impossible de voir quels aliments vont bientôt périmer.
  - **Pas de quantités** : Impossible de savoir combien de litres de lait il reste.
  - **Pas de lien avec les recettes** : Impossible de voir quelles recettes peuvent être faites avec les ingrédients du frigo.
- **Solution** :
  - **Ajouter des dates de péremption** :
    - Champ `expiry_date` dans `FridgeItem`.
    - **Rappels automatiques** 3 jours avant la péremption.
  - **Ajouter des quantités** : Champ `quantity` dans `FridgeItem`.
  - **Lien avec les recettes** :
    - Bouton **"Quelles recettes puis-je faire ?"** qui filtre les recettes du foyer en fonction des ingrédients du frigo.

### 7. **Module "Messages" (Conversations)**
- **Problème** :
  - **Pas de pièces jointes** : Impossible d’envoyer des photos ou des fichiers.
  - **Pas de réactions** : Impossible de réagir à un message (ex: ❤️, 👍).
  - **Pas de mention (@)** : Impossible de mentionner un autre utilisateur.
- **Solution** :
  - **Ajouter des pièces jointes** : Utiliser `ActiveStorage` pour stocker les fichiers.
  - **Ajouter des réactions** : Modèle `MessageReaction` (comme pour `CirclePostReaction`).
  - **Ajouter des mentions** :
    - Parser le texte des messages pour détecter `@nom_utilisateur`.
    - Envoyer une **notification** à l’utilisateur mentionné.

---
# 📊 **Synthèse des priorités**

| **Catégorie**               | **Priorité** | **Actions**                                                                                     | **Effort** | **Impact** |
|-----------------------------|--------------|------------------------------------------------------------------------------------------------|------------|------------|
| **Sécurité**                | ⭐⭐⭐⭐⭐      | Corriger CSRF, XSS, SQL Injection, ajouter 2FA, limiter la durée des tokens API.               | Moyen      | Élevé      |
| **Performances**            | ⭐⭐⭐⭐       | Optimiser les requêtes N+1, ajouter des index, améliorer le cache.                          | Moyen      | Élevé      |
| **Stabilité**               | ⭐⭐⭐⭐       | Corriger les bugs (Flutter, OAuth, géocodage, PDF).                                            | Élevé      | Élevé      |
| **UX Mobile**               | ⭐⭐⭐⭐       | Ajouter une PWA, optimiser pour mobile, corriger l’accessibilité.                           | Moyen      | Élevé      |
| **Onboarding**              | ⭐⭐⭐         | Simplifier l’onboarding, ajouter un tutoriel.                                                | Faible      | Moyen      |
| **Fonctionnalités manquantes** | ⭐⭐⭐      | Ajouter la synchronisation bancaire, les graphiques budget, les suggestions de recettes.      | Élevé      | Moyen      |
| **Refonte des modules**     | ⭐⭐          | Simplifier Budget, Calendar, Recipes, Shopping, Tasks, Fridge.                               | Élevé      | Moyen      |
| **Suppression de modules**  | ⭐           | Supprimer Circles, Trip, Wellbeing, Wine Cellar, Outdoor (ou les désactiver par défaut).       | Faible      | Faible     |

---

# 🎯 **Recommandations pour la suite**

### 1. **Version 1.0 (Stable)**
- **Objectif** : Rendre Hestia **utilisable en production** par des familles.
- **Actions** :
  1. **Corriger les bugs critiques** (sécurité, stabilité).
  2. **Optimiser les performances** (N+1, cache, index).
  3. **Améliorer l’UX mobile** (PWA, accessibilité).
  4. **Simplifier l’onboarding** (tutoriel, données d’exemple).
  5. **Compléter les traductions** (français et anglais).
  6. **Ajouter une documentation utilisateur** (guide, FAQ).

### 2. **Version 1.1 (Améliorations)**
- **Objectif** : Ajouter des **fonctionnalités utiles** pour les familles.
- **Actions** :
  1. **Synchronisation bancaire** (Plaid/Nordigen).
  2. **Graphiques pour le budget** (Chart.js).
  3. **Suggestions de recettes** (basées sur le frigo).
  4. **Gestion des quantités** (Shopping, Fridge).
  5. **Pièces jointes dans les messages** (ActiveStorage).
  6. **Rappels contextuels** (géolocalisation).

### 3. **Version 2.0 (Refonte)**
- **Objectif** : **Simplifier et moderniser** l’application.
- **Actions** :
  1. **Supprimer les modules inutiles** (Circles, Trip, Wellbeing, Wine Cellar).
  2. **Refondre les modules complexes** (Budget, Calendar, Recipes).
  3. **Ajouter une IA** (suggestions intelligentes, détection de doublons).
  4. **Intégrations externes** (IFTTT, Alexa, Google Assistant).
  5. **Client mobile natif** (si la communauté le demande).

---


# 📝 **Exemple de roadmap pour les 6 prochains mois**

| **Mois** | **Focus**                          | **Livrables**                                                                                     |
|----------|-----------------------------------|---------------------------------------------------------------------------------------------------|
| 1        | **Stabilité et sécurité**         | Correction des bugs critiques, optimisation des performances, ajout du 2FA.                  |
| 2        | **UX et onboarding**              | PWA, tutoriel, données d’exemple, corrections d’accessibilité.                                  |
| 3        | **Fonctionnalités familiales**   | Synchronisation bancaire, graphiques budget, gestion des quantités (Shopping/Fridge).          |
| 4        | **Intégrations et automatisation** | Suggestions de recettes, pièces jointes dans les messages, rappels contextuels.                 |
| 5        | **Refonte des modules**           | Simplification de Budget, Calendar, Recipes. Suppression des modules inutiles.                 |
| 6        | **Préparation de la v2.0**       | Ajout de l’IA (suggestions), intégrations externes (IFTTT), client mobile (si ressources).      |

---
# 🔍 **Analyse SWOT (pour résumer)**

| **Forces (Strengths)**                          | **Faiblesses (Weaknesses)**                          |
|------------------------------------------------|------------------------------------------------------|
| ✅ Architecture technique solide (Rails 8, PostgreSQL, Hotwire). | ❌ Bugs critiques (Flutter, OAuth, géocodage).        |
| ✅ 25 modules couvrant tous les besoins familiaux. | ❌ Performances à améliorer (N+1, cache).            |
| ✅ Open-source (AGPLv3) et auto-hébergeable.     | ❌ Sécurité perfectible (CSRF, XSS, 2FA).             |
| ✅ Design system cohérent et réutilisable.       | ❌ UX mobile non optimisée (pas de PWA).             |
| ✅ API prête pour le mobile et l’IA.             | ❌ Onboarding complexe.                              |
| ✅ Communauté active (300+ tests, CI/CD).       | ❌ Traductions incomplètes.                          |

| **Opportunités (Opportunities)**               | **Menaces (Threats)**                                |
|------------------------------------------------|------------------------------------------------------|
| 🚀 Ajout de fonctionnalités familiales (budget, recettes). | ⚠️ Concurrence des apps freemium (Todoist, Notion). |
| 🚀 Intégrations externes (IFTTT, Alexa, banques). | ⚠️ Complexité de maintenance (25 modules).          |
| 🚀 IA pour des suggestions intelligentes.       | ⚠️ Risque de fragmentation (trop de modules).      |
| 🚀 Client mobile natif.                         | ⚠️ Dépendance à des APIs externes (Open Food Facts).|
| 🚀 Partenariats avec des associations familiales. | ⚠️ RGPD et confidentialité des données.          |

---

# 💡 **Conclusion : Mon avis d’utilisateur lambda**

**Hestia est un projet ambitieux et prometteur**, mais **trop complexe pour un utilisateur moyen**.
En tant que père de famille avec 2 enfants, un budget serré et peu de temps, voici ce que je retiens :

### ✅ **Ce que j’adore** :
- **Tout est au même endroit** : Plus besoin de jongler entre 10 apps différentes (Todoist pour les tâches, Google Calendar pour les événements, YNAB pour le budget, etc.).
- **Open-source et gratuit** : Pas de risque de voir mes données vendues ou l’app devenir payante.
- **Auto-hébergement** : Je peux installer Hestia sur mon Raspberry Pi et garder le contrôle total.
- **Design moderne** : L’interface est belle et intuitive (même si perfectible).

### ❌ **Ce qui me bloque** :
- **Trop de modules** : Je n’ai pas besoin de gérer une cave à vin ou des cercles sociaux. **25 modules, c’est trop**.
- **Bugs et fonctionnalités incomplètes** : La synchronisation calendrier externe ne marche pas, le client mobile est inutilisable.
- **Lent sur mobile** : Sans PWA, l’expérience sur téléphone est médiocre.
- **Complexité** : L’onboarding est trop long, et je ne sais pas par où commencer.

### 🔧 **Ce que je ferais si j’étais le maintainer** :
1. **Simplifier** :
   - Garder **10 modules essentiels** (Courses, Frigo, Recettes, Tâches, Calendrier, Budget, Notes, Contacts, Messages, Documents).
   - Supprimer ou désactiver par défaut les modules niche (Circles, Trip, Wellbeing, Wine Cellar, Outdoor).
2. **Corriger les bugs** :
   - Priorité à la **sécurité** (2FA, CSRF, XSS) et à la **stabilité** (OAuth, géocodage, PDF).
3. **Optimiser pour le mobile** :
   - Ajouter une **PWA** pour une expérience app-like.
   - Simplifier l’interface pour les petits écrans.
4. **Ajouter des fonctionnalités utiles** :
   - **Synchronisation bancaire** (pour le budget).
   - **Suggestions de recettes** (basées sur le frigo).
   - **Gestion des quantités** (pour les courses).
5. **Améliorer l’onboarding** :
   - **Tutoriel guidé** au premier lancement.
   - **Données d’exemple** pour comprendre comment ça marche.

---

# 📌 **Résumé en 3 mots**
**Hestia = "Tout-en-un, mais trop."**
→ **Simplifiez, stabilisez, puis étendez.**