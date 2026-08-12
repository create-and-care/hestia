# Hestia design language

Hestia is a household-management app (budget, tâches, courses, calendrier, contacts, profils
bébé…). **All UI copy is French** — sentence case, `« … »` for quotes, amounts as `1 284,90 €`.
The look is warm and grounded: terracotta brand, warm-tinted neutrals instead of gray, color
reserved for status and per-module accents — the "Terre cuite" direction (see below).

## Direction "Terre cuite" — déviation intentionnelle de l'amont

Le design system a été forké depuis `Create-and-Care/hestia` (`main`) — palette indigo, gris
neutre, densité `text-sm`. Le 2026-07-31, la direction a changé volontairement vers une identité
terracotta plus chaude. **Une future synchronisation avec l'amont doit réappliquer cette
direction, pas revenir à l'indigo.**

| | Amont (`main`) | Hestia (Terre cuite) |
| --- | --- | --- |
| Marque | indigo `#444CE7` | clay-600 `#A85030` |
| Neutres | gris froid (`gray-*`) | tinte chaude dérivée de `#3A2A22` |
| Destructif | `red-*` (hue ≈ 3°, trop proche du clay) | `crimson-*` (hue ≈ 348°, plus froid) |
| Densité | `text-sm`-first (corps 14px) | `text-base`-first (corps 16px) |
| Rayons | `md` 8px / `lg` 10px | `sm` 8 / `md` 10 / `lg` 14 / `2xl` 20 |
| Contrôles | h-8/9/10 (32/36/40) | `--control-h-{sm,default,lg}` 36/40/44 |
| Accents module | absent en amont | 12 tokens `--module-*`, un par domaine du foyer |
| Contrepoint froid | bleu générique (`--link`, `--info`) | `pine-*`, vert-bleu désaturé (2026-08-12) |
| Accent éditorial | absent en amont | Instrument Serif via `--font-display` (2026-08-12) |
| Composants | — | 4 ajouts : `ModuleMedallion`, `GreetingHeader`, `CelebrationMoment`, `HouseholdHeader` |

Les échelles brutes d'amont (`gray-*`, `red-*`, `indigo-*`, etc.) restent intactes pour la data
viz — seuls les tokens **sémantiques** (marque, neutres, destructif, contrepoint froid) ont changé
de source.

## Les trois règles

> **Hestia ressemble à un foyer bien tenu, pas à un tableau de bord.**

C'est la phrase de direction : elle tranche les cas que rien ci-dessous ne couvre. Matières de
référence — papier ivoire (les surfaces), terre cuite mate non émaillée (la marque), lin écru
(les neutres chauds).

1. **Le pin est le contrepoint froid, jamais une seconde marque.** Il prend ce qui informe sans
   demander d'action (liens, `--info`, jauges, séries neutres). La terre cuite garde ce qui
   s'active. Le pin n'apparaît ni dans les accents de module, ni sur un badge de statut, ni en
   fond de bouton — une envie de l'y mettre signale un token manquant, pas une couleur.
2. **L'accent ne remplit jamais un bouton.** L'amber marque — une pastille, un repère dans une
   jauge. Un bouton amber est soit un primaire mal déguisé, soit un avertissement mal étiqueté.
3. **Un filet d'1px plutôt qu'un écart.** À l'intérieur d'une carte, un trait `border-subdued`
   hiérarchise mieux qu'un `gap` de 20px. L'écart sépare les cartes ; le filet sépare ce qu'elles
   contiennent.

## Surfaces & color roles

Style with **semantic utility classes** — they swap automatically in dark mode. Never hardcode
grays for chrome, and never use `dark:` variants (theming is class-based via tokens).

| Role | Classes |
| --- | --- |
| Page background | `bg-surface` (body default), hover rows `hover:bg-surface-hover` |
| Card / panel | `bg-container` + `border border-primary rounded-lg`, or `shadow-border-xs` |
| Inset well (code, tab track, skeleton) | `bg-surface-inset`, `bg-container-inset` |
| Text hierarchy | `text-primary` → `text-secondary` → `text-subdued`; on dark fills `text-inverse` |
| Links | `text-link`, buttons variant `link` add `hover:underline underline-offset-4` |
| Status | `text-success` / `text-warning` / `text-destructive` / `text-info` / `text-accent`; tinted fills `bg-success/10`, `bg-warning/10`, `bg-destructive/10`, `bg-accent/10` |
| Borders | `border-primary` (default), `border-secondary`/`border-subdued` (quieter), `border-divider` (hairlines) |
| Focus | `focus-visible:ring-focus` (2px neutral ring) |
| Buttons | `bg-button-primary`/`-secondary`/`-destructive` + `hover:bg-button-*-hover`, ghost/outline hovers `bg-button-ghost-hover`/`bg-button-outline-hover` (full recipes in `guidelines/components/formulaires-saisie.md`) |

