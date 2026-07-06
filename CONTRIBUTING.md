# Contributing to Hestia

Thanks for your interest in Hestia. The project is open to external
contributions, following the example of the [Sure](https://github.com/we-promise/sure)
project, which inspires its governance: everything is free, everything is
open-source, no paid tier hiding behind a rejected contribution.

## Before contributing

- For a minor change (typo, small bug), a direct pull request is enough.
- For a new feature or a behavior change, open an issue first describing
  the need, linking it if possible to the relevant module in the
  [Specification](<Specification — Hestia.md>) and the
  [Implementation Plan](<Implementation Plan — Hestia.md>).
- The architecture decisions settled in the Spec (section 4) and the four
  documented deviations (section 5: Circles, Gifts, Trip, Wellbeing) are
  settled choices: any proposal that departs from them should be discussed
  in an issue before implementation.

## Development environment

Prerequisites: Ruby `3.4.9` (`.ruby-version`), Node `20.11.1`
(`.node-version`), PostgreSQL (`docker compose up -d` provides a local
instance).

```sh
bin/setup     # install dependencies, prepare the DB
bin/dev       # Rails server + esbuild/Tailwind watchers
```

On Windows, use WSL2 (Ubuntu) rather than native Ruby — see Spec §4.

## Code conventions

- **Ruby style**: [Rails Omakase](https://github.com/rails/rubocop-rails-omakase)
  via RuboCop (`.rubocop.yml`). No custom style beyond this baseline.
- **UI**: reuse the existing components under `app/components/ui/`
  (a shadcn-style library, browsable at `/design-system`) rather than
  writing ad hoc HTML/Tailwind. If a component is missing, add it to the
  library rather than duplicating a one-off pattern.
- **Household scoping**: any new data must be scoped via the
  `HouseholdScoped` concern and filtered by `Current.household`, never by
  a client parameter — except for the four modules with an architecture
  deviation documented in Spec §5.
- **Business logic**: prefer a per-domain service object
  (`app/services/<Module>::<Action>`, e.g. `Courses::AddItem`) over a dense
  controller or model. This is what will let Hest.AI (Phase 3) invoke this
  same logic as a tool, without duplicating business code.
- **Real-time**: any create/update/delete visible in a list should
  broadcast via `broadcasts_to` / `broadcasts_refreshes_to` (Solid Cable),
  the same way already-shipped modules do.

## Tests

Every pull request must stay green on the four CI checks
(`.github/workflows/ci.yml`):

```sh
bin/rails test           # models, controllers, services
bin/rails test:system    # system tests (Capybara)
bin/rubocop               # style
bin/brakeman               # static security
bin/bundler-audit           # dependency vulnerabilities
```

A new module or feature should ship with model + controller tests (+ a
service test where relevant), following the 83+ test files already present
under `test/`.

## Pull requests

- One pull request, one topic. Avoid mixing a feature with an unrelated
  refactor.
- Describe the *why* of the change, not just the *what* (the diff already
  speaks for the *what*).
- Explicitly flag any deliberate deviation from the Spec or the
  Implementation Plan, and propose the matching update to both documents in
  the same pull request.

## License of contributions

By submitting a contribution, you agree that it will be distributed under
the terms of the project's [AGPLv3](LICENSE) license.
