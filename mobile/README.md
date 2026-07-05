# Hestia — client mobile (squelette)

Client mobile Flutter/Dart d'Hestia (CDC §14) : client léger consommant l'API Rails
`api/v1`, sans logique métier propre — toute règle de gestion vit côté serveur, pour
un comportement identique au client web.

## Statut

**Squelette minimal**, pas une application fonctionnelle : structure de projet,
client HTTP (`ApiClient`), écran de connexion par jeton API, et un premier écran
« Courses » en lecture seule. Sert de point de départ, pas de livrable.

**Reste à construire**, avant toute parité fonctionnelle réelle :

- Écrans pour les 24 autres modules (CDC §9 à §12).
- Accès caméra natif (scan code-barres, capture de documents).
- Dictée vocale, notifications push, import de contacts.
- Mode hors-ligne (lecture des données déjà synchronisées).
- Connexion temps réel (WebSocket vers Solid Cable), pour l'instant uniquement
  du HTTP ponctuel côté client.
- Gestion du renouvellement de jeton / re-authentification transparente.

## Prérequis

Flutter SDK (stable) — non installé dans cet environnement de développement au
moment de la création de ce squelette ; le code n'a donc pas été exécuté/testé
avec `flutter run` ou `flutter analyze`.

## Démarrer

```sh
cd mobile
flutter pub get
flutter run
```

À la connexion, l'écran demande l'URL de l'instance Hestia (ex.
`https://mon-foyer.example.com`) et un jeton API, généré depuis le web sur
`/api_tokens` (Tableau de bord → Jetons API).
