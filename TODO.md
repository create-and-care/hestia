# TODO — File d'exécution court terme

> **Établi le 2026-08-07, par vérification ligne à ligne contre le commit `a9be35b`.**
>
> Ce fichier distille `amelioration.md` (55 Ko) et `design-system.md` (87 Ko) après
> avoir confronté **chacune de leurs affirmations au code réel**.
>
> **Verdict : environ 60 % des affirmations de ces deux documents sont fausses** — elles
> décrivent des fonctionnalités déjà livrées. Les trois commits qui les ont ajoutés
> (`363c5e2`, `60d5f4f`, `a9be35b`) ne touchent ni `app/components/ui/` ni
> `application.tailwind.css` : ils ont été écrits *après* le travail, sans que le code
> bouge. Le §2 ci-dessous existe pour empêcher qu'on réimplémente ce qui existe.

## Definition of Done

Un item n'est clos que lorsque **les quatre** conditions sont réunies :

1. Le champ *Vérif* de l'item passe.
2. `bin/rails test` et `bin/rubocop` sont verts.
3. Pour tout item touchant le rendu : `bin/rails visual:check` sans régression.
4. **Le changement est répercuté dans [`app/models/roadmap.rb`](app/models/roadmap.rb)
   et `config/locales/{en,fr}/roadmap.yml`.**

Le point 4 n'est pas un item, c'est une condition. `roadmap.rb` se déclare lui-même
« the project's single source of truth for progress ». Si ce fichier-ci devient un
backlog concurrent, il pourrira exactement comme les deux qu'il remplace.

## Péremption de ce fichier

`TODO.md` est **la file court terme**, pas la timeline produit. Il doit être vidé dans
`roadmap.rb` et **supprimé à la 1.0**. Aucun nouveau document d'analyse à la racine ne
doit être créé : le dépôt porte déjà `README`, `CHANGELOG`, `CONTRIBUTING`,
`CODE_OF_CONDUCT` — plus ces deux audits, dont le §10 organise la suppression.

*Un backlog qui ne planifie pas sa propre mort devient ce qu'il remplaçait.*

---

# 1. Comment lire ce fichier

**Identifiants** — `SEC` · `PERF` · `DS` (design system) · `I18N` · `PROD` (produit) ·
`DOC`. Le préfixe porte le *thème*, la vague porte le *calendrier*. Citez l'ID en
message de commit.

**Effort** — `S` (< 1 h) · `M` (1–4 h) · `L` (> 1 jour).

**Ordre des vagues** — les vagues 0→6 sont classées par **certitude décroissante**, pas
par gravité décroissante. Les vagues 0–2 sont des choses que je peux prouver cassées ;
les vagues 5–6 sont des arbitrages produit. Qui s'arrête en cours de lecture s'arrête
sur la partie défendable.

**Champ *Vérif*** — obligatoire, et c'est le champ qui compte le plus. Sans commande de
preuve, un item se ferme cosmétiquement : c'est précisément le mécanisme qui a produit
les deux documents sources.

**Champ *Règle*** (items design uniquement) — clé exacte issue de
[`report_builder.rb`](app/services/visual_check/report_builder.rb) : `touch_target`,
`overflow_page`, `overflow_container`, `spacing_scale`, `font_size`, `font_weight`,
`contrast`. Utilisez la clé littérale pour pouvoir grepper le rapport généré.

---

# 2. ⚠️ À NE PAS FAIRE — affirmations réfutées

**Ne mettez aucune de ces lignes en chantier.** Chaque « réalité » ci-dessous est
accompagnée d'une preuve rejouable. Une réfutation sans reproduction ne serait qu'une
contre-affirmation.

