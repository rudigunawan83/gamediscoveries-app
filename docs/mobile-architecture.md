# GameDiscoveries Mobile Architecture

Dokumen ini merangkum hasil Phase 0 dan mendefinisikan fondasi arsitektur untuk aplikasi Flutter `gamediscoveries-mobile`.

## Product Positioning

GameDiscoveries mobile bukan WebView wrapper dari web utama. Aplikasi ini adalah native Flutter app yang:

- menampilkan discovery experience secara native
- mengelola auth, state, cache, analytics, dan navigation secara native
- memakai WebView hanya untuk HTML5 game player
- menjaga backend sebagai otoritas tunggal untuk session, XP, level, streak, missions, achievements, ranking, dan recommendation result

## Architecture Principles

1. Backend is authoritative.
2. Flutter is presentation and interaction layer.
3. Clean Architecture + feature-first modules.
4. Typed API models, tidak ada magic JSON di UI.
5. Anonymous mode tetap berguna untuk discovery dan play.
6. Offline cache hanya untuk read models dan replay queue yang aman.
7. WebView diisolasi sebagai player surface, bukan tempat logic bisnis.

## Mobile Architecture Diagram

```text
┌────────────────────────────────────────────────────────────┐
│                    Flutter Presentation                    │
│  Screens / Widgets / GoRouter / Material 3 / Theme        │
└─────────────────────────────┬──────────────────────────────┘
                              │
                              ▼
┌────────────────────────────────────────────────────────────┐
│                    Riverpod State Layer                    │
│  Providers / Notifiers / Async state / Derived selectors  │
└─────────────────────────────┬──────────────────────────────┘
                              │
                              ▼
┌────────────────────────────────────────────────────────────┐
│                 Domain + Application Layer                 │
│  Use cases / Entities / Repository contracts / Policies    │
└─────────────────────────────┬──────────────────────────────┘
                              │
                    ┌─────────┴─────────┐
                    ▼                   ▼
┌──────────────────────────────┐   ┌─────────────────────────┐
│        Remote Data           │   │       Local Data        │
│ Dio / API client / DTOs      │   │ Hive/Isar / SecureStore │
│ Auth interceptor / retries   │   │ Cache / queue / flags   │
└───────────────┬──────────────┘   └────────────┬────────────┘
                │                               │
                └──────────────┬────────────────┘
                               ▼
┌────────────────────────────────────────────────────────────┐
│                GameDiscoveries Backend API                 │
│  Auth / Catalog / Session / XP / Missions / Community     │
└────────────────────────────────────────────────────────────┘
```

## Feature Map

### Core

- Auth
- Home
- Discovery
- Search
- Game Detail
- Game Player
- Favorites
- History

### Gamification

- Progress / XP
- Missions
- Streak
- Achievements
- Leaderboard
- Recommendations

### Social

- Community
- Notifications
- Profile

### Platform

- Analytics
- Connectivity
- Local cache
- Secure storage
- Environment config
- Error handling

## Navigation Map

```text
/splash
  └─ decide onboarding / auth restore / guest home

/onboarding
  └─ login | register | continue as guest

/login
/register

/home
  ├─ /discover
  ├─ /search
  ├─ /missions
  ├─ /profile
  └─ quick links:
     /recommendations
     /progress
     /streak
     /achievements
     /leaderboard
     /community
     /notifications

/game/:id
  └─ /game/:id/play

/favorites
/history
/community/posts
/community/posts/:id
/profile/settings
```

## Data Flow

```text
UI Event
  ↓
Riverpod Notifier
  ↓
Repository
  ↓
Remote Data Source / Local Cache
  ↓
ApiClient / Storage
  ↓
State Emit
  ↓
UI Render
```

### Example: load game detail

```text
Screen opened
  ↓
gameDetailProvider(id)
  ↓
GameDetailRepository.getBySlugOrId()
  ↓
GameDetailRemoteDataSource.fetch()
  ↓
Dio GET /api/v1/games/{slug}
  ↓
DTO parse → domain model
  ↓
provider state = data
  ↓
UI renders + analytics GAME_VIEW
```

## Authentication Flow

```text
App Launch
  ↓
Read secure token
  ↓
Token exists?
  ├─ No  → Guest mode
  └─ Yes
       ↓
    GET /api/v1/users/me
       ↓
    200? 
      ├─ Yes → authenticated session
      └─ No  → clear token → guest mode
```

### Important auth notes

