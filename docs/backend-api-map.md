# GameDiscoveries Mobile Backend API Map

Dokumen ini memetakan API backend yang benar-benar ditemukan di `gamediscoveries-api` untuk kebutuhan aplikasi mobile Flutter. Fokusnya adalah endpoint yang relevan untuk mobile; endpoint admin hanya dicatat bila berguna sebagai referensi arsitektur atau potensi fitur internal.

## Audit Summary

- Source of truth: `gamediscoveries-api`
- Gaya API: REST JSON dengan wrapper `ApiResponse<T>`
- Versioning: URL versioning `/api/v1/...`
- Auth utama: JWT Bearer
- Endpoint mobile campuran antara `AllowAnonymous` dan `RequireAuthorization`
- Business rules gamification tetap di backend
- Search endpoint yang dipakai frontend (`/api/v1/search/games`) belum ditemukan pada source backend saat audit ini
- Refresh token field ada pada response login, tetapi endpoint refresh token belum ditemukan pada source backend saat audit ini

## Response Contract

### Success wrapper

```json
{
  "success": true,
  "data": {},
  "error": null,
  "meta": null
}
```

### Paginated wrapper

```json
{
  "success": true,
  "data": [],
  "error": null,
  "meta": {
    "page": 1,
    "pageSize": 20,
    "total": 120,
    "totalPages": 6
  }
}
```

### Error wrapper

```json
{
  "success": false,
  "data": null,
  "error": {
    "type": "validation_error",
    "title": "Validation Error",
    "status": 400,
    "detail": "One or more validation errors occurred.",
    "traceId": "..."
  },
  "meta": null
}
```

### Validation error note

`AppException` juga mendukung kumpulan error validasi dalam bentuk `Errors: IDictionary<string, string[]>`. Mobile harus menyiapkan parser error yang toleran terhadap:

- wrapper `ApiResponse<T>`
- payload error detail
- kemungkinan error validasi field-based

## Authentication

### `POST /api/v1/auth/login`

- Auth required: No
- Request:
  - `email: string`
  - `password: string`
- Response:
  - `ApiResponse<LoginResponse>`
  - `LoginResponse`
    - `accessToken: string`
    - `expiresIn: number`
    - `user`
      - `id`
      - `email`
      - `displayName`
      - `avatarUrl`
      - `roles: string[]`
    - `refreshToken?: string | null`
- Pagination: No
- Flutter usage:
  - login utama
  - simpan access token di secure storage
  - jangan asumsikan refresh token selalu tersedia
- Notes:
  - field refresh token ada, tetapi endpoint refresh belum terkonfirmasi

### `POST /api/v1/auth/register`

- Auth required: No
- Request:
  - `email: string`
  - `password: string`
  - `displayName: string`
- Response: sama seperti login
- Pagination: No
- Flutter usage:
  - registration dan auto-login flow

### `POST /api/v1/auth/logout`

- Auth required: Yes
- Request: body kosong
- Response:
  - `ApiResponse<{ loggedOut: boolean }>`
- Pagination: No
- Flutter usage:
  - panggil saat logout jika token valid
  - tetap hapus state lokal walau request gagal
- Notes:
  - logout bersifat stateless untuk JWT

### `GET /api/v1/users/me`

- Auth required: Yes
- Request: none
- Response:
  - `ApiResponse<UserResponse>`
  - `UserResponse`
    - `id`
    - `email`
    - `displayName`
    - `avatarUrl`
    - `roles: string[]`
- Pagination: No
- Flutter usage:
  - restore session
  - hydrate current user
  - role awareness untuk admin/superadmin jika nanti dibutuhkan

## Catalog and Discovery

### `GET /api/v1/games`

- Auth required: No
- Query:
  - `page`
  - `pageSize`
  - `search`
  - `category`
  - `platform`
  - `mobileReady`
  - `sort`
  - `tag`
- Response:
  - `ApiResponse<GameSummaryResponse[]>`
  - item:
    - `id`
    - `slug`
    - `title`
    - `description`
    - `thumbnailUrl`
    - `coverUrl`
    - `gameUrl`
    - `category`
    - `platform`
    - `mobileReady`
    - `publishedAt`
