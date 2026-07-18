# Building with Hestia — conventions

Hestia has **no JS component bundle** — do not import components from a global or an npm
package. Its components are server-rendered Rails ViewComponents; you rebuild them in your
designs by **copying the rendered markup patterns** in `guidelines/components/*.md` (real HTML
whose classes all resolve against `styles.css`) and annotating each with its `Ui::*Component`
name so engineers can swap in the real component 1:1.

## Setup

- `styles.css` provides everything: tokens, utilities, base styles. No provider or wrapper is
  needed. `body` already gets `bg-surface text-primary font-sans`.
- Dark mode: set `class="dark"` on `<html>` (or the design root). Semantic classes swap
  automatically — **never use `dark:` variants**; if you styled with the semantic vocabulary
  below, dark mode is free.
- All UI copy is **French** (sentence case, `« … »`, amounts like `1 284,90 €`).

## Styling idiom — Tailwind utilities, semantic first

Chrome uses **semantic classes**, never hardcoded grays:

- Surfaces: `bg-surface`, `bg-surface-hover`, `bg-surface-inset`, `bg-container`,
  `bg-container-hover`, `bg-container-inset` (+ `-inset-hover` forms), overlay `bg-overlay`
- Text: `text-primary` / `text-secondary` / `text-subdued` / `text-inverse`, links `text-link`
- Borders: `border-primary` / `border-secondary` / `border-subdued` / `border-divider`,
  focus `focus-visible:ring-focus`
- Status: `text-success|warning|destructive|info`, tints `bg-success/10` `bg-warning/10`
  `bg-destructive/10`, `border-destructive`
- Buttons: `bg-button-primary|secondary|destructive` + `hover:bg-button-*-hover`,
  `bg-button-ghost-hover`, `bg-button-outline-hover`, disabled `bg-button-disabled`
- Elevation: `shadow-border-xs|sm|md|lg|xl` (shadow + 1px hairline — the house style);
  radius `rounded-md` (controls) / `rounded-lg` (panels)
- Motion: `animate-in fade-in-0 zoom-in-95`, `slide-in-from-*`, `animate-accordion-down|up`

Layout glue is standard Tailwind (`flex`, `grid`, `gap-*`, `p-*`, `w-*`, `text-sm`, …). A wide
but **fixed** vocabulary is compiled in — **arbitrary values (`w-[13px]`, `bg-[#fff]`,
`text-[11px]`) do not exist**; if a class isn't in `styles.css` or the markup patterns, pick
the nearest one that is. Raw palette classes (`bg-gray-100`, `text-red-700`, scales 25–900)
are for data viz only. Icons: Lucide inline SVG, `class="size-4"`, `stroke="currentColor"`.

## Where the truth lives

- `guidelines/components/*.md` — 63 components in 6 files: purpose, Rails API (props/slots),
  canonical ERB, **rendered HTML to mirror exactly**
- `guidelines/design-language.md` — color roles, type scale, spacing, icon list
- `tokens/tokens.md` — every token with its value; `styles.css` — the compiled ground truth

## Example — a Hestia card with actions

```html
<div class="bg-container border border-primary rounded-lg p-6 max-w-sm">
  <h3 class="text-xl font-semibold tracking-tight text-primary">Budget de juillet</h3>
  <p class="mt-1 text-sm text-secondary">Il reste 715,10 € à dépenser ce mois-ci.</p>
  <div class="mt-4 flex items-center justify-between">
    <span class="inline-flex items-center rounded-md px-2 py-0.5 text-xs font-medium gap-1 bg-success/10 text-success">Actif</span>
    <!-- Ui::ButtonComponent variant=:default size=:sm -->
    <button type="button" class="inline-flex items-center rounded-md font-medium transition-colors focus-visible:ring-focus bg-button-primary text-inverse hover:bg-button-primary-hover h-8 px-3 text-sm gap-1.5">Voir le détail</button>
  </div>
</div>
```