- Gunakan `flutter_secure_storage` untuk access token
- Jangan simpan JWT di SharedPreferences
- Siapkan interface refresh token, tetapi implementasi runtime harus mengikuti endpoint backend yang benar-benar tersedia
- Anonymous user tetap bisa browse dan play

## Game Session Flow

```text
Open Game Detail
  ↓
Press Play
  ↓
POST /api/v1/games/{gameId}/sessions/start
  ↓
Open WebView player
  ↓
Heartbeat loop every ~30s
  ↓
App paused? → POST pause
  ↓
App resumed? → POST resume
  ↓
User exits player
  ↓
POST end
  ↓
Refresh progress / missions / streak / achievements / leaderboard
```

### Session ownership rule

- Backend menentukan valid/invalid session
- Flutter hanya mengirim lifecycle signal
- Flutter tidak menghitung active play duration authoritative

## Offline Strategy

### Safe to cache

- home shelves
- game catalog pages
- game detail
- categories/tags kalau nanti tersedia
- profile snapshot
- favorites snapshot
- missions snapshot
- achievements snapshot
- leaderboard snapshot

### Safe to queue

- analytics events
- recommendation impressions
- safe read refresh requests

### Not safe to mutate offline as source of truth

- XP
- level
- streak
- missions completion
- leaderboard score
- authoritative session duration

### UX policy

- tampilkan cached content saat offline
- tampilkan badge atau banner bahwa data mungkin stale
- flush analytics queue saat koneksi kembali

## Folder Structure

```text
lib/
  app/
    app.dart
    bootstrap.dart
    config/
    router/
    theme/

  core/
    analytics/
    constants/
    env/
    errors/
    extensions/
    logging/
    network/
    storage/
    utils/
    widgets/

  features/
    auth/
      data/
      domain/
      presentation/
    home/
      data/
      domain/
      presentation/
    discovery/
      data/
      domain/
      presentation/
    search/
      data/
      domain/
      presentation/
    game_detail/
      data/
      domain/
      presentation/
    game_player/
      data/
      domain/
      presentation/
    favorites/
      data/
      domain/
      presentation/
    history/
      data/
      domain/
      presentation/
    recommendations/
      data/
      domain/
      presentation/
    progress/
      data/
      domain/
      presentation/
    missions/
      data/
      domain/
      presentation/
    streak/
      data/
      domain/
      presentation/
    achievements/
      data/
      domain/
      presentation/
    leaderboard/
      data/
      domain/
      presentation/
    community/
      data/
      domain/
      presentation/
    notifications/
      data/
      domain/
      presentation/
    profile/
      data/
      domain/
      presentation/

  shared/
    components/
    models/
    widgets/
```

## Dependency List

Dependensi inti yang direncanakan:

- `flutter_riverpod`
  - state management dan dependency injection
- `go_router`
  - routing dan nested navigation
- `dio`
  - HTTP client
- `freezed`
  - immutable models dan unions
- `json_serializable`
  - typed JSON mapping
- `flutter_secure_storage`
  - token storage
- `hive` atau `isar`
  - cache lokal
- `cached_network_image`
  - image cache
- `webview_flutter`
  - HTML5 game player
- `connectivity_plus`
  - connectivity awareness
- `url_launcher`
  - external links
- `share_plus`
  - sharing game/profile
- `package_info_plus`
  - app version analytics
- `device_info_plus`
  - device metadata
- `uuid`
  - event/session/anonymous IDs
- `intl`
  - formatting
- `logger`
  - debug logging

Tambahan build tooling:

- `build_runner`
- `freezed_annotation`
- `json_annotation`

## API Client Design

`ApiClient` berbasis Dio akan menangani:

- base URL per environment
- bearer token injection
- request timeout
- debug logging
- standardized error mapping
- connectivity-aware retry yang aman
- wrapper parse `ApiResponse<T>`

### Environment strategy

- `.env.development`
- `.env.staging`
- `.env.production`

Config minimum:

```text
API_BASE_URL=https://api.gamediscoveries.com
APP_ENV=production
```

## Localization (en, id)