- Pagination: Yes via `meta`
- Flutter usage:
  - catalog listing
  - discover feed fallback
  - category/tag/search fallback
- Notes:
  - karena endpoint search dedicated belum terkonfirmasi, mobile bisa memakai `search` query pada endpoint ini sebagai baseline

### `GET /api/v1/games/{slug}`

- Auth required: No
- Request: route `slug`
- Response:
  - `ApiResponse<GameResponse>`
  - `GameResponse`
    - `id`
    - `slug`
    - `title`
    - `description`
    - `instructions`
    - `thumbnailUrl`
    - `coverUrl`
    - `gameUrl`
    - `embedUrl`
    - `category`
    - `developer`
    - `platform`
    - `status`
    - `mobileReady`
    - `orientation`
    - `width`
    - `height`
    - `tags: string[]`
    - `createdAt`
    - `updatedAt`
    - `publishedAt`
- Pagination: No
- Flutter usage:
  - game detail
  - player launch preparation
  - orientation handling

### `GET /api/v1/discoveries/home`

- Auth required: No
- Request: none
- Response:
  - `ApiResponse<HomeDiscoveriesResponse>`
  - sections:
    - `featured`
    - `trending`
    - `latest`
    - `popular`
    - `mobile`
    - `multiplayer`
    - `hotGames`
    - `bestGames`
    - `mostPlayed`
    - `exclusiveGames`
- Pagination: No
- Flutter usage:
  - home shelves awal
  - offline snapshot cache

## Search

### Observed Gap: `/api/v1/search/games`

- Frontend saat ini memanggil `GET /api/v1/search/games?q=...`
- Endpoint backend yang sesuai belum ditemukan pada source audit ini
- Flutter recommendation:
  - buat abstraction `SearchRemoteDataSource`
  - implementasi awal gunakan `GET /api/v1/games?search=...`
  - beri catatan integrasi agar bisa dipindah ke dedicated search endpoint saat tersedia

## Favorites and History

### `GET /api/v1/users/me/favorites`

- Auth required: Yes
- Response:
  - `ApiResponse<FavoriteItemResponse[]>`
  - item:
    - `gameId`
    - `favoritedAt`
    - `game: GameSummaryResponse`
- Pagination: No
- Flutter usage:
  - favorites list
  - profile summary

### `POST /api/v1/users/me/favorites`

- Auth required: Yes
- Request:
  - game identifier payload from backend contract
- Response:
  - favorited item / success wrapper
- Pagination: No
- Flutter usage:
  - add favorite
  - optional optimistic UI jika payload lokal cukup
- Notes:
  - saat implementasi Phase 10, baca DTO request final sebelum wiring form body

### `GET /api/v1/users/me/favorites/{gameId}`

- Auth required: Yes
- Response:
  - favorite status untuk game tertentu
- Pagination: No
- Flutter usage:
  - sinkron status hati pada game detail / cards

### `DELETE /api/v1/users/me/favorites/{gameId}`

- Auth required: Yes
- Response:
  - success wrapper
- Pagination: No
- Flutter usage:
  - remove favorite

### `GET /api/v1/users/me/history`

- Auth required: Yes
- Response:
  - `ApiResponse<HistoryItemResponse[]>`
  - item:
    - `id`
    - `gameId`
    - `playedAt`
    - `durationSeconds`
    - `game: GameSummaryResponse`
- Pagination: No
- Flutter usage:
  - continue playing / recently played

### `POST /api/v1/users/me/history`

- Auth required: Yes
- Request:
  - history creation payload dari backend
- Response:
  - success wrapper
- Pagination: No
- Flutter usage:
  - hanya bila backend memang butuh explicit write selain play session

## Analytics and Session Tracking

### `POST /api/v1/events`

- Auth required: No
- Request:
  - `AnalyticsEventIngestRequest`
    - `eventId`
    - `eventType`
    - `anonymousId?`
    - `sessionId?`
    - `gameId?`
    - `source?`
    - `platform?`
    - `deviceType?`
    - `appVersion?`
    - `pageUrl?`
    - `referrerUrl?`
    - `metadata?`
    - `occurredAt`
