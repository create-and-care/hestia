# design-sync notes — Hestia

## 2026-08-12 re-sync — 21 icons missing across three syncs; Badge divergence closed upstream

**This file was stale again.** Its newest entry was 2026-08-07, but the live project's own `github.md`
recorded a later sync (**2026-08-09T20:30Z**, a token pass). As that entry below already warns:
`github.md` in the project is the source of truth for sync history, not this file. Read it first,
every time — the date in its `## Last sync` header is the real baseline.

That timestamp gave this sync something no previous one had: **a dated baseline**. The last commit
before it is `6a9bad5`, so the drift is exactly `git diff 6a9bad5..HEAD` over
`app/components/ui/ app/assets/stylesheets/ app/assets/icons/ app/assets/images/ app/views/design_system/`
— 15 files, 13 of them icons. Use that command next time instead of reading files speculatively.

**The real find: 21 Lucide icons had never been uploaded** (project had 76, repo has 97). Only 13
came from this window; **8 had been missing since 2026-08-02** (`menu`) through 2026-08-07
(`chevron-right`, `log-out`, `panel-left-close`, `panel-left-open`, `user` — the `d014a4e` sidebar
commit) and 2026-08-09 (`external-link`, `eye`). Three consecutive syncs missed them because each
one focused on components or tokens and **verified the icon count by reading the readme's own prose**
— which was itself stale, and internally inconsistent (the readme said 75 in one section and 76 in
another; the iconography card said 75; the truth was 76). Same failure shape as the 2026-08-07 logo
miss: trusting a document's claim about a file instead of checking the file.

**→ The rule: verify the icon set with a list diff, never by reading prose.**
```
ls app/assets/icons/lucide/ | sed 's/\.svg$//' | sort > /tmp/local.txt
# vs the project's assets/icons/lucide/* from DesignSync list_files
comm -23 /tmp/local.txt /tmp/remote.txt   # missing from the project
```

