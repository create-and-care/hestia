
# 🏠 **Analyse Complète du Projet Hestia**
*Une application open-source de gestion de foyer auto-hébergeable*

---

## 📌 **Présentation du Projet**
**Hestia** est une alternative **gratuite, open-source (AGPLv3) et auto-hébergeable** aux applications freemium comme **Todoist, Notion, Google Calendar ou YNAB**.
Elle centralise **25 modules** pour gérer :
- **La vie quotidienne** (courses, frigo, recettes, tâches, calendrier, routines).
- **La maison** (notes, adresses, prestataires, véhicules, cave à vin, déchets, documents, extérieur, budget).
- **La famille** (anniversaires, bébé, animaux, bien-être).
- **Le social** (messages, fidélité, cadeaux, cercles, voyages).

**Stack technique** :
- Backend : **Rails 8.1** + **PostgreSQL**.
- Frontend : **Hotwire (Turbo + Stimulus)** + **Tailwind v4**.
- Temps réel : **Solid Cable** (WebSockets sur PostgreSQL).
- Jobs : **Solid Queue** (sur PostgreSQL).
- Cache : **Solid Cache** (sur PostgreSQL).
- Mobile : **Flutter (skeleton non fonctionnel)**.
- Déploiement : **Docker/Kamal**.

**Points clés** :
- **Pas de dépendance à Redis** → Auto-hébergement simplifié (1 seul service : PostgreSQL).
- **API REST versionnée** (`api/v1`) pour le mobile et l’IA (Hest.AI).
- **Design system cohérent** (~50 composants UI réutilisables).
- **Multi-langues** (Français, Anglais).
- **CI/CD complète** (tests, linting, sécurité).

---

# ✅ **Points Forts (Ce qui marche bien)**

---

## 1. **Architecture Technique Solide**
| **Aspect**               | **Détails**                                                                                     | **Impact**                          |
|--------------------------|-------------------------------------------------------------------------------------------------|-------------------------------------|
| **Stack moderne**        | Rails 8.1 + PostgreSQL + Hotwire + Tailwind v4.                                                 | Performant, scalable, maintenable. |
| **Pas de Redis**         | Solid Queue/Cable/Cache tournent sur PostgreSQL.                                               | Auto-hébergement simplifié.        |
| **Docker/Kamal**         | Déploiement facile pour les non-experts.                                                      | Accessible aux débutants.          |
| **CI/CD complète**       | Tests (Minitest + Capybara), linting (RuboCop), sécurité (Brakeman, Bundler Audit).              | Code fiable et sécurisé.           |
| **API versionnée**       | Prête pour le mobile (Flutter) et l’IA (Hest.AI).                                               | Extensible.                         |
| **Design system**        | ~50 composants UI réutilisables (shadcn-style).                                                | Cohérence visuelle.                |

---

## 2. **Fonctionnalités Complètes**
**25 modules** couvrant tous les aspects du quotidien :
- **Quotidien** : Shopping, Fridge, Recipes, Menu, Tasks, Calendar, Routines.
- **Maison** : Notes, Addresses, Service Providers, Vehicles, Wine Cellar, Waste, Documents, Outdoor, Budget.
- **Famille** : Birthdays (Contacts), Baby, Pets, Wellbeing.
- **Social** : Messages (Conversations), Loyalty, Gifts, Circles, Trips.

**Fonctionnalités avancées** :
- Recherche globale (across tous les modules).
- Notifications (rappels, digest quotidien).
- Export PDF (listes de courses, calendrier).
- Géocodage (Nominatim pour les adresses).
- Open Food Facts (recherche de produits par code-barres).
- Synchronisation calendrier externe (Google, Microsoft, CalDAV).
- Catalogues (marques de fidélité, fiches de soins des plantes).

---

## 3. **Expérience Utilisateur (UX)**
- **Design system** : Composants réutilisables (`Ui::ButtonComponent`, `Ui::CardComponent`, etc.).
- **Navigation intuitive** : Sidebar groupée (Quotidien, Maison, Famille, Social).
- **Modules activables/désactivables** : Personnalisation de l’interface.
- **Temps réel** : Mises à jour instantanées (ex: ajout d’un produit dans la liste de courses).
- **Multi-langues** : Français et Anglais (fichiers YAML bien structurés).

---
## 4. **Sécurité et Confidentialité**
- **Chiffrement** : Tokens OAuth (calendrier externe) chiffrés en base.
- **AGPLv3** : 100% open-source, pas de features payantes.
- **Gestion des sessions** : Revocation des sessions actives, tokens API (HMAC-SHA256).
- **Protection CSRF** : Activée par défaut dans Rails.

---
## 5. **Documentation**
- **README.md** : Clairs, exemples de commandes Docker.
- **CONTRIBUTING.md** : Guide pour les contributeurs (conventions, tests).
- **CHANGELOG.md** : Historique détaillé des versions.
- **Roadmap intégrée** (`/roadmap`) : Suivi des fonctionnalités en temps réel.

---

# ❌ **Points Faibles (ce qui pose problème)**

## 🔴 **Problèmes Critiques (À corriger en priorité)**

### 1. **Performances et Scalabilité**
| **Problème**               | **Impact**                                                                                     | **Solution**                                                                                     |
|----------------------------|------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------|
| **Requêtes N+1**           | Ralentissement des pages avec beaucoup d’associations (ex: dashboard).                     | Utiliser `includes` ou `preload` dans les contrôleurs. Ajouter la gem `bullet`.               |
| **Chargement des assets**  | Tailwind v4 en beta, pas de code splitting pour le JavaScript.                                | Utiliser `importmap-rails` ou `esbuild` pour le code splitting.                                |
| **Base de données**        | 120 migrations, index manquants, colonnes inutiles.                                           | Ajouter des index sur les colonnes fréquemment interrogées (`user_id`, `household_id`).      |
| **Jobs Solid Queue**       | Pas de priorisation (tous les jobs sont traités en FIFO).                                    | Utiliser `priority` dans les jobs critiques (ex: notifications).                              |