- Flutter gen-l10n: `lib/l10n/app_en.arb` (template, setiap key wajib punya `@key.description`) dan `app_id.arb`; regenerate dengan `flutter gen-l10n`.
- Akses string lewat `context.l10n` (`lib/core/l10n/locale_resolution.dart`); di luar widget/test pakai `lookupAppLocalizations(locale)`.
- Mode bahasa `AppLanguage` (`SYSTEM` | `en` | `id`) di `lib/core/l10n/app_language.dart`; `SYSTEM` mengikuti bahasa perangkat, bahasa tak didukung jatuh ke English.
- State menyimpan enum/objek error, bukan teks; teks dipetakan saat `build` supaya ganti bahasa langsung berlaku. Di callback async, ambil `l10n` sebelum `await`.
- Format angka/waktu per bahasa lewat `lib/core/utils/formatters.dart` (`l10n.localeName`); pesan error lewat `friendlyErrorMessage(l10n, error)`.
- Sinkron akun: lihat `PUT /api/v1/users/me/preferences` di `backend-api-map.md` dan `features/profile/presentation/language_sync.dart`.
- Tidak diterjemahkan: judul game, nama/handle user, konten buatan user, merek, isi game di WebView, dan konten dari server (judul misi/achievement, notifikasi, kategori, catatan rilis) sampai backend menyediakan versi lokal.
- Penjaga regresi: `test/l10n/translation_completeness_test.dart` (key EN/ID sama, placeholder lengkap, tidak ada teks UI hardcoded di `lib`).

## Design System Direction

Default theme:

- Dark gaming theme
- Material 3 sebagai basis
- rounded cards
- glowing accent terbatas
- artwork-heavy layouts
- motion halus, tidak berlebihan

Token desain yang harus dipisah:

- `AppColors`
- `AppTypography`
- `AppSpacing`
- `AppRadius`
- `AppShadows`
- `AppIcons`
- `AppAnimations`

## Initial Feature-to-API Mapping

- Auth → `/api/v1/auth/*`, `/api/v1/users/me`
- Home/Discovery → `/api/v1/discoveries/home`, `/api/v1/games`, `/api/v1/discovery/*`
- Game Detail → `/api/v1/games/{slug}`
- Game Player → `/api/v1/games/{gameId}/sessions/*`
- Favorites → `/api/v1/users/me/favorites*`
- History → `/api/v1/users/me/history`
- Recommendations → `/api/v1/recommendations*`
- Progress → `/api/v1/me/progress`, `/api/v1/me/xp*`
- Missions → `/api/v1/me/missions*`
- Streak → `/api/v1/me/streak*`
- Achievements → `/api/v1/me/achievements*`
- Leaderboard → `/api/v1/leaderboards*`, `/api/v1/competitions*`
- Community → `/api/v1/community*`, `/api/v1/games/{slug}/reviews`
- Notifications → `/api/v1/community/notifications*`
- Analytics → `/api/v1/events/batch`

## Identified Backend Gaps and Mobile Handling

### 1. Refresh token flow not confirmed

Handling:

- arsitektur auth tetap menyediakan extension point refresh
- implementasi awal jangan memanggil endpoint fiktif
- fallback ke relogin/guest mode saat token invalid

### 2. Dedicated search endpoint not confirmed

Handling:

- abstraction search repository tetap dibuat
- implementasi awal gunakan query `search` di `/api/v1/games`
- dokumentasikan migration path ke endpoint search dedicated nanti

### 3. Push notification backend not fully confirmed

Handling:

- buat `NotificationService` abstraction
- integrasikan dulu notification center berbasis API community
- push provider bisa ditambahkan tanpa mengubah layer UI

## Development Roadmap

### Phase 0

- audit backend selesai
- tulis API map
- tulis mobile architecture

### Phase 1

- scaffold Flutter project
- set package structure
- setup app bootstrap
- setup theme dasar
- setup router dasar
- setup env/config shell

### Phase 2

- design system primitives
- dark/light theme baseline
- reusable shell widgets

### Phase 3

- Dio client
- error mapper
- secure storage
- connectivity service
- local cache layer

### Phase 4

- auth models
- auth repository
- login/register/session restore
- guest mode gateway

### Phase 5+

Lanjut bertahap sesuai urutan user:

- Home + Discovery
- Search
- Game Detail
- Game Player
- Session tracking
- Favorites + History
- Recommendations
- Progress
- Missions
- Streak
- Achievements
- Leaderboard
- Community
- Notifications
- Offline optimization
- Analytics optimization
- Performance
- Security
- Testing
- CI/CD
- Release

## Immediate Phase 1 Implementation Plan

1. Buat project Flutter di repo `gamediscoveries-app`.
2. Set nama package/project ke `gamediscoveries_mobile`.
3. Tambahkan struktur folder `lib/app`, `lib/core`, `lib/features`, `lib/shared`.
4. Buat `App`, `bootstrap`, router placeholder, dan theme shell.
5. Tambahkan dependency inti yang aman untuk fondasi awal saja.
6. Pastikan `flutter analyze` dan `flutter test` bersih setelah fondasi awal.
