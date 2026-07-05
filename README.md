# Hestia

Application collaborative et libre de gestion du foyer — une alternative
complète, gratuite et auto-hébergeable aux applications de gestion du
quotidien freemium existantes.

Un foyer regroupe plusieurs membres (couple, famille, colocation) qui
partagent en temps réel les mêmes modules : courses, calendrier, recettes,
frigo, tâches, et une vingtaine d'autres domaines du quotidien (notes,
anniversaires, adresses, fidélité, animaux, véhicules, cave à vin, déchets,
bébé, messages, menu, routines, extérieur, budget, documents, cadeaux,
cercles, voyage, bien-être...).

Contrairement aux applications commerciales équivalentes, Hestia ne plafonne
aucune fonctionnalité derrière un abonnement : le code est public sous
licence [AGPLv3](LICENSE), et chacun peut héberger sa propre instance sans
dépendre d'un service tiers ni payer quoi que ce soit.

Pour le détail fonctionnel de chaque module, voir le
[Cahier des charges](<Cahier des charges — Hestia.md>) ; pour l'état
d'avancement du développement, voir le
[Plan d'implémentation](<Plan d'implémentation — Hestia.md>).

## Sommaire

- [Socle technique](#socle-technique)
- [Démarrage rapide (Docker)](#démarrage-rapide-docker)
- [Développement local](#développement-local)
- [Tests et qualité](#tests-et-qualité)
- [Client mobile](#client-mobile)
- [Structure du dépôt](#structure-du-dépôt)
- [Contribuer](#contribuer)
- [Licence](#licence)

## Socle technique

| Domaine | Choix |
|---|---|
| Backend / Web | Ruby on Rails 8.1 |
| Base de données | PostgreSQL |
| Temps réel | Hotwire (Turbo + Stimulus) + Solid Cable |
| Jobs asynchrones | Solid Queue |
| Cache | Solid Cache |
| Interface | ViewComponent (bibliothèque style shadcn, ~50 composants) + Tailwind v4 |
| Mobile | Flutter/Dart (squelette, consomme l'API `api/v1`) |
| Déploiement | Docker / Kamal |

Aucune dépendance à Redis/Sidekiq : Solid Queue/Cable/Cache tournent sur la
base PostgreSQL existante, ce qui simplifie l'auto-hébergement à un seul
processus applicatif.

## Démarrage rapide (Docker)

```sh
docker compose up -d          # démarre PostgreSQL
bin/setup                     # installe les dépendances, prépare la base, lance le serveur
```

L'application est ensuite accessible sur `http://localhost:3000`.

Pour un déploiement de production auto-hébergé, voir `config/deploy.yml`
(Kamal) et le `Dockerfile` à la racine.

## Développement local

Prérequis : Ruby `3.4.9` (voir `.ruby-version`), Node `20.11.1` (voir
`.node-version`), PostgreSQL.

```sh
bin/setup        # installe les gems/paquets JS, prépare la base
bin/dev           # lance serveur Rails + watchers esbuild/Tailwind (Procfile.dev)
```

La bibliothèque de composants UI est consultable sur `/design-system`.

## Tests et qualité

```sh
bin/rails test           # suite Minitest (modèles, contrôleurs, services)
bin/rails test:system    # tests système (Capybara)
bin/rubocop               # style (Rails Omakase)
bin/brakeman               # analyse de sécurité statique
bin/bundler-audit           # vulnérabilités connues des gems
```

Ces quatre commandes sont exécutées en intégration continue sur chaque pull
request (`.github/workflows/ci.yml`).

## Client mobile

Un squelette Flutter/Dart consommant l'API `api/v1` vit dans [`mobile/`](mobile/README.md).
Ce n'est pas encore une application fonctionnelle — voir ce README pour le
détail de ce qui reste à construire.

## Structure du dépôt

```
app/            application Rails (contrôleurs, modèles, vues, composants Ui::*, services)
config/         routes, environnements, initializers
db/             schéma et migrations
mobile/         client Flutter/Dart (squelette)
test/           suite Minitest
```

## Contribuer

Les contributions externes sont bienvenues — voir [CONTRIBUTING.md](CONTRIBUTING.md)
pour l'environnement de développement, les conventions de code et le
processus de pull request.

## Licence

Hestia est distribué sous licence [GNU AGPLv3](LICENSE). Toute instance
modifiée mise à disposition d'utilisateurs sur un réseau doit reverser ses
modifications sous la même licence.