### 2. **Sécurité**
| **Problème**               | **Risque**                                                                                     | **Solution**                                                                                     |
|----------------------------|------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------|
| **CSRF**                   | Attaques CSRF si l’utilisateur est connecté sur un site malveillant.                          | Vérifier que `protect_from_forgery` est activé dans `ApplicationController`.                  |
| **XSS**                    | Certaines vues utilisent `raw` ou `html_safe` sans sanitization.                           | Utiliser `sanitize` ou `ActionView::Helpers::SanitizeHelper`.                                  |
| **SQL Injection**          | Certaines requêtes utilisent des interpolations de strings.                                | Utiliser `where(name: params[:name])` ou `sanitize_sql`.                                       |
| **Authentification**       | Pas de 2FA.                                                                                   | Intégrer `devise-two-factor` ou `rotp`.                                                          |
| **Tokens API**             | Pas de limite de durée de vie.                                                                | Ajouter un `expires_at` et un mécanisme de rotation.                                          |

### 3. **Stabilité et Bugs**
| **Problème**               | **Impact**                                                                                     | **Solution**                                                                                     |
|----------------------------|------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------|
| **Flutter Mobile**         | Squelette non fonctionnel (pas de SDK Flutter dans l’environnement).                          | Soit supprimer le dossier `mobile/`, soit le rendre fonctionnel.                              |
| **Synchronisation calendrier externe** | OAuth non implémenté (Google/Microsoft/CalDAV).                                              | Implémenter OAuth avec `omniauth-google`, `omniauth-microsoft`, ou masquer la fonctionnalité.   |
| **Géocodage (Nominatim)**  | Pas de cache → risque de limite de requêtes.                                                  | Cacher les résultats dans `Solid Cache` ou PostgreSQL.                                         |
| **Open Food Facts**        | Pas de fallback si l’API est down.                                                           | Ajouter un cache local ou un fallback vers une base de données interne.                      |
| **PDF Export**             | Prawn peut planter avec des caractères spéciaux (UTF-8).                                      | Utiliser `wicked_pdf` (basé sur wkhtmltopdf).                                                  |

### 4. **Expérience Utilisateur (UX)**
| **Problème**               | **Impact**                                                                                     | **Solution**                                                                                     |
|----------------------------|------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------|
| **Onboarding complexe**    | Trop d’étapes → risque d’abandon.                                                             | Ajouter un tutoriel guidé et pré-remplir des données d’exemple.                               |
| **Mobile non optimisé**    | Pas de PWA → expérience médiocre sur téléphone.                                               | Activer les lignes commentées dans `config/routes.rb` pour la PWA. Ajouter `manifest.json`.   |
| **Notifications intrusives** | Pas de contrôle fin (tout ou rien).                                                          | Permettre de configurer les notifications **par module**.                                     |
| **Recherche globale lente** | La recherche across tous les modules peut être lente.                                        | Ajouter un index full-text sur les colonnes pertinentes. Utiliser PostgreSQL `tsvector`.      |
| **Accessibilité (a11y)**   | Manque de labels, contraste des couleurs insuffisant.                                       | Utiliser `axe-core` pour auditer l’accessibilité. Corriger les contrastes avec Tailwind.      |

---
### 5. **Internationalisation (i18n)**
| **Problème**               | **Impact**                                                                                     | **Solution**                                                                                     |
|----------------------------|------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------|
| **Traductions incomplètes** | Certains modules n’ont pas de traduction française (ex: `waste`, `outdoor`).                | Compléter les fichiers de traduction pour tous les modules.                                   |
| **Dates et nombres**       | Formatage non localisé (ex: `MM/DD/YYYY` en français).                                         | Utiliser `I18n.l` systématiquement pour les dates.                                             |

---
### 6. **Gestion des Erreurs**
| **Problème**               | **Impact**                                                                                     | **Solution**                                                                                     |
|----------------------------|------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------|
| **Messages d’erreur peu clairs** | Exemple : "Une erreur est survenue" pour un doublon dans la liste de courses.                | Personnaliser les messages d’erreur pour chaque cas.                                         |
| **500 Errors non gérées**  | L’utilisateur voit une page blanche ou un stack trace.                                         | Créer une page `500.html.erb` personnalisée. Utiliser `rescue_from` dans `ApplicationController`. |

---
### 7. **Documentation Utilisateur**
| **Problème**               | **Impact**                                                                                     | **Solution**                                                                                     |
|----------------------------|------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------|
| **Pas de guide utilisateur** | L’utilisateur ne sait pas comment utiliser les modules avancés (ex: budget, routines).      | Ajouter une section "Aide" dans le menu. Créer des vidéos tutoriels ou des GIFs animés.       |
| **Roadmap peu visible**    | La roadmap est accessible via `/roadmap`, mais pas de lien dans le menu principal.          | Ajouter un lien "Roadmap" dans le footer ou le menu utilisateur.                              |

---

# 🟡 **Opportunités d’Amélioration (Non critiques mais utiles)**

---

## 🚀 **Fonctionnalités Manquantes (Pour une famille)**

---