- Response:
  - ingest result wrapper
- Pagination: No
- Flutter usage:
  - single-event fallback

### `POST /api/v1/events/batch`

- Auth required: No
- Request:
  - batch analytics events
- Response:
  - `AnalyticsBatchIngestResult`
    - `accepted`
    - `duplicates`
    - `rejected`
    - `results`
- Pagination: No
- Flutter usage:
  - preferred mobile queue flush
  - offline analytics replay

### `POST /api/v1/analytics/events`

- Auth required: No
- Notes:
  - alias/event ingest path juga ditemukan
  - final client sebaiknya memilih satu canonical path setelah integrasi diuji

### `POST /api/v1/games/{gameId}/sessions/start`

- Auth required: No
- Request:
  - `StartGamePlaySessionRequest`
    - `sessionId?`
    - `anonymousId?`
    - `source?`
    - `platform?`
    - `deviceType?`
    - `appVersion?`
- Response:
  - `ApiResponse<GamePlaySessionResponse>`
- Flutter usage:
  - start authoritative session sebelum WebView load

### `POST /api/v1/games/sessions/{sessionId}/heartbeat`

- Auth required: No
- Request:
  - `anonymousId?`
  - `clientTimestamp?`
  - `visibilityState?`
  - `isFocused?`
- Response:
  - session state wrapper
- Flutter usage:
  - heartbeat kira-kira setiap 30 detik

### `POST /api/v1/games/sessions/{sessionId}/pause`

- Auth required: No
- Request:
  - `anonymousId?`
  - `reason?`
- Response:
  - session state wrapper
- Flutter usage:
  - saat app lifecycle `paused` atau game tertutup sementara

### `POST /api/v1/games/sessions/{sessionId}/resume`

- Auth required: No
- Request:
  - `anonymousId?`
  - `reason?`
- Response:
  - session state wrapper
- Flutter usage:
  - saat kembali foreground

### `POST /api/v1/games/sessions/{sessionId}/end`

- Auth required: No
- Request:
  - `anonymousId?`
  - `reason?`
- Response:
  - session final wrapper
- Flutter usage:
  - wajib dipanggil saat user exit dari player screen

### `GET /api/v1/games/sessions/{sessionId}`

- Auth required: No
- Response:
  - `ApiResponse<GamePlaySessionResponse>`
  - fields:
    - `sessionId`
    - `gameId`
    - `status`
    - `startedAt`
    - `lastHeartbeatAt`
    - `pausedAt`
    - `resumedAt`
    - `endedAt`
    - `durationSeconds`
    - `activeSeconds`
    - `isValid`
    - `invalidReason`
    - `source`
    - `platform`
- Flutter usage:
  - session recovery dan diagnostics

## Recommendations

### `GET /api/v1/recommendations`

- Auth required: Mixed, endpoint mendukung anonymous dan identified context
- Query/behavior:
  - tipe recommendation ditentukan di backend
- Response:
  - `ApiResponse<RecommendationResponse>`
  - fields:
    - `items`
    - `type`
    - `algorithmVersion`
    - `generatedAt`
    - `expiresAt`
    - `cacheHit`
    - `strategy`
    - `profileLevel`
    - `recommendationRequestId?`
- Flutter usage:
  - generic recommendation source

### `GET /api/v1/recommendations/home`

- Auth required: Mixed
- Response:
  - `ApiResponse<RecommendationHomeResponse>`
  - fields:
    - `sections`
    - `algorithmVersion`
    - `profileLevel`
    - `recommendationRequestId`
- Flutter usage:
  - personalized home shelves

### Typed recommendation aliases

- `GET /api/v1/recommendations/for-you`
- `GET /api/v1/recommendations/because-you-played`
- `GET /api/v1/recommendations/trending`
- `GET /api/v1/recommendations/new`
- `GET /api/v1/recommendations/hidden-gems`
- `GET /api/v1/recommendations/quick-play`

