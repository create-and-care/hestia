# Hestia design language

Hestia is a household-management app (budget, tâches, courses, calendrier, contacts, profils
bébé…). **All UI copy is French** — sentence case, `« … »` for quotes, amounts as `1 284,90 €`.
The look is quiet and neutral: near-black on white, gray surfaces, color reserved for status.

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
| Status | `text-success` / `text-warning` / `text-destructive` / `text-info`; tinted fills `bg-success/10`, `bg-warning/10`, `bg-destructive/10` |
| Borders | `border-primary` (default), `border-secondary`/`border-subdued` (quieter), `border-divider` (hairlines) |
| Focus | `focus-visible:ring-focus` (2px neutral ring) |
| Buttons | `bg-button-primary`/`-secondary`/`-destructive` + `hover:bg-button-*-hover`, ghost/outline hovers `bg-button-ghost-hover`/`bg-button-outline-hover` (full recipes in `guidelines/components/formulaires-saisie.md`) |

Raw palette (`bg-gray-100`, `text-red-700`, 11 scales × 25–900 in `tokens/tokens.md`) is for
data viz and illustrations only — chrome always uses the semantic roles above.

## Shape, elevation, spacing

- Radius: `rounded-md` (8px) for buttons, inputs, menu items; `rounded-lg` (10px) for cards,
  panels, popovers; `rounded-full` for pills, avatars, icon dots.
- Elevation: `shadow-border-{xs,sm,md,lg,xl}` — shadow plus a 1px hairline. Cards sit flat
  (`border-primary` or `shadow-border-xs`); menus/popovers float with `shadow-border-md`;
  dialogs/sheets with `shadow-border-lg` or `-xl`. Plain `shadow-*` exists but the paired
  `shadow-border-*` is the house style.
- Spacing rhythm: `gap-2` icon↔label, `gap-1.5` compact; `p-4`/`p-6` card padding; `gap-4`/
  `gap-6` between sections; `space-y-1` menu lists. Controls are h-8 (`sm`) / h-9 (default) /
  h-10 (`lg`).

## Typography

`font-sans` = Geist with system fallback (no webfont ships — system stack in practice);
`font-mono` = IBM Plex Mono stack for code, kbd, amounts in tables. Weights: 400/500/600
(`font-normal`/`font-medium`/`font-semibold`) — nothing heavier.

| Level | Classes |
| --- | --- |
| h1 | `text-4xl font-semibold tracking-tight text-primary` |
| h2 | `text-3xl font-semibold tracking-tight text-primary` |
| h3 | `text-2xl font-semibold tracking-tight text-primary` |
| h4 / page section | `text-xl font-semibold tracking-tight text-primary` |
| Lead | `text-lg text-secondary` |
| Body | `text-sm leading-relaxed text-primary` (the app is text-sm-first) |
| Muted / caption | `text-sm text-secondary`, `text-xs text-subdued` |
| Code | `rounded bg-surface-inset px-1.5 py-0.5 font-mono text-sm text-primary` |

## Icons

Lucide, inlined as SVG with `stroke="currentColor"`, default `class="size-4"` — they size and
color like text (engineers call `lucide_icon "plus"`). Stick to the vendored set:
arrow-left, arrow-right, baby, bell, book-open, cake, calendar, car, carrot, check, chef-hat,
clock, credit-card, droplet, dumbbell, euro, file-text, gift, grip-vertical, handshake,
heart-pulse, house, layout-dashboard, layout-grid, link, list, list-checks, luggage, mail, map,
map-pin, message-circle, milk, minus, notebook-pen, package, paw-print, pencil, phone, pill,
plus, puzzle, recycle, refresh-cw, refrigerator, repeat, scale, search, settings, shopping-cart,
smartphone, sofa, sprout, square-check, star, sun, syringe, trash-2, trees, triangle-alert,
users, users-round, utensils, waves, wine, wrench, x.

## Dark mode

Add `class="dark"` on `<html>` — every semantic token swaps (near-black `--background`,
gray-900 containers, white primary text). A design built only from semantic classes needs zero
extra work to support it; that's the test of doing it right.

## Motion

Floating panels animate with `animate-in fade-in-0 zoom-in-95` on open (`animate-out
fade-out-0 zoom-out-95` on close), sheets/drawers with `slide-in-from-{top,bottom,left,right}`,
accordions with `animate-accordion-down/up`. Durations 150–300ms (`duration-200` etc.).