### 1. **Gestion des Repas**
| **Idée**                          | **Bénéfice**                                                                                     | **Implémentation**                                                                              |
|-----------------------------------|-------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------|
| **Suggestions de recettes**       | Proposer des recettes basées sur les ingrédients disponibles dans le frigo.                 | Ajouter un bouton "Suggérer des recettes" dans le module Menu. Intégrer Spoonacular API.       |
| **Listes de courses automatiques** | Ajouter automatiquement les ingrédients manquants à la liste de courses.                     | Bouton "Ajouter les ingrédients manquants" dans le module Menu.                              |

---
### 2. **Budget et Finances**
| **Idée**                          | **Bénéfice**                                                                                     | **Implémentation**                                                                              |
|-----------------------------------|-------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------|
| **Synchronisation bancaire**     | Importer automatiquement les transactions bancaires.                                         | Intégrer Plaid ou Nordigen API. Alternative open-source : Firefly III.                        |
| **Visualisation graphique**      | Voir les dépenses sous forme de camembert ou histogramme.                                     | Ajouter Chart.js ou D3.js. Permettre de comparer les dépenses mois par mois.                 |
| **Rappels de paiements**          | Rappeler les factures récurrentes (électricité, loyer, etc.).                                   | Ajouter un module "Factures" avec des rappels automatiques.                                  |

---
### 3. **Santé et Bien-être**
| **Idée**                          | **Bénéfice**                                                                                     | **Implémentation**                                                                              |
|-----------------------------------|-------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------|
| **Suivi médical**                | Suivre les médicaments, cycles menstruels, vaccins.                                           | Étendre le module Wellbeing ou créer un module "Santé" dédié.                                |
| **Allergies et intolérances**     | Filtrer les recettes contenant des allergènes.                                               | Ajouter un profil santé pour chaque utilisateur. Filtrer les recettes en conséquence.       |

---
### 4. **Éducation et Enfants**
| **Idée**                          | **Bénéfice**                                                                                     | **Implémentation**                                                                              |
|-----------------------------------|-------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------|
| **Suivi scolaire**                | Suivre les notes, devoirs, activités extrascolaires.                                          | Ajouter un module "École" avec calendrier des devoirs et suivi des notes.                   |
| **Temps d’écran**                 | Limiter ou suivre le temps d’écran des enfants.                                               | Intégrer un minuteur dans le module Tasks. Alternative : module "Parental Control".            |

---
### 5. **Maison et Logistique**
| **Idée**                          | **Bénéfice**                                                                                     | **Implémentation**                                                                              |
|-----------------------------------|-------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------|
| **Inventaire des biens**          | Suivre les objets de la maison (meubles, électroménager) pour l’assurance ou la revente.       | Ajouter un module "Inventaire" avec photos, valeur estimée, date d’achat.                   |
| **Maintenance de la maison**      | Suivre l’entretien de la chaudière, climatisation, etc.                                       | Étendre le module Service Providers pour inclure les prestataires de maintenance.          |

---
### 6. **Social et Partage**
| **Idée**                          | **Bénéfice**                                                                                     | **Implémentation**                                                                              |
|-----------------------------------|-------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------|
| **Partage externe sécurisé**     | Partager des listes de cadeaux avec un mot de passe et une date d’expiration.                 | Ajouter un mot de passe et une date d’expiration pour les liens publics (module Gifts).       |
| **Collaboration avec des invités** | Inviter des personnes sans compte Hestia (ex: un parent qui veut voir la liste de courses). | Ajouter un mode "invité" avec un lien temporaire (ex: 24h).                                   |

---
### 7. **Automatisation et IA**
| **Idée**                          | **Bénéfice**                                                                                     | **Implémentation**                                                                              |
|-----------------------------------|-------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------|
| **Suggestions intelligentes**     | Suggérer des produits basés sur l’historique des achats.                                       | Utiliser l’historique des achats pour suggérer des produits.                                  |
| **Détection des doublons**        | Éviter d’ajouter plusieurs fois le même produit dans la liste de courses.                     | Ajouter une détection automatique des doublons (ex: "Lait" et "lait" = même produit).       |
| **Rappels contextuels**           | Rappeler d’acheter du lait quand on passe près du supermarché.                                | Utiliser la géolocalisation (si l’utilisateur l’autorise).                                   |

---
### 8. **Intégrations Externes**
| **Idée**                          | **Bénéfice**                                                                                     | **Implémentation**                                                                              |
|-----------------------------------|-------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------|
| **IFTTT/Zapier**                  | Automatiser des tâches (ex: "Si un nouvel événement est ajouté dans Google Calendar, crée-le dans Hestia"). | Créer une API webhook pour recevoir des événements externes. Documenter Zapier.             |
| **Alexa/Google Assistant**        | Ajouter des éléments à la liste de courses via la voix.                                       | Créer une skill Alexa ou une action Google Assistant.                                        |
| **Calendrier scolaire**           | Intégrer les calendriers scolaires (zones A/B/C en France).                                    | Ajouter un calendrier scolaire pré-rempli via une API comme Education Nationale.            |

---
### 9. **Personnalisation**
| **Idée**                          | **Bénéfice**                                                                                     | **Implémentation**                                                                              |
|-----------------------------------|-------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------|
| **Thèmes personnalisés**          | Choisir des couleurs personnalisées ou des thèmes prédéfinis.                                  | Permettre de choisir des couleurs via CSS variables. Ajouter des thèmes prédéfinis.         |
| **Disposition des modules**       | Réorganiser les modules via glisser-déposer.                                                  | Sauvegarder la disposition par utilisateur.                                                  |
| **Langues supplémentaires**      | Ajouter l’espagnol, l’allemand, l’italien.                                                     | Utiliser Crowdin ou Transifex pour la traduction collaborative.                           |