Semua:

- Auth required: Mixed
- Response: `ApiResponse<RecommendationResponse>`
- Flutter usage:
  - shelf-specific providers

### `GET /api/v1/recommendations/similar/{gameId}`

- Auth required: Mixed
- Response: `ApiResponse<RecommendationResponse>`
- Flutter usage:
  - similar games di game detail

### `POST /api/v1/recommendations/{gameId}/feedback`

- Auth required: Mixed
- Request:
  - `feedbackType`
  - `section?`
  - `recommendationRequestId?`
  - `anonymousId?`
- Response:
  - success wrapper
- Flutter usage:
  - thumbs up/down atau feedback relevansi bila UI nanti menampungnya

### `POST /api/v1/recommendations/impressions`

- Auth required: Mixed
- Request:
  - `recommendationRequestId`
  - `gameId`
  - `position`
  - `section`
  - `eventType = IMPRESSION`
  - `anonymousId?`
- Response:
  - success wrapper
- Flutter usage:
  - impression tracking per shelf

## Progress, XP, Missions, Streak, Achievements

### `GET /api/v1/me/progress`

- Auth required: Yes
- Response:
  - `ApiResponse<UserProgressResponse>`
  - `user`
  - `level`
  - `stats`
  - `streak?`
- Flutter usage:
  - progress screen utama
  - home header

### `GET /api/v1/me/xp`

- Auth required: Yes
- Response:
  - `ApiResponse<UserXpSummary>`
  - `totalXp`
  - `level`
  - `currentLevelXp`
  - `recentTransactions`
- Flutter usage:
  - compact XP widgets

### `GET /api/v1/me/xp/transactions`

- Auth required: Yes
- Query:
  - `page`
  - `pageSize`
  - `ruleCode?`
  - `dateFrom?`
  - `dateTo?`
- Response:
  - `ApiResponse<PagedXpTransactionsResponse>`
  - item:
    - `transactionId`
    - `ruleCode`
    - `eventType`
    - `referenceType`
    - `referenceId`
    - `xpAmount`
    - `description`
    - `createdAt`
- Pagination: response body fields `page`, `pageSize`, `total`
- Flutter usage:
  - XP history tab

### `GET /api/v1/me/missions`

- Auth required: Yes
- Response:
  - `ApiResponse<MyMissionsResponse>`
  - `daily`
  - `weekly`
  - `dailyExpiresAt`
  - `weeklyExpiresAt`
  - `timeZone`
- Flutter usage:
  - missions screen

### `GET /api/v1/me/missions/history`

- Auth required: Yes
- Response:
  - `ApiResponse<PagedMissionsResponse>`
- Flutter usage:
  - completed/archive missions

### `GET /api/v1/me/missions/{missionId}`

- Auth required: Yes
- Response:
  - `ApiResponse<MissionDto>`
  - fields:
    - `id`
    - `code`
    - `type`
    - `title`
    - `description`
    - `icon`
    - `requirementType`
    - `progress`
    - `target`
    - `percentage`
    - `rewardXp`
    - `status`
    - `difficulty`
    - `periodStart`
    - `expiresAt`
    - `completedAt`
- Flutter usage:
  - mission detail

### `GET /api/v1/me/streak`

- Auth required: Yes
- Response:
  - `ApiResponse<StreakStatusDto>`
  - `currentStreak`
  - `longestStreak`
  - `status`
  - `streakStartDate`
  - `lastQualifyingActivityDate`
  - `todayQualified`
  - `freezeCount`
  - `maxFreezeCount`
  - `nextMilestone?`
  - `lastAchievedMilestone?`
- Flutter usage:
  - streak screen
  - profile summary

### `GET /api/v1/me/streak/history`

- Auth required: Yes
- Query:
  - `page`
  - `pageSize`
  - `eventType?`
- Response:
  - `ApiResponse<PagedStreakHistoryDto>`
  - item:
    - `id`
    - `eventType`
    - `streakValue`
    - `activityDate`
    - `previousStreak`
    - `newStreak`
    - `reason`
    - `createdAt`
