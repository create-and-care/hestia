class RoadmapController < ApplicationController
  allow_without_household

  # Progress by phase (Spec §18) and list of planned improvements, derived from
  # the application analysis. Static data versioned with the code, similar to
  # the Spec and Implementation Plan that they summarize.
  PHASES = [
    { name: "Phase 1 — Socle", detail: "User, Session, Household, Membership, scoping multi-foyer", status: :done },
    { name: "2.a — Modules prioritaires", detail: "Courses, Calendrier, Tâches, Frigo, Recettes", status: :done },
    { name: "2.b — Modules satellites", detail: "Notes, Anniversaires, Adresses, Prestataires, Fidélité, Animaux, Véhicules, Cave à vin, Déchets, Bébé, Messages", status: :done },
    { name: "2.c — Logique métier riche", detail: "Menu, Routines, Extérieur, Budget, Documents", status: :done },
    { name: "2.d — Écarts d'architecture", detail: "Cadeaux, Cercles, Voyage, Bien-être", status: :done },
    { name: "Rappels & notifications", detail: "Tâches, Calendrier, Frigo — reste la notification jour J Anniversaires", status: :partial },
    { name: "Intégrations externes", detail: "Open Food Facts, Nominatim, jours fériés, catalogues Fidélité/Extérieur faits — sync calendrier en scaffold", status: :partial },
    { name: "API api/v1", detail: "5 modules exposés (vague 2.a) sur 25", status: :partial },
    { name: "Application mobile", detail: "Squelette Flutter — connexion + Courses en lecture seule", status: :partial },
    { name: "Gouvernance & documentation", detail: "LICENSE, README, CONTRIBUTING, CHANGELOG, page Roadmap", status: :done },
    { name: "Site vitrine & doc utilisateur", detail: "Non démarré", status: :todo },
    { name: "Hest.IA (Phase 3)", detail: "Non démarrée — nécessite la consolidation des chantiers ci-dessus", status: :todo }
  ].freeze

  IMPROVEMENTS = [
    {
      category: "Tableau de bord & expérience transverse",
      emoji: "🧭",
      items: [
        "Enrichir le tableau de bord avec les widgets prévus au CDC §7 (frigo proche de péremption, anniversaires proches, tâches en retard, prochains événements) : il n'affiche aujourd'hui que le foyer, ses membres et le code d'invitation.",
        "Brancher un composant de recherche/navigation globale (Ui::CommandComponent, déjà présent dans la bibliothèque mais utilisé nulle part hors /design-system) plutôt que de naviguer via la grille de 25 liens du tableau de bord.",
        "Achever l'adoption de la bibliothèque de composants Ui:: dans les vues métier : 730 occurrences de classes grises codées en dur (gray-100, bg-gray-50…) contre 16 seulement d'usage des tokens sémantiques (bg-container, text-primary…) hors bibliothèque elle-même. Le mode sombre existe au niveau des tokens (classe .dark) mais n'est fonctionnellement exploité par presque aucune vue de module.",
        "Ajouter un flux d'activité du foyer (qui a fait quoi, quand) — utile pour la confiance en usage multi-membres et réutilisable comme brique de journalisation pour Hest.IA (CDC §13).",
        "Permettre l'export des données du foyer (JSON/CSV) : aucune fonctionnalité de portabilité des données personnelles n'existe à ce stade."
      ]
    },
    {
      category: "Sécurité & gestion de compte",
      emoji: "🔐",
      items: [
        "Permettre à un membre de quitter un foyer et à un administrateur d'en retirer un autre : MembershipsController et HouseholdsController n'exposent aucune action destroy à ce jour.",
        "Permettre la suppression d'un foyer (aucune route destroy sur households) : un foyer créé par erreur reste aujourd'hui permanent.",
        "Ajouter la suppression de compte utilisateur et un export de données personnelles, dans une logique de portabilité même en auto-hébergé (cf. politique de confidentialité recommandée, CDC §8).",
        "Ajouter une expiration/rotation des jetons API : ApiToken n'a pas de expires_at, un jeton reste valide indéfiniment tant qu'il n'est pas supprimé manuellement depuis /api_tokens.",
        "Renforcer la politique de mot de passe : User s'appuie uniquement sur has_secure_password, sans longueur minimale ni règle de complexité.",
        "Ajouter un rate limiting sur la route publique non authentifiée de réservation de cadeaux (g/:token/reserve/:idea_id), qui n'en a aucun contrairement à la connexion et au mot de passe oublié.",
        "Écrire les tests d'autorisation dédiés au module Bien-être recommandés en priorité par le CDC §5.4 : ni WellbeingController, ni WeightEntriesController, ni WorkoutEntriesController, ni leurs modèles n'ont de test à ce jour — c'est pourtant le module dont l'étanchéité est la plus sensible.",
        "Étendre la couverture de tests aux modules à écart d'architecture les moins couverts : Cercles (circle_memberships_controller, circle_posts_controller, circle_post_reactions_controller) et Cadeaux (gift_ideas_controller, gift_list_shares_controller) dérogent au scope foyer standard sans test contrôleur dédié."
      ]
    },
    {
      category: "Fiabilité, qualité & observabilité",
      emoji: "🧪",
      items: [
        "Écrire de vrais tests système (Capybara) : test/system ne contient qu'un fichier .keep, alors que le job CI system-test existe et passe donc trivialement sans rien vérifier.",
        "Combler l'écart global de couverture : 42 contrôleurs sur 93 et 48 modèles sur 80 n'ont aucun fichier de test dédié.",
        "Ajouter un outil de mesure de couverture (SimpleCov) à la CI pour rendre ces écarts visibles en continu plutôt que de les découvrir par audit ponctuel.",
        "Ajouter un outil de détection de requêtes N+1 (Bullet) : le risque augmente avec 25 modules et leurs associations imbriquées.",
        "Ajouter un outil de suivi d'erreurs en production (Sentry/Honeybadger/GlitchTip auto-hébergeable) : un job Solid Queue en échec silencieux (ex. Reminders::DeliverDue) ne remonterait nulle part aujourd'hui.",
        "Ajouter une interface d'administration Solid Queue (mission_control-jobs) pour inspecter les jobs en échec ou en attente, en particulier pour les rappels/notifications désormais critiques.",
        "Configurer explicitement le fuseau horaire de l'application (config.time_zone est commenté, valeur par défaut UTC) : plusieurs calculs « aujourd'hui » (péremption Frigo, échéances Tâches, digest quotidien) sont sensibles au fuseau réel du foyer."
      ]
    },
    {
      category: "Modules fonctionnels — compléments identifiés",
      emoji: "🧩",
      items: [
        "Brancher la notification jour J des Anniversaires sur l'infrastructure de rappels désormais en place (CDC §10.2).",
        "Implémenter le flux OAuth/CalDAV réel de la synchronisation calendrier externe : le scaffold ExternalCalendarConnection existe, pas la connexion effective.",
        "Étoffer le catalogue de plantes de référence au-delà des 6 fiches de départ (PlantReference).",
        "Étoffer le catalogue d'enseignes de fidélité au-delà de la dizaine de départ (LoyaltyBrand).",
        "Importer les contacts du répertoire téléphonique (Anniversaires, Prestataires) une fois le mobile suffisamment avancé.",
        "Ajouter la fusion intelligente des ingrédients (doublons, conversion d'unités) lors de l'ajout d'une recette aux courses — aujourd'hui un ajout brut sans fusion (capacité cible de Hest.IA).",
        "Étudier la communauté de recettes inter-foyers évoquée en évolution hors périmètre V1 (CDC §19), une fois une masse critique de foyers actifs atteinte."
      ]
    },
    {
      category: "API & Mobile",
      emoji: "📡",
      items: [
        "Étendre l'API api/v1 aux 20 modules restants : seuls Courses, Frigo, Recettes, Tâches, Calendrier sont exposés aujourd'hui.",
        "Ouvrir un canal temps réel pour les clients externes (WebSocket vers Solid Cable) : le mobile ne fait aujourd'hui que du HTTP ponctuel, sans mise à jour en direct.",
        "Construire la parité fonctionnelle du client mobile sur les 24 modules restants : seul un écran Courses en lecture seule existe.",
        "Ajouter l'accès caméra natif côté mobile (scan de code-barres Courses/Frigo, capture de documents).",
        "Ajouter la dictée vocale native côté mobile (Notes, Tâches).",
        "Ajouter les notifications push natives côté mobile, en s'appuyant sur l'infrastructure Notification/NotificationPreference déjà posée côté web.",
        "Ajouter un mode hors-ligne en lecture côté mobile pour les données déjà synchronisées.",
        "Ajouter le renouvellement transparent du jeton API côté mobile : aujourd'hui un jeton statique, sans expiration ni flux de rafraîchissement."
      ]
    },
    {
      category: "Internationalisation & accessibilité",
      emoji: "🌍",
      items: [
        "Structurer les textes de l'interface avec I18n : config/locales/en.yml est aujourd'hui le seul fichier de locale, alors que toute l'interface est en français codé en dur dans les vues — préalable à toute traduction future et bonne pratique même pour une appli mono-langue.",
        "Activer le PWA : manifest et service worker existent dans app/views/pwa/ mais restent commentés dans config/routes.rb et le layout, alors qu'ils permettraient d'installer l'app web sur mobile/desktop en attendant la parité complète du client Flutter.",
        "Auditer l'accessibilité clavier et lecteur d'écran des composants Stimulus personnalisés (combobox, dialog, dropdown, command…) : aucun test d'accessibilité automatisé n'existe à ce stade."
      ]
    },
    {
      category: "Site, documentation & gouvernance",
      emoji: "📚",
      items: [
        "Construire un site vitrine public (page d'accueil, une page par module, présentation de Hest.IA, mise en avant du caractère gratuit/open-source) : non démarré, distinct de cette page Roadmap applicative.",
        "Constituer un centre de documentation utilisateur par module (guides d'usage), au-delà des fichiers de gouvernance déjà en place.",
        "Rédiger une politique de confidentialité adaptée au contexte auto-hébergé, recommandée dès qu'un foyer héberge des données de tiers (liens publics Cadeaux, Cercles).",
        "Envisager une traduction anglaise du Cahier des charges et du Plan d'implémentation pour élargir l'audience de contribution externe à un projet aujourd'hui 100 % francophone."
      ]
    },
    {
      category: "Hest.IA (Phase 3)",
      emoji: "🤖",
      items: [
        "Démarrer Hest.IA seulement une fois les chantiers ci-dessus consolidés (notification Anniversaires, flux OAuth/CalDAV réel, extension API, tests Bien-être) : l'assistant hériterait sinon des mêmes lacunes (CDC §13, Plan §7).",
        "Généraliser la couche de services métier par domaine aux modules qui n'en ont pas encore, condition posée dès la section 5 du CDC pour que Hest.IA puisse les invoquer comme outils."
      ]
    }
  ].freeze

  def show
    @phases = PHASES
    @improvements = IMPROVEMENTS
  end
end