---
### 10. **Analytique et Insights**
| **Idée**                          | **Bénéfice**                                                                                     | **Implémentation**                                                                              |
|-----------------------------------|-------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------|
| **Statistiques d’utilisation**    | Voir quels modules sont les plus utilisés.                                                     | Ajouter un tableau de bord d’analytique. Anonymiser les données.                              |
| **Historique des modifications**  | Voir qui a modifié une tâche ou une liste de courses.                                         | Ajouter un historique des changements avec Paper Trail.                                       |

---

# 🗑️ **Suggestions de Suppression ou de Refonte**

---

## ❌ **À Supprimer (ou à désactiver par défaut)**

---

### 1. **Module "Circles" (Cercles)**
| **Problème**               | **Solution**                                                                                     |
|----------------------------|-------------------------------------------------------------------------------------------------|
| Architecture complexe (indépendante des foyers). | Supprimer le module et intégrer ses fonctionnalités dans **Messages** ou **Gifts**.          |
| Peu utile pour la plupart des utilisateurs.     | Désactiver par défaut et le laisser comme option avancée.                                    |

---
### 2. **Module "Trip" (Voyages)**
| **Problème**               | **Solution**                                                                                     |
|----------------------------|-------------------------------------------------------------------------------------------------|
| Trop complexe (ajoute des `trip_id` sur les notes, tâches, etc.). | Remplacer par des **tags** (ex: `#vacances-ete-2025`).                                         |
| Peu utilisé.               | Désactiver par défaut.                                                                         |

---
### 3. **Module "Wellbeing" (Bien-être)**
| **Problème**               | **Solution**                                                                                     |
|----------------------------|-------------------------------------------------------------------------------------------------|
| Scoping par utilisateur (incohérent avec les autres modules). | Intégrer dans le **profil utilisateur** ou supprimer.                                         |
| Peu intégré avec les autres modules.          | Recommander des apps dédiées (ex: MyFitnessPal).                                              |

---
### 4. **Client Mobile Flutter**
| **Problème**               | **Solution**                                                                                     |
|----------------------------|-------------------------------------------------------------------------------------------------|
| Non fonctionnel (skelette). | **Supprimer le dossier `mobile/`** et se concentrer sur une **PWA**.                          |
| Doublon avec l’API.        | L’API est déjà prête pour un client mobile futur.                                            |

---
### 5. **Module "Outdoor" (Extérieur)**
| **Problème**               | **Solution**                                                                                     |
|----------------------------|-------------------------------------------------------------------------------------------------|
| Trop niche (jardin, piscine). | Désactiver par défaut.                                                                         |
| Peu intégré.               | Fusionner avec le module **Tasks** (ex: "Arroser les plantes" comme une tâche récurrente).     |

---
### 6. **Module "Wine Cellar" (Cave à vin)**
| **Problème**               | **Solution**                                                                                     |
|----------------------------|-------------------------------------------------------------------------------------------------|
| Très niche.                | **Supprimer le module** et recommander des apps dédiées (ex: Vivino).                        |
| Complexité inutile.        | Désactiver par défaut.                                                                         |

---

## 🔄 **À Refondre (Améliorer l’existant)**

---

### 1. **Module "Budget"**
| **Problème**               | **Solution**                                                                                     |
|----------------------------|-------------------------------------------------------------------------------------------------|
| Trop complexe (beaucoup de modèles). | Simplifier : fusionner `SharedProject` et `SharedExpense` en `SharedBudget`.                     |
| Peu intuitif.              | Utiliser des **catégories imbriquées** (ex: "Maison > Électricité").                          |
| Manque de visualisation.   | Ajouter des **graphiques** (Chart.js).                                                        |

---
### 2. **Module "Calendar" (Calendrier)**
| **Problème**               | **Solution**                                                                                     |
|----------------------------|-------------------------------------------------------------------------------------------------|
| Pas de vue "Semaine".      | Ajouter une vue **Semaine** et une vue **Jour**.                                               |
| Événements récurrents complexes. | Simplifier la récurrence : utiliser le format **RRULE** (iCalendar). Ajouter un éditeur visuel. |

---
### 3. **Module "Recipes" (Recettes)**
| **Problème**               | **Solution**                                                                                     |
|----------------------------|-------------------------------------------------------------------------------------------------|
| Import depuis URL limité.  | Améliorer l’import : ajouter un **scraper** pour Marmiton/750g. Permettre l’import manuel.     |
| Pas de recherche par ingrédient. | Indexer les ingrédients dans une table dédiée pour une recherche rapide.                     |

---
### 4. **Module "Shopping" (Courses)**
| **Problème**               | **Solution**                                                                                     |
|----------------------------|-------------------------------------------------------------------------------------------------|
| Pas de gestion des quantités. | Ajouter un champ `quantity` dans `ShoppingListItem`.                                          |
| Pas de catégories de produits. | Ajouter un champ `category` dans `Product`.                                                   |
| Pas de prix.               | Ajouter un champ `price` dans `ShoppingListItem`. Calculer le **total automatique**.          |

---
### 5. **Module "Tasks" (Tâches)**
| **Problème**               | **Solution**                                                                                     |
|----------------------------|-------------------------------------------------------------------------------------------------|
| Pas de sous-tâches.        | Ajouter un modèle `Subtask` lié à `Task`.                                                      |
| Pas de priorité.           | Ajouter un champ `priority` ("Faible", "Moyenne", "Haute").                                    |
| Pas de tags.               | Ajouter un champ `tags` (array de strings).                                                    |