| Affirmation des audits | Réalité vérifiée | Preuve |
|---|---|---|
| « ~50 composants UI » | **75**, un fichier de test chacun (368 cas) | `ls app/components/ui/*.rb \| wc -l` → 75 · `ls test/components/ui/*_test.rb \| wc -l` → 75 |
| « Pas de dark mode » | 3 modes (clair/sombre/système) + script anti-FOUC avant premier paint | bloc `.dark{}` `application.tailwind.css:370-456` · `theme_controller.js` · `layouts/application.html.erb:14-21` |
| « Pas de recherche globale » | Palette de commandes complète sur 27 modèles | `app/services/global_search.rb` · `app/views/shared/_search_dialog.html.erb` |
| « Pas de raccourci ⌘K » | Implémenté, avec indice `<kbd>⌘K</kbd>` visible | `dialog_controller.js:12-20` · `search_palette_controller.js` |
| « Pas de breadcrumbs » | Utilisés dans **101 vues** | `grep -rl breadcrumb app/views \| wc -l` → 101 |
| « Pas de Toast / Tooltip / Accordion » | Les trois existent | `sonner_component.rb` · `tooltip_component.rb` · `accordion_component.rb` |
| « Pas de Skeleton / Spinner » | Les deux existent et sont testés | `skeleton_component.rb` · `spinner_component.rb` (voir toutefois **DS-05**) |
| « Modale : pas d'animation, pas de tailles, pas de bouton fermer » | Les trois existent | `ANIMATION_CLASSES` + `POSITION_CLASSES` dans `dialog_component.rb` · bouton `aria-label` dans le template |
| « Contraste : `text-gray-400` sur fond blanc » | **Zéro classe de palette Tailwind brute** dans les vues ; tout passe par des tokens sémantiques | `grep -rE "(text\|bg\|border)-(gray\|slate\|red\|blue)-[0-9]{2,3}" app/views app/components` → 0 · `test/lib/color_contrast_test.rb` (ΔE, deux thèmes) |
| « Pas d'échelle typo, h1 = 24 px » | Échelle à 8 crans, **h1 = 40 px**, avec `line-height` et `letter-spacing` par niveau | `.h1`–`.h4` dans `application.tailwind.css:612-615` |
| « 3 couleurs seulement » | ~150 tokens, 14 échelles, 12 accents par module | bloc `@theme` `application.tailwind.css:9-265` |
| « Pas de tokens rayon / ombres » | `--radius-sm…full` et `--shadow-xs…xl` + 5 utilitaires composites | `application.tailwind.css:31-35`, `260-264`, `498-502` |
| « Sidebar non responsive, pas de hamburger » | `<aside>` en `max-md:hidden` + barre 56 px et `Ui::DrawerComponent` sous `md` | `app/views/shared/_app_sidebar.html.erb` |
| « Pas de badges de notification dans la sidebar » | Pastille non-lu + badge live via `turbo_stream_from` | `app/views/shared/_sidebar_nav.html.erb` |
| « Pas d'`aria-label` sur les boutons-icônes » | 38 `aria-label` + 37 `sr-only`, **et un test le fait respecter** | `test/lib/icon_only_button_test.rb` |
| « CSRF peut-être désactivé » | `load_defaults 8.1` l'active ; l'API opte correctement pour `ActionController::API` | `config/application.rb:12` · `api/v1/base_controller.rb:6` |
| « XSS via `raw` / `html_safe` » | 3 occurrences, les 3 sûres (échappement **avant** balisage) | `notes_helper.rb:63-65` (`CGI.escapeHTML` puis regex) · `icon_helper.rb:14` (SVG vendorisés) |
| « Injection SQL par interpolation » | Aucun `where("…#{}")` dans `app/` ou `lib/` ; `sanitize_sql_like` partout | `global_search.rb:189` · les 3 `Arel.sql` enveloppent du SQL **constant** |
| « Pas de Brakeman » | Brakeman + bundler-audit en CI, **sans fichier d'exclusion** | `.github/workflows/ci.yml`, job `scan_ruby` |
| « Jetons API sans expiration ni révocation » | Empreinte HMAC-SHA256, `expires_at`, `last_used_at`, UI de révocation | `app/models/api_token.rb` (voir toutefois **SEC-02**) |
| « Index manquants sur `user_id` / `household_id` » | **127 des 132** colonnes `*_id` indexées ; les 5 restantes sont des moitiés polymorphes couvertes par un composite `[type, id]` | `db/schema.rb` |
| « Ajouter la gem `bullet` » | Déjà présente **et** configurée en développement et en test | `Gemfile.lock` · `config/environments/development.rb:82-91`, `test.rb:64-74` |
| « OAuth calendrier externe non implémenté » | Google + Microsoft (avec refresh tokens et validation `state`) **plus** un client CalDAV écrit à la main qui définit le verbe WebDAV `REPORT` | `app/services/calendar/external_sync/` (5 fichiers) · `external_calendar_connections_controller.rb:28,63` |
| « Prawn plante en UTF-8 » | Assaini par aller-retour Windows-1252 ; avertissement m17n documenté | `pdf/shopping_list_document.rb:44` · `config/initializers/prawn.rb` |
| « Pas de page 500 personnalisée » | `public/500.html` (8 Ko) + 400 / 404 / 422 / 406 | `ls public/*.html` |
| « `waste` et `outdoor` sans traduction française » | **Parité exacte : en 1984 clés = fr 1984 clés, zéro manquante dans les deux sens**, 47 fichiers de chaque côté | commande en Annexe B |
| « Désactiver un module ne fait que le cacher ; `/wine_cellars` reste accessible » | ~70 contrôleurs gatés par `before_action`, tests à l'appui | `app/controllers/concerns/module_gating.rb` (`"wine_cellars" => "wine_cellar"`) · `test/controllers/module_gating_test.rb` |
| « Onboarding en 5+ étapes » | **2 soumissions de formulaire** (inscription → choix foyer → nom) | `onboarding_controller.rb` : une seule action `show` |
| « Shopping : pas de quantité ni de catégorie » | `quantity`, `unit` et `rayon` existent sur l'item **et** sur le produit | `db/schema.rb`, table `shopping_list_items` |
| « Frigo : pas de date de péremption, pas de lien recettes » | `expires_on` existe et alimente les notifications ; suggestion de recettes implémentée | `app/models/concerns/perishable.rb` · `app/services/frigo/suggest_recipes.rb` |
| « Calendrier : pas de vue semaine ni jour » | `VIEWS = %w[month week day list]`, les quatre implémentées, préférence persistée | `calendar_controller.rb:2` |
| « Pas de documentation de composants » | Page `/design-system` : 6 vues + 73 aperçus, **tableaux de props réflexifs** (lus depuis `initialize.parameters`, donc non dérivables) | `app/models/design_system_registry.rb` (voir toutefois **DS-02**) |

---

# 3. Vague 0 — Gains rapides (< 1 h chacun)

Tous les gains rapides sont **ici et nulle part ailleurs** : les dupliquer dans les
vagues thématiques est le mécanisme par lequel un document se contredit lui-même. Le
préfixe d'ID préserve la lecture thématique.

- [ ] **DOC-01 — Corriger « ~50 composants » dans le README**
  - *Pourquoi* : le README annonce « ~50 components » ; il y en a 75. C'est la source
    exacte du premier chiffre faux de `design-system.md`.
  - *Fichiers* : [README.md](README.md)
  - *Effort* : S
  - *Vérif* : `ls app/components/ui/*.rb | wc -l` correspond au chiffre du README.

