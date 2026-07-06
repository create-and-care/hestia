# Hestia — mobile client (skeleton)

Hestia's Flutter/Dart mobile client (Spec §14): a thin client consuming the
Rails `api/v1` API, with no business logic of its own — every business rule
lives server-side, for identical behavior with the web client.

## Status

**A minimal skeleton**, not a functional app: project structure, an HTTP
client (`ApiClient`), an API-token login screen, and a first read-only
"Shopping" screen. A starting point, not a deliverable.

**Still to build**, before any real functional parity:

- Screens for the other 24 modules (Spec §9 to §12).
- Native camera access (barcode scanning, document capture).
- Voice dictation, push notifications, contact import.
- Offline mode (reading already-synced data).
- A real-time connection (WebSocket to Solid Cable) — currently only
  one-off HTTP on the client side.
- Transparent token renewal / re-authentication.

## Prerequisites

The Flutter SDK (stable) — not installed in the development environment
where this skeleton was created; the code has therefore not been run or
tested with `flutter run` or `flutter analyze`.

## Getting started

```sh
cd mobile
flutter pub get
flutter run
```

On login, the screen asks for the Hestia instance's URL (e.g.
`https://my-household.example.com`) and an API token, generated from the
web app at `/api_tokens` (Dashboard → API Tokens).