---
### 6. **Module "Fridge" (Frigo)**
| **Problème**               | **Solution**                                                                                     |
|----------------------------|-------------------------------------------------------------------------------------------------|
| Pas de suivi des dates de péremption. | Ajouter un champ `expiry_date` dans `FridgeItem`. Rappels automatiques 3 jours avant.          |
| Pas de quantités.          | Ajouter un champ `quantity` dans `FridgeItem`.                                                 |
| Pas de lien avec les recettes. | Bouton **"Quelles recettes puis-je faire ?"** qui filtre les recettes du foyer.               |

---
### 7. **Module "Messages" (Conversations)**
| **Problème**               | **Solution**                                                                                     |
|----------------------------|-------------------------------------------------------------------------------------------------|
| Pas de pièces jointes.     | Utiliser `ActiveStorage` pour stocker les fichiers.                                           |
| Pas de réactions.          | Ajouter un modèle `MessageReaction` (comme pour `CirclePostReaction`).                         |
| Pas de mentions (@).       | Parser le texte des messages pour détecter `@nom_utilisateur`. Envoyer une notification.    |

---

# 🔍 **Analyse Spécifique : Les Modules Désactivables**

---

## ✅ **Pourquoi les modules désactivables sont UTILES (et même nécessaires)**

---

### 1. **Expérience Utilisateur (UX) : Éviter la surcharge cognitive**
- **Problème** : Avec **25 modules**, un utilisateur lambda se sent **submergé**.
  - **Exemple** : Un parent n’a pas besoin de gérer une **cave à vin**, des **cercles sociaux**, ou des **voyages organisés**.
  - **Conséquence** : Il abandonne l’app parce qu’elle semble trop complexe.
- **Solution** : La désactivation permet de **personnaliser l’interface** pour ne garder que ce qui est utile.
  → **Moins de modules = moins de distraction = plus d’adoption**.

- **Preuves** :
  - **Notion** et **ClickUp** permettent de masquer les fonctionnalités inutiles.
  - **Trello** a simplifié son interface en cachant les options avancées par défaut.

---
### 2. **Performances : Réduire la charge inutile**
- **Impact technique** :
  - Même si un module est désactivé, son **code reste chargé** (modèles, contrôleurs, vues, migrations).
  - **Exemple** : Si un utilisateur désactive **Wine Cellar**, les modèles `WineCellar` et `Bottle` sont toujours initialisés par Rails.
  - **Problème** : Cela ralentit le **boot time** de l’app et consomme de la mémoire inutilement.
- **Solution idéale** (mais complexe) :
  - **Chargement dynamique** : Ne charger que les modules activés (via `require_dependency` ou un système de plugins).
  - **Exemple** : Comme **Discourse** (forum open-source) qui charge les plugins à la demande.

---
### 3. **Maintenabilité : Réduire la complexité perçue**
- **Pour les contributeurs** :
  - Un nouveau développeur peut se concentrer sur **1 ou 2 modules** sans avoir à comprendre les 25.
- **Pour les maintainers** :
  - Moins de modules **activés par défaut** = moins de bugs à corriger en urgence.
  - **Priorisation** : On peut se concentrer sur les modules **les plus utilisés** (ex: Shopping, Tasks, Calendar).

---
### 4. **Flexibilité : S’adapter à tous les cas d’usage**
| **Cas d’usage**          | **Modules utiles**                                                                 | **Modules inutiles**                          |
|--------------------------|------------------------------------------------------------------------------------|-----------------------------------------------|
| **Famille classique**    | Shopping, Fridge, Recipes, Tasks, Calendar, Budget, Notes, Contacts, Messages.   | Wine Cellar, Outdoor, Circles, Trip, Wellbeing.|
| **Colocataires**          | Shopping, Tasks, Calendar, Budget, Messages.                                     | Baby, Wellbeing, Pets, Vehicles.              |
| **Personnes âgées**      | Calendar, Contacts, Notes, Tasks.                                               | Budget, Baby, Wellbeing, Outdoor.            |
| **Voyageurs**            | Trip, Addresses, Tasks, Calendar, Notes.                                         | Wine Cellar, Baby, Wellbeing.                |

→ **Sans désactivation, Hestia serait trop générique et peu adaptée à chaque cas d’usage.**

---
### 5. **Marketing : Cibler différents personas**
- **Argument de vente** :
  - *"Hestia s’adapte à VOS besoins : activez uniquement les modules qui vous intéressent !"*
  - Cela permet de **cibler plusieurs audiences** avec le même produit.

---

## ❌ **Les Limites de la Désactivation Actuelle dans Hestia**

---

### 1. **Désactivation = Masquage Visuel Uniquement**
- **Problème** :
  - Dans Hestia, désactiver un module **ne fait que le cacher dans la sidebar** (via `module_enabled?` dans `SidebarHelper`).
  - **Le code reste chargé** :
    - Les **migrations** sont toujours exécutées (ex: `CreateWineCellars`).
    - Les **modèles** sont toujours chargés (ex: `WineCellar`, `Bottle`).
    - Les **contrôleurs** et **vues** sont toujours accessibles via URL (ex: `/wine_cellars`).
    - Les **jobs** et **services** liés au module sont toujours actifs.
- **Exemple concret** :
  - Si un utilisateur désactive **Wine Cellar**, il ne verra plus le lien dans la sidebar, mais :
    - Il peut toujours accéder à `/wine_cellars` en tapant l’URL.
    - Les **migrations** `CreateWineCellars` et `CreateBottles` ont déjà été exécutées sur sa base de données.
    - Les **validations** dans `WineCellar` (ex: `validates :name, presence: true`) sont toujours vérifiées.

