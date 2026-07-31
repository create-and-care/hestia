# design-sync notes — Hestia

- Hestia's design system is **Rails ViewComponents** (`app/components/ui/`, ~110 files, Ruby + ERB),
  styled with Tailwind v4 and animated by Stimulus controllers. There is no JS/React component
  package, no Storybook, no `dist/` — so the standard component sync (`_ds_bundle.js` +
  per-component `.d.ts`/previews) is **not possible without reimplementation**, which design-sync
  forbids. Confirmed with the user 2026-07-16.
- Scope chosen by user: **style + guidelines sync** (`shape: "style-only"` in config.json).
  Uploads: `styles.css` (token closure + compiled app CSS), `tokens/`, `guidelines/`
  (component inventory + design language as prose), `README.md`. No `_ds_bundle.js`,
  no `components/`, no `_ds_sync.json` anchor (nothing to hash-anchor; every future sync
  re-verifies, which is correct).
- Tokens live hand-edited in `app/assets/stylesheets/application.tailwind.css` (`@theme` block +
  `.dark` overrides). Tailwind v4, built via `npm run build:css` (@tailwindcss/cli) into
  `app/assets/builds/application.css`.
- Fonts: Geist / IBM Plex Mono are named first in the stacks but **no font files ship in the repo**
  and the layout loads none — the app falls back to system fonts. Nothing to upload under `fonts/`.
- If a React/JS twin of Hestia ever exists, re-run /design-sync against it for the full
  high-fidelity component sync (user was offered this path).

## Re-sync pipeline (run from repo root, in order)

1. `npm run build:css` — rebuild the app CSS (sanity that the theme compiles).
2. `node .design-sync/build-tokens.mjs` — ds-bundle/tokens/{theme.css,tokens.md}. ASSUMPTION:
   the three top-level blocks of application.tailwind.css close with `}` at column 0.
3. `npx @tailwindcss/cli -i .design-sync/sync-entry.css -o ds-bundle/_ds_bundle.css --minify`
   — app CSS + forced core-utility vocabulary (see sync-entry.css; arbitrary values like
   `w-[13px]` are NOT available to designs — conventions.md warns about this).
4. `bin/rails runner .design-sync/extract.rb` — registry JSON + 63 previews rendered to
   static HTML in .design-sync/out/ (gitignored).
5. `node .design-sync/build-guidelines.mjs` — ds-bundle/guidelines/ + README.md (stitches
   .design-sync/conventions.md as header; copies design-language.md).
6. `node .design-sync/validate-conventions.mjs` && `node .design-sync/validate-previews.mjs`
   — gates: every class named in authored docs and every class in every markup pattern must
   resolve in the shipped CSS closure; icons must be vendored.
7. Visual check: `node .design-sync/out/assemble.mjs` batches the 67 previews (12/page) into
   `.design-sync/out/assembled-<N>.html` linking `ds-bundle/styles.css` (dark: same file with
   `<html class="dark">`, e.g. via `sed`). Screenshot with the cached Chrome for Testing binary
   directly — no puppeteer npm package needed:
   `~/.cache/puppeteer/chrome/*/chrome-mac-arm64/Google Chrome for Testing.app/Contents/MacOS/Google Chrome for Testing`
   `--headless --disable-gpu --window-size=1400,6000 --screenshot=out.png file://.../assembled-N.html`.
   window-size height must exceed the batch's real content height or the shot clips silently —
   6000px was enough margin for 12-item batches; watch for silent clipping if batch size grows.
   Stimulus-driven previews with no static markup (calendar's day grid) render empty in this
   harness since no JS executes — expected, not a bug; only affects components whose content is
   built by their controller's `connect()` rather than present in the ERB.
8. Upload ds-bundle/ (styles.css, _ds_bundle.css, tokens/**, guidelines/**, README.md).
   No `_ds_sync.json` anchor is produced (style-only shape has no per-component verification
   to skip) — every sync re-verifies everything, which is cheap here.

## Bugs found in the repo during re-sync (2026-07-31, fixed in working tree)

- `app/views/design_system/previews/_code-block.html.erb` used `@entry.slug` — copied from
  `component.html.erb` (the controller-action view, which sets `@entry`), but extract.rb renders
  previews standalone via `ApplicationController.render(partial:)`, which never sets `@entry`.
  Every other preview partial hardcodes its own slug string; this one alone didn't. Broke the
  whole extract step (`undefined method 'slug' for nil`). Fixed by hardcoding
  `design_system_source("code-block")`. Watch for this pattern if new previews are copy-pasted
  from `component.html.erb`.
- Repo grew from 63 to 67 registry entries since the 2026-07-17 sync (4 new components added).
  All 67 previews now render and pass both validators.

## Bugs found in the repo during first sync (2026-07-17, fixed in working tree)

- 4 docs preview partials (`_button`, `_badge`, `_button-group`, `_item`) used
  `render Ui::X.new(...) { "label" }` — the brace-block binds to `.new` and Ruby drops it, so
  the docs site rendered those components EMPTY. Fixed by parenthesizing: `render(Ui::X.new(...)) { }`
  (the form the app views already use). Watch for this footgun in new previews.
- 3 dead utility classes (never generated by Tailwind, silently unstyled in the real app):
  `checked:border-button-primary` (checkbox), `bg-tab-bg-group` (tabs — utility is named
  `bg-tab-group`), `hover:bg-border-primary` (resizable). Fixed by adding the two missing
  `@utility` definitions (`border-button-primary`, `bg-border-primary`) to
  application.tailwind.css and renaming the tabs class to `bg-tab-group`.
  `validate-previews.mjs` now guards against regressions of this kind.