- Flutter usage:
  - streak timeline

### `GET /api/v1/me/achievements`

- Auth required: Yes
- Response:
  - `ApiResponse<AchievementListResponse>`
  - `items`
  - `overview`
- Flutter usage:
  - achievement gallery

### Additional achievement endpoints

- `GET /api/v1/me/achievements/unlocked`
- `GET /api/v1/me/achievements/in-progress`
- `GET /api/v1/me/achievements/recent`
- `GET /api/v1/me/achievements/{code}`

Common item fields:

- `id`
- `code`
- `title`
- `description`
- `category`
- `difficulty`
- `icon`
- `isSecret`
- `isUnlocked`
- `unlockedAt`
- `progressValue`
- `targetValue`
- `progressPercentage`
- `rewardXp`

Flutter usage:

- tabs unlocked / in progress / recent
- achievement detail

## Leaderboards and Competitions

### `GET /api/v1/leaderboards`

- Auth required: No
- Response:
  - `ApiResponse<LeaderboardListItemDto[]>`
  - item:
    - `code`
    - `name`
    - `type`
    - `description`
    - `activePeriod?`
    - `participants`
- Flutter usage:
  - leaderboard tab selector

### `GET /api/v1/leaderboards/{code}`

- Auth required: No
- Query:
  - `limit` pada frontend web dipakai untuk jumlah ranking
- Response:
  - `ApiResponse<LeaderboardDetailResponse>`
  - `leaderboard`
  - `items`
  - `me`
  - `totalParticipants`
- Item fields:
  - `rank`
  - `user`
  - `score`
  - `rankChange`
  - `rankMovement`
  - `gamesPlayed`
  - `validSessions`
  - `xpEarned`
- Flutter usage:
  - ranking list
  - sticky current user row

### `GET /api/v1/leaderboards/{code}/me`

- Auth required: Yes
- Response:
  - `ApiResponse<UserRankResponse>`
  - `rank`
  - `score`
  - `previousRank`
  - `rankChange`
  - `rankMovement`
  - `percentile`
  - `gamesPlayed`
  - `validSessions`
  - `xpEarned`
  - `nextRank`
  - `xpToNextRank`
  - `period?`
- Flutter usage:
  - current user standing

### `GET /api/v1/leaderboards/{code}/history`

- Auth required: Yes
- Response:
  - `ApiResponse<LeaderboardHistoryItemDto[]>`
- Flutter usage:
  - past periods history bila dibutuhkan

### `GET /api/v1/me/leaderboards/history`

- Auth required: Yes
- Response:
  - user leaderboard history
- Flutter usage:
  - profile competition history

### `GET /api/v1/competitions`

- Auth required: Mixed
- Response:
  - `ApiResponse<CompetitionDto[]>`
  - `code`
  - `name`
  - `description`
  - `status`
  - `startAt`
  - `endAt`
  - `leaderboardCode`
  - `requiresJoin`
- Flutter usage:
  - future event/competition shelf

### `POST /api/v1/competitions/{code}/join`

- Auth required: Yes
- Response:
  - success wrapper
- Flutter usage:
  - explicit join competition CTA

## Discovery Score and Trending

### Supported endpoints

- `GET /api/v1/discovery`
- `GET /api/v1/discovery/trending`
- `GET /api/v1/discovery/rising`
- `GET /api/v1/discovery/popular`
- `GET /api/v1/discovery/new-trending`
- `GET /api/v1/discovery/most-played`
- `GET /api/v1/discovery/most-favorited`
- `GET /api/v1/discovery/most-rated`
- `GET /api/v1/discovery/most-reviewed`
- `GET /api/v1/trending`
- `GET /api/v1/games/{gameId}/discovery-score`

Common notes:

- Auth required: No
- Ranking list response:
  - `ApiResponse<DiscoveryRankingResponse>`
  - `type`
  - `period`
  - `items`
  - `page`
  - `pageSize`
  - `total`
- Score explain response:
  - `ApiResponse<DiscoveryScoreExplainDto>`