---
### 2. **Pas de Gain de Performance Réel**
- **Impact** :
  - **Boot time** : Rails charge tous les modèles au démarrage, même ceux des modules désactivés.
  - **Mémoire** : Tous les modèles sont en mémoire (ex: `WineCellar`, `Bottle`, `Plant`, etc.).
  - **Requêtes SQL** : Les tables des modules désactivés sont toujours interrogées (ex: `SELECT * FROM wine_cellars` si une requête les inclut).

---
### 3. **Complexité Accrue pour les Développeurs**
- **Problème** :
  - Chaque module doit **vérifier `module_enabled?`** avant d’afficher quoi que ce soit.
  - **Risque** : Oublier cette vérification dans un contrôleur ou une vue → **accès non autorisé**.
- **Solution** :
  - **Centraliser la vérification** dans un `before_action` global (ex: dans `ApplicationController`).

---
### 4. **Problèmes de Données**
- **Problème 1 : Données orphelines** :
  - Si un utilisateur **désactive un module**, puis le **réactive plus tard**, ses données sont toujours là.
  - **C’est bien** (pas de perte de données), mais **peu intuitif** (l’utilisateur s’attend à ce que le module soit "vide" après réactivation).
- **Problème 2 : Suppression de données** :
  - Si un utilisateur veut **supprimer définitivement** un module (et ses données), il n’y a pas de mécanisme pour ça.

---

## 🔧 **Comment Améliorer la Désactivation des Modules dans Hestia ?**

---

### 1. **Rendre la Désactivation VRAIMENT Efficace**
| **Niveau**               | **Description**                                                                 | **Complexité** | **Impact** |
|--------------------------|---------------------------------------------------------------------------------|----------------|------------|
| **Niveau 1 (Actuel)**    | Masquage dans la sidebar (via `module_enabled?`).                              | Faible         | Faible     |
| **Niveau 2**             | Bloquer l’accès aux routes des modules désactivés (via `before_action`).      | Moyen          | Moyen      |
| **Niveau 3**             | Ne pas charger les modèles/contrôleurs des modules désactivés (via `autoload`). | Élevé          | Élevé      |
| **Niveau 4**             | Désinstaller les migrations des modules désactivés (via un système de plugins). | Très élevé     | Très élevé |

- **Recommandation** :
  - **Cibler le Niveau 2** (bloquer l’accès aux routes) en priorité.
  - **Exemple de code** :
    ```ruby
    # app/controllers/application_controller.rb
    before_action :check_module_access

    private

    def check_module_access
      return unless respond_to?(:module_key) # Définir module_key dans chaque contrôleur
      return if current_household.module_enabled?(module_key)

      redirect_to root_path, alert: t("errors.module_disabled")
    end
    ```
    ```ruby
    # app/controllers/wine_cellars_controller.rb
    def module_key
      :wine_cellar
    end
    ```

---
### 2. **Ajouter une Option "Supprimer les Données du Module"**
- **Fonctionnalité** :
  - Dans les paramètres du foyer, ajouter un bouton **"Réinitialiser le module"** pour chaque module désactivable.
  - **Comportement** :
    - Supprime **toutes les données** liées au module (ex: `WineCellar.destroy_all` pour le foyer).
    - **Avertissement** : "Cette action est irréversible. Toutes les données seront supprimées."
- **Exemple d’interface** :
  ```
  Module : Cave à vin
  [✓] Activé  [×] Désactivé  [🗑️] Supprimer les données
  ```

---
### 3. **Optimiser le Chargement des Modules**
- **Solution 1 : Chargement dynamique avec `autoload`**
  - Déplacer les modèles des modules optionnels dans `app/models/optional/`.
  - **Avantage** : Les modèles ne sont chargés que lorsqu’ils sont utilisés.
  - **Inconvénient** : Complexe à maintenir (risque de `LoadError` si mal configuré).

- **Solution 2 : Utiliser des Gems Séparées**
  - Chaque module optionnel devient une **gem Rails** (ex: `hestia-wine_cellar`).
  - **Avantage** :
    - Chargement **à la demande** (via `Bundler.require`).
    - Possibilité de **désinstaller** complètement un module.
  - **Inconvénient** :
    - **Très complexe** à implémenter (nécessite de refactorer tout le code).
    - **Maintenance lourde** (chaque module doit être une gem indépendante).

---
### 4. **Améliorer l’UX de la Désactivation**
- **Problème actuel** :
  - La désactivation se fait dans **les paramètres du foyer** (`households#show`), mais ce n’est pas intuitif.
- **Solutions** :
  1. **Ajouter un bouton "Personnaliser la sidebar"** dans la sidebar elle-même.
     - **Exemple** :
       ```
       [⚙️] Personnaliser la sidebar
       ```
     - Ouvre un modal avec la liste des modules (coché = activé, décoché = désactivé).
  2. **Ajouter une description pour chaque module** :
     - **Exemple** :
       ```
       [✓] Shopping : Gestion des listes de courses et du catalogue de produits.
       [✓] Fridge : Suivi des aliments dans votre frigo et de leurs dates de péremption.
       [×] Wine Cellar : Gestion de votre cave à vin (pour les amateurs).
       ```
  3. **Permettre de désactiver des groupes entiers** :
     - **Exemple** :
       ```
       [✓] Quotidien (Shopping, Fridge, Recipes, Menu, Tasks, Calendar, Routines)
       [✓] Maison (Notes, Addresses, Service Providers, Vehicles, Wine Cellar, Waste, Documents, Outdoor, Budget)
       [×] Famille (Birthdays, Baby, Pets, Wellbeing)
       [×] Social (Messages, Loyalty, Gifts, Circles, Trips)
       ```