Raw palette (`bg-gray-100`, `text-red-700`, plus the additions `clay-*`, `crimson-*` and `pine-*`,
25–900 scales in `tokens/tokens.md`) is for data viz and illustrations only — chrome always uses
the semantic roles above. `pine-*` in particular is never hand-painted: a link is `text-link` and
an info tint is `bg-info/10`, so the counterpoint stays in one place (règle 1).

## Contrat de contraste

`--success` / `--warning` / `--destructive` / `--info` / `--accent` are tuned as **fills** (dots,
bars, borders) — at 13–15px on a 10% tint several land under 4.5:1. The rule:

> **Le fond utilise `--X`, le texte dessus utilise `--X-text`.**

`--success-text` / `--warning-text` / `--destructive-text` / `--info-text` / `--accent-text` are
the separately-tuned, contrast-safe counterparts — that's what `text-success` etc. actually
resolve to (mapped `!important` in `application.tailwind.css` so Tailwind's auto-generated
`text-*` utilities can't win by source order). `Badge`, `Alert`, and `Field`'s error line all use
these, never the base `--X` token, for their text color.

Same logic for links: `--link` is `pine-700`, not `pine-600` — 8.4:1 on `--surface` against 6.3:1,
and `pine-600` is reserved as the `--info` fill. Dark mode mirrors it with `pine-300` (9.1:1). A
global `a` / `a:hover` rule lives in `@layer base` — an unstyled link never falls back to the
browser default blue.

## Shape, elevation, spacing

- Radius: `--radius-sm` 8px (chips, checkboxes), `--radius-md` 10px (buttons, inputs, menu
  items), `--radius-lg` 14px (cards, panels, popovers, dialogs), `--radius-2xl` 20px (bubbles),
  `--radius-full` (pills, avatars, icon dots) — softened/expanded vs. the amont's 8/10.
- Elevation: `shadow-border-{xs,sm,md,lg,xl}` — shadow plus a 1px hairline. Cards sit flat
  (`border-primary` or `shadow-border-xs`); menus/popovers float with `shadow-border-md`;
  dialogs/sheets with `shadow-border-lg` or `-xl`. Plain `shadow-*` exists but the paired
  `shadow-border-*` is the house style.
- Spacing rhythm: `gap-2` icon↔label, `gap-1.5` compact; `p-4`/`p-6` card padding; `gap-4`/
  `gap-6` between sections; `space-y-1` menu lists. Controls are `--control-h-sm` 36px /
  `--control-h-default` 40px / `--control-h-lg` 44px — the single source of truth `Button`,
  `Input`, `Select`, `Textarea`, and `InputOtp` all read from (`InputOtp` is 40 wide × 44 tall).
  The 4px spacing step itself is unchanged from the amont.

## Typography

`font-sans` = Geist with system fallback (no webfont ships — system stack in practice);
`font-mono` = IBM Plex Mono stack for code, kbd, amounts in tables; `--font-display` = Instrument
Serif, see "Chaleur du foyer" below (`--font-hand` is a deprecated alias for it — don't write new
calls against it). Weights: 400/500/600 (`font-normal`/`font-medium`/`font-semibold`) — nothing
heavier, and **400 only** on the serif, which ships no other weight: anything bolder is a
synthetic bold on screen. Scale enlarged from text-sm-first to text-base-first (body 16px, was 14px):
`text-xs` 13 · `text-sm` 15 · `text-base` 16 · `text-lg` 20 · `text-xl` 22 · `text-2xl` 26 ·
`text-3xl` 32 · `text-4xl` 40.

| Level | Classes |
| --- | --- |
| h1 | `.h1` (40px, line-height 1.15, letter-spacing -0.02em, semibold) |
| h2 | `.h2` (32px, line-height 1.2) |
| h3 | `.h3` (26px, line-height 1.25) |
| h4 / page section | `.h4` (22px, line-height 1.3) |
| Lead | `text-lg text-secondary` (20px) |
| Body | `.body-text text-primary` (16px / line-height 1.6) |
| Large | `text-lg font-semibold text-primary` (20px) |
| Small / Muted | `text-sm` (15px) — `font-medium leading-none` for small, `text-secondary` for muted |
| Code | `rounded-[6px] bg-surface-inset px-1.5 py-0.5 font-mono text-sm text-primary` |

`Ui::TypographyComponent` is the canonical implementation of this scale — read it rather than
hand-rolling heading classes.

## Icons

Lucide, vendored under `app/assets/icons/lucide`. Two rendering paths, pick by whether the icon
needs a color it can't inherit from surrounding text:

- **`lucide_icon(name)`** — inlines the SVG with `stroke="currentColor"`, default
  `class="size-4"`. Sizes and colors like text. The default for icons sitting next to a label.
- **`lucide_icon_mask(name)`** — paints the icon via CSS `mask` (`background-color: currentColor`
  clipped to the glyph shape) instead of inlining the SVG. Required whenever the icon's color
  must come from something other than inherited text color — e.g. `ModuleMedallionComponent`,
  where the glyph is `text-module-*` but the wrapping `<span>` has no text content for an inline
  SVG's `stroke="currentColor"` to key off visually the same way. **Never render a colored icon
  as `<img src=...>`** — an `<img>` can't inherit `currentColor` at all and renders black
  regardless of the module color, which defeats the point of a module accent.

Stick to the vendored set: arrow-left, arrow-right, baby, bell, book-open, cake, calendar-plus,
calendar, car, carrot, check, chef-hat, clock, credit-card, droplet, dumbbell, euro, file-text,
gift, grip-vertical, handshake, heart-pulse, house, info, layout-dashboard, layout-grid, link,
list, list-checks, list-filter, luggage, mail, map, map-pin, message-circle, mic, milk, minus,
notebook-pen, package, paperclip, paw-print, pencil, phone, pill, plus, puzzle, recycle,
refresh-cw, refrigerator, repeat, scale, search, settings, shopping-cart, smartphone, sofa,
sprout, square-check, star, sun, syringe, trash-2, trees, trending-up, triangle-alert, users,
users-round, utensils, waves, wine, wrench, x.

## Dark mode

Add `class="dark"` on `<html>` — every semantic token swaps (warm near-black `--background`
`#14100E`, never pure `#000`; `clay-300` brand; warm off-white primary text). A design built
only from semantic classes needs zero extra work to support it — **never write a `dark:`
variant**; if you find yourself reaching for one, the right fix is a new semantic token, not an
inline override. That's the test of doing it right.

## Motion

Floating panels animate with `animate-in fade-in-0 zoom-in-95` on open (`animate-out
fade-out-0 zoom-out-95` on close), sheets/drawers with `slide-in-from-{top,bottom,left,right}`,
accordions with `animate-accordion-down/up`. Durations 150–300ms (`duration-200` etc.). This is
the only motion in the system — see "Chaleur du foyer" below for what deliberately gets none.

## Chaleur du foyer

Four components exist with no upstream equivalent — assumed additions, not gaps to fill on the
next sync:

- **`ModuleMedallionComponent`** — a Lucide glyph in a circle tinted 12% by module color, via
  `lucide_icon_mask` (see Icons above). Sizes 32/44/64.
- **`GreetingHeaderComponent`** — hour-of-day salutation in the `.greeting` class (44px serif,
  weight 400, line-height 1.05, letter-spacing -0.01em), plus one line of real context. Slots:
  Bonne nuit (0–5h) · Bonjour (5–11h) · Bon appétit (11–14h) · Bon après-midi (14–18h) · Bonsoir
  (18–22h) · Bonne soirée (22–24h). `hour`/`greeting` props override.
- **`CelebrationMomentComponent`** — a band tinted 10%, three kinds: `birthday` (gifts/cake),
  `streak` (courses/sprout), `milestone` (calendar/star). Title in the serif at 28px/400 — 28
  rather than the scale's 26 because the serif has a smaller x-height than Caveat had.
- **`HouseholdHeaderComponent`** — household photo, name, members. No photo → a warm invitation
  to add one, never a gray square.

**Restraint is the point.** No emoji, no exclamation points, no confetti, no animation on any of
the four — the editorial serif accent alone carries the warmth.

The serif appears in exactly **three** components: `GreetingHeader`, `CelebrationMoment`, and the
`Empty` title (22px/400) — plus hero amounts and dashboard section titles, granted case by case in
the views rather than through a component. Never a label, never a table cell, never under 20px.
Grep for `--font-display`/`.greeting` before adding a fourth component.

## Ton éditorial chaleureux

- Salue par le prénom, sans virgule avant : « Bonjour Anthony » pas « Bonjour, Anthony ».
- Une ligne de contexte réelle sous la salutation (ex. le nombre de tâches du jour), jamais une
  phrase générique de bienvenue.
- Les états vides s'écrivent comme un encouragement, pas comme une erreur : « Ajoutez une photo
  du foyer », pas « Aucune photo ». Pas de point d'exclamation.

## Ajouts intentionnels

Ce qui n'a pas d'équivalent en amont, à préserver lors d'une future synchronisation :

- Les échelles `clay-*` (marque), `crimson-*` (destructif) et `pine-*` (contrepoint froid) — voir
  "Direction Terre cuite" et "Les trois règles" ci-dessus.
- `--font-display` (Instrument Serif) et la classe `.greeting`. `--font-hand` n'est plus qu'un
  alias déprécié de `--font-display`, à supprimer dans une passe ultérieure.
- La prop `tint` sur `Avatar`/`AvatarGroup` — clé de module ou couleur CSS brute, avec repli par
  hachage sur le pool des 12 accents de module.
- Les 4 composants "chaleur du foyer" : `ModuleMedallion`, `GreetingHeader`, `CelebrationMoment`,
  `HouseholdHeader`.
- Le système d'illustrations d'état vide (`Empty#illustration`, brief complet sur
  `/design-system/illustrations`).
