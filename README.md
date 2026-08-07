# Hestia

A free, collaborative household management app — a complete, free, and
self-hostable alternative to existing freemium everyday-life management
apps.

A household groups several members (a couple, a family, roommates) who
share the same modules in real time: shopping, calendar, recipes, fridge,
tasks, and about twenty other everyday domains (notes, birthdays,
addresses, loyalty, pets, vehicles, wine cellar, waste, baby, messages,
menu, routines, outdoor, budget, documents, gifts, circles, trip,
wellbeing...).

Unlike equivalent commercial apps, Hestia caps no feature behind a
subscription: the code is public under the [AGPLv3](LICENSE) license, and
anyone can host their own instance without depending on a third-party
service or paying anything.

For each module's functional detail and the project's shipped/planned
work, see the in-app **Roadmap** (`/roadmap`, reachable without an
account) — a chronological timeline kept current with every release,
superseding the separate Specification/Implementation Plan documents
this project started from.

## Contents

- [Tech stack](#tech-stack)
- [Quick start (Docker)](#quick-start-docker)
- [Local development](#local-development)
- [Tests and quality](#tests-and-quality)
- [Mobile client](#mobile-client)
- [Repo structure](#repo-structure)
- [Contributing](#contributing)
- [License](#license)

## Tech stack

| Area | Choice |
|---|---|
| Backend / Web | Ruby on Rails 8.1 |
| Database | PostgreSQL |
| Real-time | Hotwire (Turbo + Stimulus) + Solid Cable |
| Async jobs | Solid Queue |
| Cache | Solid Cache |
| UI | ViewComponent (shadcn-style library, 75 components) + Tailwind v4 |
| Mobile | Flutter/Dart (skeleton, consumes the `api/v1` API) |
| Deployment | Docker / Kamal |

No dependency on Redis/Sidekiq: Solid Queue/Cable/Cache run on the existing
PostgreSQL database, which keeps self-hosting down to a single app process.

## Quick start (Docker)

```sh
docker compose up -d          # start PostgreSQL
bin/setup                     # install dependencies, prepare the DB, start the server
```

The app is then available at `http://localhost:3000`.

For a self-hosted production deployment, see `config/deploy.yml` (Kamal)
and the `Dockerfile` at the repo root.

## Local development

Prerequisites: Ruby `3.4.9` (see `.ruby-version`), Node `20.11.1` (see
`.node-version`), PostgreSQL.

```sh
bin/setup   # install gems/JS packages, prepare the DB
bin/dev     # run the Rails server + esbuild/Tailwind watchers (Procfile.dev)
```

The UI component library can be browsed at `/design-system`.

## Optional integrations

None of these are required to run the app — each is closed/inert until configured.

**External calendar sync** (Google, Microsoft, CalDAV): encrypts OAuth tokens
at rest, so generate the instance's encryption keys once and add them to
credentials:

```sh
bin/rails db:encryption:init   # prints 3 keys
bin/rails credentials:edit     # paste them under `active_record_encryption:`
```

Google/Microsoft additionally need an OAuth application registered with the
provider (redirect URI `https://<host>/external_calendar_connections/<provider>/callback`),
configured via either environment variables (`GOOGLE_CLIENT_ID`/`GOOGLE_CLIENT_SECRET`,
`MICROSOFT_CLIENT_ID`/`MICROSOFT_CLIENT_SECRET` — convenient for a Docker
deployment) or `bin/rails credentials:edit` (`google:`/`microsoft:` `client_id`/`client_secret`).
CalDAV needs no such registration — a user connects directly with their
server URL, username, and password from `/external_calendar_connections`.

**Error tracking**: set `SENTRY_DSN` (or `bin/rails credentials:edit` ->
`sentry: dsn:`) to a Sentry or self-hosted GlitchTip project's DSN.

**Solid Queue admin UI** (`/jobs`): closed by default. Enable with
`bin/rails credentials:edit` -> `mission_control: http_basic_auth_user:`/`http_basic_auth_password:`.

## Tests and quality

```sh
bin/rails test           # Minitest suite (models, controllers, services)
bin/rails test:system    # system tests (Capybara)
bin/rubocop               # style (Rails Omakase)
bin/brakeman               # static security analysis
bin/bundler-audit           # known gem vulnerabilities
```

These four commands run in CI on every pull request
(`.github/workflows/ci.yml`).

## Mobile client

A Flutter/Dart skeleton consuming the `api/v1` API lives in
[`mobile/`](mobile/README.md). It isn't a functional app yet — see that
README for what's left to build.

## Repo structure

```
app/            Rails application (controllers, models, views, Ui:: components, services)
config/         routes, environments, initializers
db/             schema and migrations
mobile/         Flutter/Dart client (skeleton)
test/           Minitest suite
```

## Contributing

External contributions are welcome — see [CONTRIBUTING.md](CONTRIBUTING.md)
for the development environment, code conventions, and pull request
process.

## License

Hestia is distributed under the [GNU AGPLv3](LICENSE) license. Any modified
instance made available to users over a network must release its
modifications under the same license.