---

## 📊 **Benchmark : Comment Font les Autres Apps ?**

| **App**          | **Modules Désactivables ?** | **Mécanisme**                                                                 | **Impact sur les Performances** |
|------------------|----------------------------|-------------------------------------------------------------------------------|---------------------------------|
| **Notion**       | ✅ Oui                     | Masquage dans la sidebar + désactivation des fonctionnalités avancées.     | Faible (tout est chargé).       |
| **ClickUp**      | ✅ Oui                     | "Custom Views" : l’utilisateur choisit quelles fonctionnalités afficher.   | Moyen (chargement dynamique).  |
| **Trello**       | ❌ Non                     | Pas de désactivation, mais une interface minimaliste par défaut.            | Aucun.                          |
| **Jira**         | ✅ Oui (via plugins)       | Architecture modulaire : chaque fonctionnalité est un plugin.             | Élevé (chargement à la demande).|
| **Discourse**    | ✅ Oui (via plugins)       | Système de plugins : chaque module est un plugin installable/désinstallable. | Très élevé.                     |
| **WordPress**    | ✅ Oui (via plugins)       | Plugins activables/désactivables.                                            | Très élevé.                     |

- **Leçon** :
  - Les apps **grand public** (Notion, ClickUp) utilisent un **masquage simple** (Niveau 1 ou 2).
  - Les apps **techniques** (Jira, Discourse, WordPress) utilisent un **système de plugins** (Niveau 4).
  - **Hestia est entre les deux** : trop complexe pour un masquage simple, mais pas assez modulaire pour un système de plugins.

---

## 🎯 **Recommandations pour Hestia**

---
### 1. **À Court Terme (1-2 semaines)**
- **Corriger les problèmes de sécurité** :
  - Bloquer l’accès aux **routes des modules désactivés** (Niveau 2).
  - **Exemple** : Si `WineCellar` est désactivé, `/wine_cellars` doit rediriger vers la page d’accueil.
- **Améliorer l’UX** :
  - Ajouter un bouton **"Personnaliser la sidebar"** dans la sidebar.
  - Ajouter des **descriptions pour chaque module**.

---
### 2. **À Moyen Terme (1-2 mois)**
- **Optimiser les performances** :
  - Utiliser `autoload` pour charger les modèles des modules désactivés **à la demande** (Niveau 3).
  - **Exemple** : Déplacer `WineCellar` et `Bottle` dans `app/models/optional/`.
- **Ajouter la suppression des données** :
  - Permettre de **supprimer les données d’un module** quand il est désactivé.

---
### 3. **À Long Terme (3-6 mois)**
- **Refactorer en système de plugins** (Niveau 4) :
  - Chaque module devient une **gem Rails** (ex: `hestia-shopping`, `hestia-calendar`).
  - **Avantages** :
    - Chargement **à la demande** (gain de performance).
    - Possibilité de **désinstaller** complètement un module.
    - **Maintenabilité** : Chaque module peut être développé indépendamment.
  - **Inconvénients** :
    - **Complexité** : Refactorer 25 modules en gems prend du temps.
    - **Dépendance** : Gérer les dépendances entre modules (ex: `Shopping` dépend de `Products`).

---
### 4. **Alternative : Architecture Modulaire Sans Gems**
- **Idée** :
  - Garder tous les modules dans le même repo, mais :
    - **Isoler chaque module** dans son propre namespace (ex: `Shopping::`, `Calendar::`).
    - **Charger dynamiquement** les contrôleurs et modèles en fonction des modules activés.
  - **Exemple** :
    ```ruby
    # config/routes.rb
    if current_household.module_enabled?(:shopping)
      mount Shopping::Engine, at: "/shopping"
    end
    ```
  - **Avantage** : Moins complexe que les gems, mais presque aussi efficace.

---
# 📊 **Synthèse des Priorités**

| **Catégorie**               | **Priorité** | **Actions**                                                                                     | **Effort** | **Impact** |
|-----------------------------|--------------|------------------------------------------------------------------------------------------------|------------|------------|
| **Sécurité**                | ⭐⭐⭐⭐⭐      | Corriger CSRF, XSS, SQL Injection, ajouter 2FA, limiter la durée des tokens API.               | Moyen      | Élevé      |
| **Performances**            | ⭐⭐⭐⭐       | Optimiser les requêtes N+1, ajouter des index, améliorer le cache.                          | Moyen      | Élevé      |
| **Stabilité**               | ⭐⭐⭐⭐       | Corriger les bugs (Flutter, OAuth, géocodage, PDF).                                            | Élevé      | Élevé      |
| **UX Mobile**               | ⭐⭐⭐⭐       | Ajouter une PWA, optimiser pour mobile, corriger l’accessibilité.                           | Moyen      | Élevé      |
| **Onboarding**              | ⭐⭐⭐         | Simplifier l’onboarding, ajouter un tutoriel.                                                | Faible      | Moyen      |
| **Fonctionnalités manquantes** | ⭐⭐⭐      | Ajouter la synchronisation bancaire, les graphiques budget, les suggestions de recettes.      | Élevé      | Moyen      |
| **Refonte des modules**     | ⭐⭐          | Simplifier Budget, Calendar, Recipes, Shopping, Tasks, Fridge.                               | Élevé      | Moyen      |
| **Amélioration des modules désactivables** | ⭐⭐ | Bloquer l’accès aux routes, optimiser le chargement (Niveau 2-3). | Moyen | Élevé |
| **Suppression de modules**  | ⭐           | Supprimer Circles, Trip, Wellbeing, Wine Cellar, Outdoor (ou les désactiver par défaut).       | Faible      | Faible     |