**`Badge#urgent` divergence is closed — by upstream, in the expected direction.** The 2026-08-09
entry removed `urgent` from the project and recorded it as a deliberate divergence ("upstream keeps
it; if the repo wants to align, that's a deletion in `badge_component.rb`"). Upstream did exactly
that hours later: `eb10f66` drops `urgent:` from `VARIANTS`, `8a0d3b6`/`5e9807f` rename the
`:urgent` status to `:destructive` across helpers/models, `0f46948` fixes the leftover mappings.
Both sides now have the same 7 variants — **no code change was needed**, only prose.

**Doc drift corrected in the project** (each verified against `application.tailwind.css` first):
- `readme.md` described the nav active state as `transparent → --surface-hover → --surface-inset`.
  That is **the exact bug fixed on 2026-08-02** (`--surface-inset` is ~1.5 ΔE from hover in light and
  *identical* to it in dark); `--item-active` has existed in the repo since. The doc was telling a
  design agent to reproduce the defect. Rewritten.
- `verification-checklist.md` §2 said `--text-subdued: #7A6B61` (abandoned intermediate; repo says
  `#72645C`) and §8 listed `--destructive-text` as crimson-700/300 (repo: crimson-800/200) — both
  contradicted by correction bullets *lower in the same file*.
- Its "known open points" still claimed `logo.png` is 0 bytes (false since 2026-08-05) and that the
  illustrations were undelivered (false since 2026-08-02).

### ⚠️ The project is AHEAD of `main` on two things — and the port landed mid-run
The live project was edited on 2026-08-12 (before this sync ran) with two intentional design
decisions, the same pattern as Terre cuite before 2026-08-01:
- **`pine-*` scale; `--link` = pine-700, `--link-hover` = pine-800.**
- **`--font-display` = Instrument Serif, replacing Caveat.**

Both were absent from committed `main` (`31c11bb`) — verified directly: `--link: var(--color-blue-700)`,
no `pine-*`, Caveat still imported, `.greeting` at weight 600. **But partway through this run the
working tree gained all of it**: the full `--color-pine-25→900` ramp, `--link`/`--link-hover` on
pine-700/800 (light) and pine-300/200 (dark), the Instrument Serif `@import`, `--font-display`,
`--font-hand` reduced to an alias, `.greeting` back to weight 400 — plus edits to
`greeting_header_component.rb`, `celebration_moment_component.html.erb`, `empty_component.html.erb`
and `design-language.md`. Uncommitted at the time of writing.

**Lesson for the next run: `git status` before trusting a "diff since baseline".** The initial status
snapshot showed one modified file; by mid-run there were thirteen. The project docs were reworded to
say "not on `main` at sync time, port written but uncommitted — recheck `main`" rather than "upstream
hasn't done it", precisely so they don't read as false the moment this gets committed.

Uploaded this pass: 21 icons + `guidelines/iconography.html` (subtitle 75→97), `readme.md`,
`guidelines/verification-checklist.md`, `github.md`. No components or tokens changed.

## 2026-08-07 re-sync — real logo mark caught (missed by a same-day sync)

Same manual process as prior re-syncs: read `github.md` in the live project first — it recorded a
sync from earlier the same day (2026-08-07T07:07Z) that confirmed 75/75 component parity and ported
two upstream fixes (`.on-tone` rule, `Badge` `urgent` variant). All commits on `main` since then were
non-design-system (dependency bumps, a flaky-test fix, `package-lock.json`/`yarn.lock` housekeeping,
two analysis-doc commits) — confirmed via `git log --oneline --name-only`, none touch
`app/components/ui/` or `application.tailwind.css`.

One real miss survived that morning sync: `app/assets/images/logo.png` has been a real 75KB PNG
(flat clay house + amber sun, 480×360) since commit `7b38a0c` (2026-08-05) — used live in
`shared/_sidebar_brand.html.erb` and reused as `public/icon.png` (apple-touch-icon, PWA manifest).
The live project's `readme.md` still called it "a 0-byte empty file". Caught by cross-checking the
file's actual bytes/usage against the readme's specific claim, not by trusting the fresh sync note.

Fixed: uploaded `assets/logo.png`; `readme.md`'s "Sources & caveats" section rewritten to describe
the real mark (and to keep the still-true half — `public/icon.svg`, the `<link rel="icon">` target,
remains a placeholder red circle, untouched); `thumbnail.html` now pairs the mark with the wordmark
instead of type-only; `ui_kits/hestia-app/index.html` sidebar header swapped its placeholder Lucide
`house` icon for the real logo image. Also fixed an unrelated bug found while touching that file: a
stray duplicate `</Sidebar>` closing tag that would have broken the app-shell card's Babel parse.
Full record in the project's own `github.md` ("2026-08-07 (2)").

## 2026-08-02 re-sync — component + illustration reconciliation

Same manual process as 2026-08-01 (no local build exists for this project — `get_file` the
plausibly-drifted remote files, diff by hand against the Ruby source, `write_files` only what
changed). Repo was 3 commits ahead of the last sync's `a247619` (up to `385deaa`). Full details
in the project's own `github.md` ("Updated in this project", 2026-08-02 entry) — summary:

- `Chart.jsx`/`.d.ts`/`.prompt.md` updated for the new `variant: :line` mode
  (`chart_component.rb`/`.html.erb`) and `color:` param. Also fixed the bar-mode `COLORS` array,
  which had drifted from the real `bg-module-{tasks,recipes,fridge,wellbeing,gifts}` order — a
  pre-existing bug, not introduced this pass, just never caught before.
- `Bubble.jsx` max-width updated for `max-w-[75%]` → `max-w-[85%] sm:max-w-md`
  (`bubble_component.rb`). This system's components are inline-style-only (no breakpoints), so
  `maxWidth: "min(85%, 28rem)"` approximates the two-value Tailwind rule in one expression —
  watch for this gap (no responsive mechanism) if a future upstream change is breakpoint-specific.
- The 4 illustrations from `guidelines/illustration-brief.md` shipped for real
  (`app/assets/images/illustrations/*.png`, previously an empty `.keep`-only dir). Uploaded as
  `assets/illustrations/*.png`; `guidelines/illustration-system.html` rewritten from 4 empty
  interactive `<image-slot>` placeholders to plain `<img>` tags showing the real shipped assets —
  they're production-final now, not something a designer should still be dropping exploratory
  images onto. Updated the brief's "Livraison" section and readme.md's "Illustration system"
  section to match (delivered, not fillable).
- Breadcrumb usage expanded to ~30 more views this pass, but `Ui::BreadcrumbComponent` itself is
  unchanged since `v1.0.0-beta4` — confirmed via `git log`, nothing to sync there. Same for the
  other repo changes in this range (workout-template feature, locale trims): outside this
  system's surface.

## ⚠️ 2026-08-01 correction — the live project is NOT style-only

Everything below this notice (originally written 2026-07-16/17, "Confirmed with the user") describes
a **style + guidelines only** sync to project `95819b9c…` ("no JS/React component package... which
design-sync forbids"). That project **no longer exists** (404 on lookup, 2026-08-01) — the user
pointed this sync at a different, pre-existing project instead: `1c75ab45-1fc4-45da-9051-63a9b2824922`
(same name, "Hestia Design System"). **That live project is a full 73-component off-script React
recreation** — one `.jsx` + `.d.ts` + `.prompt.md` + `*.card.html` per component, a real
`_ds_bundle.js`, `_ds_manifest.json`, vendored Lucide icons, and an app-shell `ui_kits/` demo —
built by hand directly in Claude Design (or by an agent working directly against the tool), **not**
by any script in this directory. There is no local `.jsx` source in this repo for it at all.

**Implication for every future sync**: the `config.json.shape` is now `"offscript-component-recreation"`,
not `"style-only"`. The pipeline documented below (steps 1–8, `build-tokens.mjs`, `build-guidelines.mjs`,
`extract.rb`, `validate-*.mjs`) was **never used to build the live project** and produces a
completely different, incompatible artifact set (no `components/`, no `_ds_bundle.js`). **Do not run
it expecting to update the live project** — it would need a brand-new project, and even then would
regress the live one from full component fidelity down to tokens+guidelines only. It's left in place
below only as a historical record and in case a from-scratch style-only project is ever wanted again.

**What a real re-sync of the live project looks like** (done once, 2026-08-01, in response to the
"Terre cuite" rebrand landing in `app/components/ui/` — commits 44d8529/9d582b2/521b3f7 on
`design-system-v2`): `get_file` every remote token/component file that plausibly drifted, diff
against the current Ruby source by hand, `write_files` only what actually changed. Nothing scripted
— there's no local build to run. In that pass, tokens/CSS/jsx were found to **already match** the
post-rebrand Ruby exactly (byte-identical hex values in `tokens/colors.css`/`tokens/spacing.css`;
every checked `.jsx` — Button, Card, Item, Select, Checkbox, Avatar, AvatarGroup, AlertDialog, Empty,
Skeleton, Accordion, Message, Switch, Slider, Table, InputOtp, Menubar, Popover, ContextMenu — already
had the new control heights/radii/shadow-border treatment). The only real drift was **prose that
called the direction and the 4 brand components (`ModuleMedallion`, `GreetingHeader`,
`CelebrationMoment`, `HouseholdHeader`) speculative "intentional additions, no Ui:: equivalent"**,
when upstream had since implemented all of them for real (plus `Empty#illustration`, `Avatar#tint`,
the `clay-*`/`crimson-*` scales, and the Google Fonts CDN `@import` — all now literally in
`application.tailwind.css`). Fixed: `readme.md`, the 4 brand components' `.jsx`/`.prompt.md`,
`guidelines/colors-brand.html` (still said "Indigo brand"), `tokens/fonts.css` comment, `SKILL.md`
(69→73), `github.md` sync record. Two tiny real code-drift fixes: `Tabs.jsx` active-tab shadow
compounded with the hairline border (matching new `shadow-border-xs`); `ViewToggle.jsx` gained
`aria-current` to match the upstream a11y fix. See `github.md` in the project itself for the full
sync record going forward — it's a better source of truth than this file for that project's history.

The `readmeHeader` config key and `conventions.md`/`design-language.md` below are vestigial for this
project — nothing in the live project's `readme.md` is generated from them; it's hand-maintained
directly in the project. They're harmless to keep in case a style-only project is built later.

---

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