Flutter usage:

- discover tabs
- trending shelves
- explainable badges

## Community and Notifications

### `GET /api/v1/community/home`

- Auth required: Mixed
- Response:
  - `ApiResponse<CommunityHomeDto>`
  - feed
  - trendingDiscussions
  - popularGames
  - recentAchievements
  - activeChallenges
  - topPlayers
- Flutter usage:
  - community home

### `GET /api/v1/community/feed`

- Auth required: Mixed
- Query:
  - `cursor?`
- Response:
  - feed items + `nextCursor`
- Flutter usage:
  - paged activity feed

### Posts

- `GET /api/v1/community/posts/{id}`
- `POST /api/v1/community/posts`
- `PUT /api/v1/community/posts/{id}`
- `DELETE /api/v1/community/posts/{id}`

Auth notes:

- read mixed/public
- create/update/delete perlu auth

Flutter usage:

- post detail
- create discussion

### Comments

- `GET /api/v1/community/posts/{id}/comments`
- `POST /api/v1/community/posts/{id}/comments`
- `DELETE /api/v1/community/comments/{id}`

Flutter usage:

- threaded comments

### Reactions

- `POST /api/v1/community/{targetType}/{targetId}/reactions`
- `DELETE /api/v1/community/{targetType}/{targetId}/reactions`

Flutter usage:

- like/reaction state

### Game community and reviews

- `GET /api/v1/games/{slug}/community`
- `GET /api/v1/games/{slug}/reviews`
- `POST /api/v1/games/{slug}/reviews`
- `DELETE /api/v1/reviews/{id}`

Flutter usage:

- discussion tab di game detail
- review summary

### User profile and graph

- `GET /api/v1/users/{username}/profile`
- `PUT /api/v1/users/me/privacy`
- `POST /api/v1/users/{id}/follow`
- `DELETE /api/v1/users/{id}/follow`
- `POST /api/v1/users/{id}/block`
- `DELETE /api/v1/users/{id}/block`

Flutter usage:

- social profile
- follow/block controls

### Community achievements/challenges/leaderboards

- `GET /api/v1/community/achievements`
- `GET /api/v1/users/me/achievements`
- `GET /api/v1/community/challenges`
- `GET /api/v1/users/me/challenges`
- `GET /api/v1/community/leaderboards`

Flutter usage:

- optional social/gamified community shelves

### Notifications

- `GET /api/v1/community/notifications`
- `POST /api/v1/community/notifications/read`

Response notes:

- `items`
- `unread`

Flutter usage:

- in-app notification center
- unread badge

### Moderation and reports

- `POST /api/v1/community/reports`
- `GET /api/v1/admin/community/reports`
- `POST /api/v1/admin/community/moderate`

Flutter usage:

- report abuse action untuk app publik

## Mobile Integration Notes

### Auth strategy

- Gunakan secure storage untuk access token
- Session restore saat app launch:
  1. baca token
  2. panggil `GET /api/v1/users/me`
  3. jika gagal `401`, pindah ke guest mode
- Siapkan abstraction refresh token, tetapi jangan implement fake refresh endpoint

### Anonymous mode

Karena beberapa endpoint public dan play session mendukung anonymous flow, mobile dapat mendukung:

- browse games
- search via catalog query
- game detail
- start session dengan `anonymousId`
- analytics queue

Tanpa auth, mobile tidak boleh mengasumsikan:

- XP persisten
- mission progress persisten
- streak persisten
- leaderboard personal

### WebView / game player implications

Gunakan field backend berikut untuk player screen:

- `gameUrl`
- `embedUrl`
- `orientation`
- `width`
- `height`
- `mobileReady`

### Known gaps before full production mobile rollout

1. Dedicated mobile search endpoint belum terverifikasi di backend source.
2. Refresh token endpoint belum terverifikasi di backend source.
3. Push notification infrastructure belum diaudit; yang terkonfirmasi baru in-app/community notifications.
4. DTO request untuk beberapa write endpoints perlu dibaca ulang saat implementasi Phase terkait agar body Flutter 100% presisi.