---
# 🎯 **Recommandations pour la Suite**

---
### 1. **Version 1.0 (Stable)**
**Objectif** : Rendre Hestia **utilisable en production** par des familles.
**Actions** :
1. **Corriger les bugs critiques** (sécurité, stabilité).
2. **Optimiser les performances** (N+1, cache, index).
3. **Améliorer l’UX mobile** (PWA, accessibilité).
4. **Simplifier l’onboarding** (tutoriel, données d’exemple).
5. **Compléter les traductions** (français et anglais).
6. **Ajouter une documentation utilisateur** (guide, FAQ).

---
### 2. **Version 1.1 (Améliorations)**
**Objectif** : Ajouter des **fonctionnalités utiles** pour les familles.
**Actions** :
1. **Synchronisation bancaire** (Plaid/Nordigen).
2. **Graphiques pour le budget** (Chart.js).
3. **Suggestions de recettes** (basées sur le frigo).
4. **Gestion des quantités** (Shopping, Fridge).
5. **Pièces jointes dans les messages** (ActiveStorage).
6. **Rappels contextuels** (géolocalisation).

---
### 3. **Version 2.0 (Refonte)**
**Objectif** : **Simplifier et moderniser** l’application.
**Actions** :
1. **Supprimer les modules inutiles** (Circles, Trip, Wellbeing, Wine Cellar).
2. **Refondre les modules complexes** (Budget, Calendar, Recipes).
3. **Ajouter une IA** (suggestions intelligentes, détection de doublons).
4. **Intégrations externes** (IFTTT, Alexa, Google Assistant).
5. **Client mobile natif** (si la communauté le demande).

---
# 📝 **Exemple de Roadmap pour les 6 Prochains Mois**

| **Mois** | **Focus**                          | **Livrables**                                                                                     |
|----------|-----------------------------------|---------------------------------------------------------------------------------------------------|
| 1        | **Stabilité et sécurité**         | Correction des bugs critiques, optimisation des performances, ajout du 2FA.                  |
| 2        | **UX et onboarding**              | PWA, tutoriel, données d’exemple, corrections d’accessibilité.                                  |
| 3        | **Fonctionnalités familiales**   | Synchronisation bancaire, graphiques budget, gestion des quantités (Shopping/Fridge).          |
| 4        | **Intégrations et automatisation** | Suggestions de recettes, pièces jointes dans les messages, rappels contextuels.                 |
| 5        | **Refonte des modules**           | Simplification de Budget, Calendar, Recipes. Suppression des modules inutiles.                 |
| 6        | **Préparation de la v2.0**       | Ajout de l’IA (suggestions), intégrations externes (IFTTT), client mobile (si ressources).      |

---
# 🔍 **Analyse SWOT**

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
# 💡 **Conclusion : Mon Avis d’Utilisateur Lambda**

**Hestia est un projet ambitieux et prometteur**, mais **trop complexe pour un utilisateur moyen**.
En tant que père de famille avec 2 enfants, un budget serré et peu de temps, voici ce que je retiens :

---
### ✅ **Ce que j’adore** :
- **Tout est au même endroit** : Plus besoin de jongler entre 10 apps différentes (Todoist pour les tâches, Google Calendar pour les événements, YNAB pour le budget, etc.).
- **Open-source et gratuit** : Pas de risque de voir mes données vendues ou l’app devenir payante.
- **Auto-hébergement** : Je peux installer Hestia sur mon Raspberry Pi et garder le contrôle total.
- **Design moderne** : L’interface est belle et intuitive (même si perfectible).
- **Modules désactivables** : Je peux masquer les fonctionnalités dont je n’ai pas besoin (ex: cave à vin, cercles sociaux).

---
### ❌ **Ce qui me bloque** :
- **Trop de modules** : 25 modules, c’est trop. Je n’ai pas besoin de tout ça.
- **Bugs et fonctionnalités incomplètes** : La synchronisation calendrier externe ne marche pas, le client mobile est inutilisable.
- **Lent sur mobile** : Sans PWA, l’expérience sur téléphone est médiocre.
- **Complexité** : L’onboarding est trop long, et je ne sais pas par où commencer.
- **Désactivation superficielle** : Désactiver un module ne fait que le cacher, sans bloquer l’accès ou améliorer les performances.

---
### 🔧 **Ce que je ferais si j’étais le maintainer** :
1. **Simplifier** :
   - Garder **10 modules essentiels** (Courses, Frigo, Recettes, Tâches, Calendrier, Budget, Notes, Contacts, Messages, Documents).
   - Supprimer ou désactiver par défaut les modules niche (Circles, Trip, Wellbeing, Wine Cellar, Outdoor).
2. **Corriger les bugs** :
   - Priorité à la **sécurité** (2FA, CSRF, XSS) et à la **stabilité** (OAuth, géocodage, PDF).
3. **Optimiser pour le mobile** :
   - Ajouter une **PWA** pour une expérience app-like.
   - Simplifier l’interface pour les petits écrans.
4. **Améliorer l’onboarding** :
   - **Tutoriel guidé** au premier lancement.
   - **Données d’exemple** pour comprendre comment ça marche.
5. **Améliorer la désactivation des modules** :
   - **Bloquer l’accès aux routes** des modules désactivés (Niveau 2).
   - **Ajouter un bouton "Personnaliser la sidebar"** pour une UX plus intuitive.
   - **Optimiser le chargement** des modèles (Niveau 3) si les performances deviennent un problème.

---
# 📌 **Résumé en 3 Mots**
**Hestia = "Tout-en-un, mais trop."**
→ **Simplifiez, stabilisez, puis étendez.**