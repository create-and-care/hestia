# Contribuer à Hestia

Merci de l'intérêt porté à Hestia. Le projet est ouvert aux contributions
externes, à l'image du projet [Sure](https://github.com/we-promise/sure) qui
en inspire la gouvernance : tout est gratuit, tout est open-source, pas de
palier payant caché derrière une contribution refusée.

## Avant de contribuer

- Pour un changement mineur (typo, petit bug), une pull request directe suffit.
- Pour une nouvelle fonctionnalité ou un changement de comportement, ouvrez
  d'abord une issue décrivant le besoin, en la reliant si possible au module
  concerné dans le [Cahier des charges](<Cahier des charges — Hestia.md>) et
  au [Plan d'implémentation](<Plan d'implémentation — Hestia.md>).
- Les décisions d'architecture actées dans le CDC (section 4) et les quatre
  écarts documentés (section 5 : Cercles, Cadeaux, Voyage, Bien-être) sont
  des choix arrêtés : toute proposition qui s'en écarte doit être discutée en
  issue avant implémentation.

## Environnement de développement

Prérequis : Ruby `3.4.9` (`.ruby-version`), Node `20.11.1` (`.node-version`),
PostgreSQL (`docker compose up -d` en fournit une instance locale).

```sh
bin/setup     # installe les dépendances, prépare la base
bin/dev       # serveur Rails + watchers esbuild/Tailwind
```

Sous Windows, utilisez WSL2 (Ubuntu) plutôt que Ruby natif — cf. CDC §4.

## Conventions de code

- **Style Ruby** : [Rails Omakase](https://github.com/rails/rubocop-rails-omakase)
  via RuboCop (`.rubocop.yml`). Pas de style personnalisé au-delà de ce socle.
- **Interface** : réutilisez les composants existants sous `app/components/ui/`
  (bibliothèque style shadcn, consultable sur `/design-system`) plutôt que
  d'écrire du HTML/Tailwind ad hoc. Si un composant manque, ajoutez-le à la
  bibliothèque plutôt que de dupliquer un patron ponctuel.
- **Scoping foyer** : toute donnée nouvelle doit être scopée via le concern
  `HouseholdScoped` et filtrée par `Current.household`, jamais par un
  paramètre client — sauf pour les quatre modules à écart d'architecture
  documentés au CDC §5.
- **Logique métier** : privilégiez un service object par domaine
  (`app/services/<Module>::<Action>`, ex. `Courses::AddItem`) plutôt qu'un
  contrôleur ou un modèle dense. C'est ce qui permettra à Hest.IA (Phase 3)
  d'invoquer cette même logique comme outil, sans dupliquer le code métier.
- **Temps réel** : toute création/modification/suppression visible en liste
  doit diffuser via `broadcasts_to` / `broadcasts_refreshes_to` (Solid Cable),
  au même titre que les modules déjà livrés.

## Tests

Toute pull request doit rester verte sur les quatre vérifications de CI
(`.github/workflows/ci.yml`) :

```sh
bin/rails test           # modèles, contrôleurs, services
bin/rails test:system    # tests système (Capybara)
bin/rubocop               # style
bin/brakeman               # sécurité statique
bin/bundler-audit           # vulnérabilités des dépendances
```

Un nouveau module ou une nouvelle fonctionnalité s'accompagne de tests
modèle + contrôleur (+ service le cas échéant), à l'image des 83+ fichiers
de tests déjà présents sous `test/`.

## Pull requests

- Une pull request = un sujet. Évitez de mélanger une fonctionnalité et un
  refactor sans rapport.
- Décrivez le *pourquoi* du changement, pas seulement le *quoi* (le diff
  parle déjà pour le *quoi*).
- Signalez explicitement tout écart volontaire par rapport au CDC ou au Plan
  d'implémentation, et proposez la mise à jour correspondante de ces deux
  documents dans la même pull request.

## Licence des contributions

En proposant une contribution, vous acceptez qu'elle soit distribuée sous les
termes de la licence [AGPLv3](LICENSE) du projet.
