# GameDiscoveries Mobile

Official Flutter mobile application for GameDiscoveries.

## Purpose

GameDiscoveries Mobile is a native Flutter application for:

- discovering games
- exploring game details
- playing HTML5 games inside a controlled WebView
- tracking session lifecycle against the existing backend
- showing progress, XP, missions, streaks, achievements, leaderboard, and community data

This app is not a WebView wrapper for the website. The backend remains the source of truth for all authoritative game and gamification logic.

## Current Status

This repository has completed:

- Phase 0 repository discovery
- initial API audit
- initial mobile architecture definition
- Phase 1 Flutter foundation scaffold
- Phase 3 networking (Dio `ApiClient`, envelope + pagination parsing, bearer interceptor, secure token storage)
- Phase 4 auth shell (session restore via `GET /api/v1/users/me`, guest fallback)
- Phase 5 first Home/Discovery integration (`GET /api/v1/discoveries/home`, `GET /api/v1/games`)
- Phase 6 full UI (dark + gold design): splash, onboarding, login/register, 5-tab shell (Home, Discover, Play, Missions, Profile), game detail, WebView player with backend session lifecycle, progress, achievements, leaderboard, community, notifications, favorites, history

Known API gaps (not implemented in the app): "My Reviews" list, profile edit (only `PUT /api/v1/users/me/privacy` exists), per-game rating/play count in list responses.

See:

- `docs/backend-api-map.md`
- `docs/mobile-architecture.md`

## Requirements

- Flutter `3.44.8`
- Dart `3.12.2`

## Development

Install dependencies:

```bash
flutter pub get
```

Run the app:

```bash
flutter run
```

Run analysis:

```bash
flutter analyze
```

Run tests:

```bash
flutter test
```

## Environment

The project is prepared to consume compile-time config through `--dart-define`.

Available keys:

```text
APP_ENV
API_BASE_URL
```

Example:

```bash
flutter run --dart-define=APP_ENV=development --dart-define=API_BASE_URL=https://api.gamediscoveries.com
```

Reference env presets are stored in:

- `.env.development`
- `.env.staging`
- `.env.production`

## Architecture

The app uses:

- Flutter
- Material 3
- Riverpod
- GoRouter

Planned architecture style:

- Clean Architecture
- feature-first folders
- repository pattern
- typed API layer
- backend-authoritative gamification

## Backend Dependency

The mobile app depends on the existing `gamediscoveries-api` backend. Do not duplicate business logic in Flutter for:

- XP calculation
- level progression
- streak validation
- mission completion
- leaderboard ranking
- recommendation scoring
- authoritative play-session validation

## Immediate Next Steps

1. Expand app foundation into typed config, network layer, and auth shell.
2. Implement session-safe API client and secure storage.
3. Begin auth and home/discovery integration using audited endpoints.