- [ ] **DS-01 — `alt` manquant sur l'aperçu de document**
  - *Pourquoi* : seule image du dépôt sans texte alternatif (19 des 20 en ont un).
  - *Fichiers* : [app/views/documents/preview.html.erb:5](app/views/documents/preview.html.erb#L5)
  - *Effort* : S · *Règle* : —
  - *Vérif* : `grep -rn "image_tag\|<img" app/views | grep -v "alt" | wc -l` → 0

- [ ] **DS-02 — Enregistrer `button_to` et `view_toggle` dans le registre**
  - *Pourquoi* : le registre expose 73 entrées pour 75 composants ; deux composants
    n'ont donc ni page de doc ni aperçu.
  - *Fichiers* : [app/models/design_system_registry.rb](app/models/design_system_registry.rb),
    `app/views/design_system/previews/`
  - *Effort* : S
  - *Vérif* : `DesignSystemRegistry` compte 75 entrées = nombre de fichiers dans `app/components/ui/`.
  - *Note* : à fusionner avec **DS-08** si celui-ci est traité dans la même passe.

- [ ] **SEC-02 — Retirer le choix de jeton API sans expiration**
  - *Pourquoi* : `EXPIRATION_CHOICES` mappe `""` sur `nil`, donc un jeton perpétuel
    reste sélectionnable dans l'UI. Tout le reste du modèle (empreinte, révocation,
    `last_used_at`) est correct — c'est le seul résidu.
  - *Fichiers* : [app/controllers/api_tokens_controller.rb:8](app/controllers/api_tokens_controller.rb#L8)
  - *Effort* : S
  - *Vérif* : `bin/rails test test/controllers/api_tokens_controller_test.rb` vert et
    l'option vide absente du `<select>`.

- [ ] **SEC-03 — Rate-limit sur la réservation d'idée cadeau publique**
  - *Pourquoi* : `post "g/:token/reserve/:idea_id"` est la **seule route sensible sans
    `rate_limit`** — et elle est non authentifiée. Les 3 entrées d'auth en ont un
    (`to: 10, within: 3.minutes`), pas celle-ci. Énumération de jetons possible.
  - *Fichiers* : [config/routes.rb:277](config/routes.rb#L277),
    `app/controllers/public_gift_lists_controller.rb`
  - *Effort* : S
  - *Vérif* : test de contrôleur asserant un `429` au-delà du seuil.
  - *Roadmap* : correspond au jalon `public_route_hardening`.

- [ ] **DS-03 — `loading="lazy"` sur les images**
  - *Pourquoi* : zéro image en chargement différé. Les 4 `loading: :lazy` existants
    sont des `turbo_frame_tag` (chargement de contenu différé), pas des images.
  - *Fichiers* : les 20 sites `image_tag` / `<img>` de `app/views`
  - *Effort* : S · *Règle* : —
  - *Vérif* : `grep -rn "image_tag" app/views | grep -cv "loading"` → 0 (hors logos above-the-fold).

- [ ] **PERF-01 — `data-turbo-preload` sur la navigation principale**
  - *Pourquoi* : zéro occurrence dans tout le dépôt. Turbo est déjà là ; c'est un
    attribut à poser sur les liens de la sidebar.
  - *Fichiers* : [app/components/ui/sidebar_item_component.html.erb](app/components/ui/sidebar_item_component.html.erb)
  - *Effort* : S
  - *Vérif* : `grep -rn "turbo-preload" app/ | wc -l` > 0 et navigation manuelle sans régression.

> **Le décommentage PWA n'est délibérément pas ici.** Il ressemble à 3 lignes
> ([routes.rb:319-321](config/routes.rb#L319-L321) +
> [application.html.erb:25](app/views/layouts/application.html.erb#L25)), mais un
> service worker interagit avec la CSP (`worker-src`, `manifest-src`). C'est
> **DS-09**, bloqué par **SEC-01**.

---

# 4. Vague 1 — Bloquants 1.0 (sécurité & production)

- [ ] **SEC-01 — Activer une Content-Security-Policy**
  - *Pourquoi* : [config/initializers/content_security_policy.rb](config/initializers/content_security_policy.rb)
    est **intégralement commenté — zéro ligne active**. Aucun en-tête CSP n'est émis.
    **Aucun des deux audits ne le mentionne**, alors qu'ils placent tous deux XSS en
    tête de leurs préoccupations : c'est l'argument le plus net de leur non-fiabilité.
    Une CSP est par ailleurs un bien meilleur contrôle anti-XSS que le `sanitize` qu'ils
    recommandent (lequel *autoriserait* une liste de balises, là où l'échappement actuel
    n'en autorise aucune).
  - *Piège* : [app/views/layouts/application.html.erb:14-21](app/views/layouts/application.html.erb#L14-L21)
    est le script **inline** anti-FOUC du dark mode. Un `script_src :self` strict le tue
    et ramène le flash au chargement. La CSP doit livrer un `:nonce` **et** le propager
    à ce script **dans le même commit** — c'est ce qui rend l'item M et non S.
  - *Fichiers* : `config/initializers/content_security_policy.rb`,
    `app/views/layouts/application.html.erb`
  - *Effort* : M · *Bloque* : **DS-09** (PWA)
  - *Vérif* : `curl -sI localhost:3000 | grep -i content-security-policy` renvoie l'en-tête ·
    `bin/rails visual:check` sur les 273 routes sans erreur console (Puppeteer remonte
    les violations CSP — c'est une couverture de non-régression déjà payée).

- [ ] **SEC-04 — Conditionner `force_ssl` / `assume_ssl` par variable d'environnement**
  - *Pourquoi* : les deux sont commentés en production. Mais **ne pas décommenter tel
    quel** : le public déclaré est l'auto-hébergeur AGPL, et forcer SSL sans condition
    casse les installations LAN en HTTP simple. Conditionner sur `ENV["FORCE_SSL"]`.
  - *Fichiers* : [config/environments/production.rb:28,31](config/environments/production.rb#L28-L31),
    documentation de la variable dans le README
  - *Effort* : S
  - *Vérif* : booter en production avec et sans `FORCE_SSL=1`, vérifier la redirection
    dans un cas et son absence dans l'autre.

- [ ] **SEC-05 — Test de complétude de `ModuleGating::CONTROLLER_MODULES`**
  - *Pourquoi* : le mapping contrôleur→module est un hash **maintenu à la main**. Un
    nouveau contrôleur de module qui n'y est pas ajouté échappe silencieusement au
    gating. Le commentaire du fichier l'admet déjà.
  - *Fichiers* : [app/controllers/concerns/module_gating.rb](app/controllers/concerns/module_gating.rb),
    `test/controllers/module_gating_test.rb`
  - *Effort* : M · *Bloque* : SEC-06
  - *Vérif* : un test qui énumère les routes et échoue si un contrôleur appartenant à un
    module n'est ni listé ni explicitement exempté.

- [ ] **SEC-06 — Gater les modules désactivés côté `Api::V1::*`**
  - *Pourquoi* : l'API JSON n'est **pas** gatée
    ([module_gating.rb:9](app/controllers/concerns/module_gating.rb#L9) le documente).
    Un module désactivé reste intégralement **lisible et inscriptible** par jeton API.
    L'utilisateur croit avoir désactivé une fonctionnalité ; elle reste ouverte.
  - *Fichiers* : `app/controllers/api/v1/base_controller.rb`, `module_gating.rb`
  - *Effort* : M · *Dépend de* : SEC-05
  - *Vérif* : test d'intégration — jeton valide + module désactivé → `403` sur `index`
    **et** sur `create`.
  - *Note* : enchaîner SEC-05 → SEC-06 et écrire **un seul** garde couvrant les deux
    surfaces, pas deux listes à maintenir en parallèle.

> **2FA : reporté en vague 6, sciemment.** Les deux audits le classent ⭐⭐⭐⭐⭐. Or les
> 3 entrées d'authentification portent déjà un rate limiting (`to: 10, within: 3.minutes`),
> les cookies de session sont signés/`httponly`/`same_site: :lax`, et une UI de
> révocation des sessions actives existe. Effort L, pour un produit mono-foyer
> auto-hébergé. Ce n'est pas un bloquant 1.0.

---

# 5. Vague 2 — Performance mesurée

- [ ] **PERF-02 — Mettre en cache les recherches Open Food Facts**
  - *Pourquoi* : **`Rails.cache` a zéro site d'appel dans tout `app/` et `lib/`**, alors
    que `solid_cache_store` est configuré et inutilisé
    ([production.rb:50](config/environments/production.rb#L50)). À traiter **en premier**
    malgré sa petite taille : le premier site d'appel fixe les conventions de namespace
    de clés et de TTL pour tous les suivants. Un code-barres → produit est effectivement
    immuable, c'est donc le point d'entrée le plus sûr.
  - *Fichiers* : [app/services/open_food_facts/lookup_product.rb](app/services/open_food_facts/lookup_product.rb)
  - *Effort* : S · *Bloque* : PERF-03 (conventions)
  - *Vérif* : test avec WebMock asserant **un seul** appel HTTP pour deux recherches du
    même code-barres.

- [ ] **PERF-03 — Mettre en cache le géocodage Nominatim**
  - *Pourquoi* : une requête `Net::HTTP` par appel, sans mémoïsation. Au-delà de la
    latence, c'est la politique d'usage d'OpenStreetMap qui l'exige. TTL plus court que
    PERF-02 (une adresse peut être corrigée en amont).
  - *Fichiers* : [app/services/geocoding/search_address.rb](app/services/geocoding/search_address.rb)
  - *Effort* : S · *Dépend de* : PERF-02
  - *Vérif* : test WebMock, un seul appel pour deux recherches identiques.

- [ ] **PERF-04 — Pousser les filtres du dashboard en SQL**
  - *Pourquoi* : le dashboard charge des relations **non bornées** puis filtre en
    **Ruby** avant de tronquer à 5. Les prédicats sont du calcul de dates pur, donc
    **Bullet ne les signalera jamais** et **`includes` ne corrige rien** — c'est le
    diagnostic exact que `amelioration.md` a manqué (il parle de N+1 ; ce n'en est pas).
  - *Fichiers* : [app/controllers/dashboard_controller.rb](app/controllers/dashboard_controller.rb)
    lignes 17 (`vehicles`), 21 (`plants`), 27 (`fridge_items`), 34 (`contacts`), 39 (`tasks`)
  - *Effort* : M
  - *Vérif* : `bin/rails test test/controllers/dashboard_controller_test.rb` vert, et le
    log de requêtes montre des `LIMIT` en SQL au lieu de chargements complets.

- [ ] **PERF-05 — Borner l'expansion des récurrences du calendrier**
  - *Pourquoi* : [dashboard_controller.rb:44](app/controllers/dashboard_controller.rb#L44)
    charge **tous** les `calendar_events` jamais créés et déplie leurs occurrences en
    mémoire, avec une garde à 1 000 itérations **par événement**. C'est le plus fort
    impact utilisateur réel de tout ce fichier, et ça se dégrade avec l'âge du foyer.
  - *Fichiers* : `dashboard_controller.rb:44`, [app/services/recurrence.rb](app/services/recurrence.rb),
    `app/models/calendar_event.rb:31-41`
  - *Effort* : M · *Bloque* : PROD-08 (RRULE)
  - *Vérif* : test avec 500 événements récurrents ; le nombre de lignes chargées reste
    borné par la fenêtre de dates.
  - *Note* : c'est un item **distinct** de PERF-04. Il exige une **API de fenêtre de
    dates bornée** sur le service `Recurrence`, pas un `where`. Poser cette couture
    maintenant évite de réécrire le service deux fois quand RRULE arrivera.

- [ ] **PERF-06 — Eager loading sur les actions `index` qui en manquent**
  - *Pourquoi* : ~11 actions `index` sans `includes`/`preload` : `documents`,
    `shopping_lists`, `trips`, `shared_projects`, `baby_profiles`, `loyalty_cards`,
    `notifications`, `recipe_catalog`, `workout_templates`, `products`,
    `external_calendar_connections`.
  - *Effort* : M
  - *Vérif* : faire **lever** Bullet dans la suite de test (`Bullet.raise = true`) et
    l'utiliser pour énumérer les cas — plutôt que de les chercher à la main.

> **Reportés en vague 6 :** `pg_trgm`/GIN sur `GlobalSearch` (28 `ILIKE '%…%'` à joker
> initial, non indexables) et découpage du bundle esbuild. Le compromis est **documenté
> dans l'en-tête du service** et reste correct à l'échelle mono-foyer visée.

---

# 6. Vague 3 — Design system & violations mesurées

- [ ] **DS-00 — Régénérer `bin/rails visual:check` avant tout le reste**
  - *Pourquoi* : `tmp/visual/report.md` est **gitignoré** et date du 2026-08-02 17:48.
    **N'inscrivez aucun chiffre dans les autres items DS avant de l'avoir rejoué.**
  - *Effort* : S · *Bloque* : **tous les autres items DS**
  - *Vérif* : `bin/rails visual:check` produit un `tmp/visual/report.md` frais.

> ### ⚠️ Deux mises en garde de lecture du rapport
>
> **1. Attribution corrigée.** Le rapport impute ses 1 656 constats `spacing_scale` à un
> sélecteur `aside > nav > a.on-tone` en `padding: 10px`. **Ce n'est pas la sidebar de
> l'application** :
> [`sidebar_item_component.html.erb`](app/components/ui/sidebar_item_component.html.erb)
> utilise `h-11` (44 px — sur grille, et au-dessus du plancher tactile de 36 px). Le vrai
> coupable est le `py-2.5` de
> [`item_component.html.erb:4`](app/components/ui/item_component.html.erb#L4), rendu
> **76 fois** par le shell de la doc via
> [`design_system/_shell.html.erb:4`](app/views/design_system/_shell.html.erb#L4). Les
> deux partagent `Ui::SidebarComponent` comme enveloppe, d'où le sélecteur trompeur.
>
> **2. Ne pas optimiser les mauvaises pages.** Le top 10 du rapport est **intégralement**
> composé de `design_system_icons` et `design_system_colors` (306–311 occurrences
> chacune) — des pages **réservées aux développeurs**. Un constat à 2 occurrences sur un
> écran utilisateur prime sur 306 occurrences sur la doc interne. Le tri par volume brut
> conduira l'exécutant droit dans le mur.

- [ ] **DS-04 — Aligner `Ui::ItemComponent` sur la grille de 4 px**
  - *Pourquoi* : `py-2.5` = 10 px, hors grille. Source dominante des constats
    `spacing_scale`.
  - *Fichiers* : [app/components/ui/item_component.html.erb:4](app/components/ui/item_component.html.erb#L4)
  - *Effort* : S (une ligne) mais **impact sur 46 vues** · *Règle* : `spacing_scale · 10px → 8px ou 12px`
  - *Vérif* : `bin/rails visual:check` — chute du compte `spacing_scale` ; **et une
    validation humaine à l'œil** avant/après, car c'est un glissement de densité sur
    tout le produit.

- [ ] **DS-05 — Utiliser `Ui::SkeletonComponent` dans les turbo-frames différés**
  - *Pourquoi* : le composant existe, est testé, et n'est utilisé **dans aucune vue de
    production** — uniquement dans son propre aperçu. Les 4 `turbo_frame_tag
    loading: :lazy` n'affichent rien pendant le chargement. Meilleur rapport
    perception/effort du fichier : zéro surface nouvelle.
  - *Fichiers* : `app/views/tasks/_task.html.erb:44`,
    `app/views/fridge_items/_fridge_item.html.erb:16`,
    `app/views/routines/_routine.html.erb:21,31`
  - *Effort* : S
  - *Vérif* : `grep -rln SkeletonComponent app/views | grep -v previews | wc -l` > 0

- [ ] **DS-06 — Échelle de tokens `z-index`**
  - *Pourquoi* : seule catégorie de tokens réellement absente (contrairement à ce
    qu'affirment les audits pour le rayon et les ombres, qui eux existent). Aujourd'hui :
    `z-50` ×9, `z-40`, `z-30`, `z-[100]` posés à la main — l'ordre d'empilement
    dialog/drawer/toast/tooltip n'est écrit nulle part.
  - *Fichiers* : `app/assets/stylesheets/application.tailwind.css` (bloc `@theme`), puis
    les 12 sites d'appel
  - *Effort* : M
  - *Vérif* : `grep -rhoE "\bz-(\[?[0-9]+\]?)" app/views app/components` ne renvoie plus
    que des tokens nommés.

- [ ] **DS-07 — Corriger les violations mesurées de `/design-system/{icons,colors}`**
  - *Pourquoi* : débordement horizontal de 80 px à 390 px (`scrollWidth` 470 vs 390),
    police à 11 px (plancher 13 px), cibles tactiles à 31 px (plancher 36 px).
  - *Fichiers* : `app/views/design_system/icons.html.erb`, `colors.html.erb`
  - *Effort* : M · *Règle* : `overflow_page` · `font_size` · `touch_target`
  - *Vérif* : `bin/rails visual:check` — zéro `overflow_page` sur ces deux routes.
  - *Priorité* : **basse malgré le volume** — voir la mise en garde n°2 ci-dessus.

- [ ] **DS-09 — Activer la PWA**
  - *Pourquoi* : `app/views/pwa/manifest.json.erb` et `service-worker.js` **existent sur
    le disque**, mais les routes et le `<link rel="manifest">` sont commentés. L'app
    n'est donc pas installable. (`amelioration.md` dit « pas de manifest.json » : c'est
    littéralement faux, fonctionnellement juste.)
  - *Fichiers* : [config/routes.rb:319-321](config/routes.rb#L319-L321),
    [app/views/layouts/application.html.erb:25](app/views/layouts/application.html.erb#L25)
  - *Effort* : M · *Dépend de* : **SEC-01** (`worker-src` / `manifest-src` dans la CSP)
  - *Vérif* : Lighthouse « Installable » au vert ; vérifier les icônes et le
    comportement hors-ligne.
  - *Roadmap* : jalon `pwa` — dont le texte français dit déjà que manifest et SW sont
    « encore commentés dans les routes et le layout ».

- [ ] **DS-08 — `icon:` / `icon_position:` sur `Ui::ButtonComponent`**
  - *Pourquoi* : **seule affirmation design réellement juste des deux audits.** Les
    icônes passent aujourd'hui par le bloc de contenu (les `gap-*` de `SIZES` existent
    pour ça). C'est un manque de commodité, pas de capacité.
  - *Fichiers* : [app/components/ui/button_component.rb](app/components/ui/button_component.rb),
    son test, son aperçu
  - *Effort* : M
  - *Vérif* : `bin/rails test test/components/ui/button_component_test.rb` + aperçu à jour.
  - *Ordre* : **en dernier de la vague** — c'est le composant au plus grand rayon
    d'appel. Fusionner **DS-02** dans la même passe.

---

# 7. Vague 4 — i18n & garde-fous CI

**L'ordre est contraignant, pas indicatif.**

- [ ] **I18N-01 — Ajouter les blocs `date:` / `time:` `formats:` aux deux locales**
  - *Pourquoi* : **aucun bloc `formats:` n'existe dans aucun fichier de locale.** Les
    11 appels `l()` actuels ne fonctionnent que grâce aux défauts de la gem `rails-i18n`.
    Sans ces clés, I18N-03 n'a rien à appeler.
  - *Fichiers* : `config/locales/{en,fr}/`
  - *Effort* : S · *Bloque* : **I18N-03**
  - *Vérif* : `I18n.t("date.formats.short", locale: :fr)` renvoie une valeur du dépôt,
    pas celle de la gem.

- [ ] **I18N-02 — `i18n-tasks` + job CI**
  - *Pourquoi* : la parité 1984/1984 est aujourd'hui **maintenue à la main**. Elle
    dérivera. C'est le seul noyau valide de l'affirmation « traductions incomplètes »
    des audits — laquelle est fausse au présent mais juste au futur.
  - *Fichiers* : `Gemfile`, `config/i18n-tasks.yml`, `.github/workflows/ci.yml`
  - *Effort* : M
  - *Vérif* : `bundle exec i18n-tasks missing` → vide, et le job échoue si on retire une clé.
  - *Piège* : n'activer que `missing` au début. `unused` échouera dès le premier jour sur
    un arbre de 1 984 clés — prévoir un nettoyage séparé.

- [ ] **I18N-03 — Migrer les 60 `strftime` vers `l()`**
  - *Pourquoi* : 60 `strftime` dans 30 fichiers de vues contre 11 `l()`. Les formats sont
    **codés en dur en français** (`"%d/%m/%Y"`) : un utilisateur en locale anglaise voit
    `07/08/2026` pour le 7 août — **activement faux**, pas seulement non localisé.
  - *Effort* : M · *Dépend de* : I18N-01, protégé par I18N-02
  - *Vérif* : suite verte en locale `en` **et** `fr`.
  - *Piège* : exclure les `strftime` qui ne sont pas de l'affichage — paramètres d'URL,
    p. ex. `app/views/calendar/show.html.erb:47,49`.

- [ ] **I18N-04 — Interdire `strftime` dans `app/views`**
  - *Pourquoi* : sans garde, la migration se défait au fil des PR.
  - *Effort* : S · *Dépend de* : I18N-03
  - *Vérif* : règle RuboCop (ou grep en CI) qui échoue sur un `strftime` réintroduit.

---

# 8. Vague 5 — Produit

## 8.1 Le motif existe déjà dans le dépôt

**2 à 3× moins cher par unité de valeur.** À traiter en priorité dans cette vague :
l'infrastructure est là, il ne reste qu'à la brancher.

- [ ] **PROD-01 — Pièces jointes et réactions sur les messages**
  - *Pourquoi* : `Message` n'a que `content` / `author_id` / `conversation_id`. Mais
    **`CirclePost` porte déjà `has_one_attached :photo` *et* un modèle
    `CirclePostReaction` complet** avec son contrôleur et ses routes. Le motif est écrit,
    testé et livré — il n'est simplement pas appliqué aux messages.
  - *Fichiers* : `app/models/message.rb`, `config/routes.rb:233` (aujourd'hui
    `only: :create`), en miroir de `circle_post_reactions_controller.rb`
  - *Effort* : M

- [ ] **PROD-02 — Graphiques dans le module Budget**
  - *Pourquoi* : `budget/show.html.erb` n'a qu'un `Ui::ProgressComponent`. Or
    **`Ui::ChartComponent` existe et tourne déjà** dans `pools/history.html.erb:19` et
    `wellbeing/show.html.erb:48`. Ce n'est pas de l'infrastructure manquante, c'est un
    branchement.
  - *Fichiers* : `app/views/budget/show.html.erb`, `budget_controller.rb`
  - *Effort* : M

- [ ] **PROD-03 — `quantity` / `unit` sur `fridge_items`**
  - *Pourquoi* : `shopping_list_items` porte `quantity` **et** `unit` ; `fridge_items`
    n'a ni l'un ni l'autre — alors que `Frigo::MoveToShoppingList` et
    `AddFromShoppingListItem` traversent déjà cette frontière et perdent l'information.
  - *Effort* : M · *Bloque* : tout travail sur les services Frigo↔Courses
  - *Note* : poser la colonne **avant** de toucher à ces services.

## 8.2 Net-neuf

- [ ] **PROD-04 — Lier `/roadmap` depuis la navigation** — la page existe et le README la
  désigne comme document de périmètre canonique, mais elle n'est liée que depuis le pied
  de page d'onboarding et un onglet de réglages : **un utilisateur connecté avec un foyer
  ne verra jamais de lien vers elle.** *Effort* : S
- [ ] **PROD-05 — Sous-tâches, priorité et tags sur `Task`** — atténuations actuelles :
  `TaskCategory` (colonnes kanban), `emoji`, et un `due_status` dérivé. *Effort* : L
- [ ] **PROD-06 — Recherche de recettes par ingrédient** — un `joins(:recipe_ingredients)`
  dans une chaîne de filtres qui existe déjà (`recipes_controller.rb:10-31`). « Que
  puis-je cuisiner avec du poulet ? » ne renvoie rien aujourd'hui. *Effort* : M
- [ ] **PROD-07 — Champ `price` sur les articles de courses** + total automatique. *Effort* : M
- [ ] **PROD-08 — Récurrence RRULE** — le service `Recurrence` fait 11 lignes
  (daily/weekly/monthly/yearly). Pas de « 2e mardi », pas de `COUNT`, pas de multi-jours.
  *Dépend de* : **PERF-05**. *Effort* : L
- [ ] **PROD-09 — Les 3 préférences de notification manquantes** — `task_reminder`,
  `event_reminder` et `external_calendar_sync_failed` sont inconditionnelles (3 des
  6 types). *Effort* : M
- [ ] **PROD-10 — Réinitialisation des données par module** — aujourd'hui c'est tout ou
  rien (`HouseholdsController#destroy`). Désactiver un module laisse ses lignes intactes
  et invisibles. *Effort* : M
- [ ] **PROD-11 — Données de démonstration depuis l'UI** — `DemoData::Seeder` existe et
  couvre ~22 modules, mais n'est accessible que par `bin/rails demo_data:default`.
  L'exposer résout le « pas de données d'exemple » des audits **sans écrire de seeder**.
  *Effort* : M
- [ ] **PROD-12 — Section aide / FAQ** — aucun contrôleur, route, vue ni namespace de
  locale. *Roadmap* : jalon `marketing_docs`. *Effort* : L
- [ ] **PROD-13 — Tutoriel guidé au premier lancement** — la seule critique d'onboarding
  des audits qui tienne (le « 5+ étapes » est faux : il y en a 2). *Effort* : L

---

# 9. Vague 6 — Parqué

| Sujet | Motif | Déclencheur de réévaluation |
|---|---|---|
| **2FA** | Rate limiting déjà sur les 3 entrées d'auth, cookies signés `httponly`, UI de révocation de sessions. Effort L. | Première instance multi-foyers exposée sur Internet public |
| **`pg_trgm` / GIN sur la recherche** | 28 `ILIKE` à joker initial, compromis **documenté** dans l'en-tête du service ; correct en mono-foyer | Latence de recherche > 300 ms sur un foyer réel |
| **Découpage du bundle esbuild** | Bundle unique, 50 contrôleurs Stimulus chargés d'emblée, mais seules dépendances tierces : Stimulus, Turbo, sortablejs | Ajout d'une dépendance tierce lourde |
| **Réordonnancement de la sidebar** | SortableJS est déjà là (listes, tâches, fidélité, menu) mais pas câblé à la sidebar. Confort, pas blocage. | Demande utilisateur récurrente |
| **PaperTrail / historique** | Vrai manque de traçabilité en foyer partagé (« qui a supprimé cet événement ? »), mais effort L | *Roadmap* : jalon `household_activity_export` |
| **Parité Flutter** | 305 lignes de Dart ; `mobile/README.md` se décrit **lui-même** comme « a skeleton, not a deliverable » et précise que le code n'a jamais été exécuté. Périmètre assumé, pas défaut découvert. | *Roadmap* : jalon `mobile_parity` |
| **Hest.AI** | *Roadmap* : jalon `hestai` | — |
| **Recettes inter-foyers** | Marqué **explicitement hors V1** dans la roadmap | — |

## 9.1 Refusé : supprimer Circles / Trip / Wellbeing / Wine Cellar / Outdoor

`amelioration.md` recommande de supprimer ou désactiver par défaut cinq modules jugés
« trop niche ». **Cette recommandation est rejetée.**

1. Ces cinq modules sont **livrés, testés, traduits (parité fr/en exacte) et déjà gatés**
   par `ModuleGating`.
2. **Le besoin invoqué est déjà couvert.** L'argument de l'audit est la surcharge
   cognitive de 25 modules — or ils sont désactivables par foyer, depuis un onglet
   dédié, et le gating bloque réellement les routes. La fonctionnalité demandée existe.
3. **Le coût est asymétrique.** Supprimer du code fonctionnel est irréversible côté
   données utilisateur ; le garder ne coûte que de la maintenance.
4. **La source n'est pas fiable.** Supprimer du code qui marche sur la recommandation
   d'un document dont ~60 % des affirmations factuelles sont fausses n'est pas un
   arbitrage défendable.

Le désaccord est consigné ici pour que la question ne soit pas rouverte sans élément
nouveau. Un vrai signal serait de la donnée d'usage, pas une intuition de niche.

---

# 10. Documentation & hygiène du dépôt

- [ ] **DOC-02 — Récolter le contenu réutilisable des deux audits**
  - *Pourquoi* : au-delà de leurs erreurs factuelles, les deux documents contiennent de
    l'idéation produit **absente du dépôt** : le benchmark concurrentiel (§ « Comment
    Font les Autres Apps ? ») et les suggestions par module. Extraire avant de supprimer.
  - *Cible* : vagues 5/6 de ce fichier + jalons `upcoming` de `roadmap.rb`
  - *Effort* : M · *Bloque* : DOC-03

- [ ] **DOC-03 — Supprimer `amelioration.md` et `design-system.md`**
  - *Pourquoi* : ils sont **nuisibles, pas seulement périmés**. Leurs affirmations
    fausses ont l'apparence de l'actionnable — elles nomment des fichiers et proposent
    des diffs. C'est strictement pire que pas de document du tout.
  - *Pourquoi pas un simple bandeau « OBSOLÈTE »* : un bandeau en tête ne survit pas à
    une lecture par fragments. Le passage qui dit « ajouter le dark mode » ne portera pas
    l'avertissement. La suppression est la seule intervention qui opère à la granularité
    de lecture réelle.
  - *Précédent en dépôt* : l'en-tête de [`app/models/roadmap.rb`](app/models/roadmap.rb)
    consigne que Specification et Implementation Plan ont été *« deleted once their
    content was fully absorbed here »*. Même geste, même raison.
  - *Effort* : S · *Dépend de* : **DOC-02**
  - *Vérif* : `git show a9be35b:amelioration.md` reste accessible — l'historique fait le
    travail d'archive.

- [ ] **DOC-04 — Rafraîchir le CHANGELOG**
  - *Pourquoi* : dernière entrée au 2026-07-05, et il **référence encore
    `Specification — Hestia.md` et `Implementation Plan — Hestia.md`, deux fichiers qui
    n'existent plus**. C'est le coût exact de n'avoir pas terminé l'absorption la fois
    précédente — raison de plus de faire DOC-02 avant DOC-03. Travaux absents : refonte
    « Terre cuite » du design system, sidebar responsive, breadcrumbs, outillage
    `visual:check`.
  - *Effort* : M

---

# Annexe A — Correspondance avec `roadmap.rb`

| Item | Jalon `MILESTONE_SLUGS` |
|---|---|
| SEC-03 | `public_route_hardening` |
| DS-09 | `pwa` |
| PROD-12 | `marketing_docs` |
| PROD-06 | `reference_catalog_growth` |
| PaperTrail (§9) | `household_activity_export` |
| Parité Flutter (§9) | `mobile_parity` |
| Recettes inter-foyers (§9) | `cross_household_recipes` (hors V1) |
| Hest.AI (§9) | `hestai` |
| Tous les autres | **hors roadmap** — à y verser au fil de la Definition of Done |

`public_route_hardening` mentionne aussi « aucun outil de test a11y en place ». C'est
inexact au présent : `bin/rails visual:check` mesure `contrast`, `touch_target` et
`font_size` sur 273 routes × 2 thèmes, et `test/lib/` porte trois tests d'accessibilité
et de contraste. À corriger dans `roadmap.yml`.

# Annexe B — Commandes de re-vérification

```bash
# Composants et couverture de test
ls app/components/ui/*.rb | wc -l              # → 75
ls test/components/ui/*_test.rb | wc -l        # → 75

# Zéro classe de palette Tailwind brute dans les vues
grep -rE "\b(text|bg|border)-(gray|slate|zinc|neutral|stone|red|blue|green|yellow|indigo|purple|pink)-[0-9]{2,3}" \
  app/views app/components | wc -l             # → 0

# Parité des locales (1984 = 1984, zéro manquante dans les deux sens)
ruby -ryaml -e '
def leaves(h, pre="")
  h.flat_map { |k,v| v.is_a?(Hash) ? leaves(v, "#{pre}#{k}.") : ["#{pre}#{k}"] }
end
en = Dir["config/locales/en/*.yml"].flat_map { |f| leaves(YAML.unsafe_load_file(f)["en"] || {}) }
fr = Dir["config/locales/fr/*.yml"].flat_map { |f| leaves(YAML.unsafe_load_file(f)["fr"] || {}) }
puts "en=#{en.size} fr=#{fr.size} manquantes_fr=#{(en-fr).size} manquantes_en=#{(fr-en).size}"'

# Écarts réels
grep -rn "Rails.cache" app/ lib/ | wc -l       # → 0   (PERF-02)
grep -c "^[^#]" config/initializers/content_security_policy.rb  # → 0  (SEC-01)
grep -rn "strftime" app/views | wc -l          # → 60  (I18N-03)
grep -rn "turbo-preload" app/views | wc -l     # → 0   (PERF-01)
grep -rln "SkeletonComponent" app/views | grep -v previews | wc -l  # → 0  (DS-05)
grep -rhoE "\bz-(\[?[0-9]+\]?)" app/views app/components | sort | uniq -c  # (DS-06)
```

# Annexe C — Propositions des audits non retenues

| Proposition | Motif du rejet |
|---|---|
| Remplacer Prawn par `wicked_pdf` | Ajouterait le binaire wkhtmltopdf (non maintenu, archivé) à l'image Docker, pour corriger un plantage qui **n'existe pas** — l'UTF-8 est déjà assaini |
| Utiliser `sanitize` sur les sorties de notes | Serait **une régression** : `sanitize` laisse passer une liste blanche de balises, là où `CGI.escapeHTML` (déjà en place, appliqué **avant** le balisage) n'en laisse passer aucune |
| Ajouter `protect_from_forgery` explicitement | Déprécié sous Rails 8 ; `load_defaults 8.1` s'en charge |
| Migrer vers `importmap-rails` pour le code splitting | Contresens : importmap **retire** le bundling, il ne le découpe pas |
| Ajouter `tabindex="0"` partout | Anti-pattern d'accessibilité sur des éléments nativement focusables ; casse l'ordre de tabulation naturel |
| Labels flottants (Material Design) | Choix esthétique contraire au parti pris du design system ; `Ui::FieldComponent` empile les labels **délibérément**, avec câblage `aria-describedby` |
| `font-light` (300) | Système à 3 graisses (400/500/600) assumé, pas un oubli |
| Dégradés sur les boutons | Contraire au parti pris visuel ; aucun bénéfice fonctionnel |
| Effets sonores | Hors périmètre |
| Refondre les 25 modules en gems Rails | Effort colossal ; le gating par `before_action` couvre déjà le besoin réel |
| Storybook | `/design-system` fait déjà le travail, avec des **tableaux de props réflexifs** (lus depuis `initialize.parameters` et `registered_slots`) — donc structurellement impossibles à laisser dériver, ce que Storybook ne garantit pas |
| Suppression de 5 modules | Voir §9.1 |
