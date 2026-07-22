# Media Tracker — Project Plan

> Locked plan produced in the planning session on **2026-07-14**.
> Source materials: `Users decisions & current progress.md` (the original
> working doc), `Media Tracking Roadmap.png` (the original roadmap).
> Phase labels (Phase N) come from the original working doc and carry over.

This document is the **reference plan** for v1. The original
`Users decisions & current progress.md` remains as the day-to-day working
progress document; cross-reference it for "where am I right now" status.

---

## TL;DR

A local-first Flutter app for tracking every type of media the user
consumes — movies, TV, anime, books, games, podcasts, comics, and more —
with sharing and community features coming in v2. **v1 ships Movies only,
no auth, single device.** Decisions below are locked; they survive until
their phase forces a revisit.

---

## 1. Product

### 1.1 One-sentence positioning

Track, organize, and remember every piece of media I've consumed or want
to consume in one unified library — Movies, TV, Anime, Books, Games,
Podcasts, Comics, Documentaries, Music videos — eventually with sharing
and recommendations for people I trust.

### 1.2 Primary user and core need

**v1:** the developer themselves. A self-described media omnivore who
currently bounces between Letterboxd, MyAnimeList, Goodreads, Backloggd,
and podcast apps. Core need: one place that holds every kind of media
and grows with them.

**v2:** the user's close circles — family, friends — who want to see
recommendations and send them back.

### 1.3 First-session flow (v1, no sign-up)

1. Launch app → Catalogue hub opens immediately
2. Tap the **+** FAB → SearchPage loads
3. Type a movie title → TMDB returns results in a grid
4. Tap a result → AddSheet opens (status toggle: Collection / To Consume,
   rating input)
5. Tap Save → AddSheet closes; the new movie appears on its HubCard
6. **First core-value moment:** ~30 seconds after install

**v2 first-session flow:** Supabase sign-up (email/password → optionally
Google/Apple) → local catalogue syncs → first social recommendation
moment when sending "you might like X" to a friend.

### 1.4 Three most important v1 features

1. **Add a movie via TMDB search** — creates all the data the rest of
   the app shows.
2. **Hub catalogue (Collection / To Consume cards)** — the place the
   user returns to daily.
3. **Edit / rate / move between statuses** — the action that rewards
   repeat visits.

If any of these break, v1 fails.

---

## 2. Scope

### 2.1 In scope (v1)

- Movies catalogue only
- Local-first persistence (Drift + SQLite, no backend)
- TMDB read-only search for adding movies
- Manual-entry fallback when TMDB is unreachable
- Hub catalogue page (Collection / To Consume cards)
- 2-state status enum (`onWatchlist`, `inCollection`)
- Material 3 theming with custom seed color
- Dark theme ships in v1. Light theme is derived from the same seed but not shipped in v1 (v1.1+ follow-up).
- Offline-first behavior

### 2.2 Out of scope (v1)

- All non-Movies media types (TV, Anime, Books, Games, Podcasts, Comics,
  Documentaries, K-Drama, Cartoons, Music videos)
- Sharing via PDF / web link
- Community circles, recommendations, swipe-matching
- Auth, multi-user, backend, cloud sync
- Bottom nav (single-page for v1)
- Saved search sessions
- Similar-media discovery
- iOS / web / desktop targets
- Custom user themes (Vivaldi-style)
- Push notifications

### 2.3 Out of scope (v2)

- All other media types, iterated type-by-type
- Supabase auth (email + social providers)
- Cloud sync of local catalogue to Supabase Postgres
- Sharing via PDF / web link (PNG Iteration 1 originally — deferred)
- Community circles (family, friends, internet friends, coworkers;
  per-media-type circles: gamer, reader, manga, etc.)
- Cross-user `Recommendation` entity with stored / unstored status
- Swipe-based mutual watchlist matching ("Tinder for media")
- Random genre / language / era explore
- Same-genre recommendation algorithm
- Explore page + Community page + bottom nav (3 or 4 tabs)
- Custom UI theming (Vivaldi-style)
- `onCollabLists` 6th status state
- **Import from external platforms** — let users bring in their existing
  tracking history. v2 sources to evaluate, in priority order:
    1. **Letterboxd CSV** (movies) — documented import format, no API
       needed, no OAuth.
    2. **iMDB `ratings.csv`** uploaded by user, enriched via OMDb
       lookups per row.
    3. **Primitive plain-text lists** — heuristic parsing + manual
       review UI for low-confidence matches.
    4. **MAL via JIKAN, Trakt, Backloggd, Steam, Spotify, Goodreads**
       — per-platform OAuth + schema work; re-evaluated at v2 kickoff.

  Each source requires:
    - A fetcher (CSV upload, OAuth API, scrape)
    - A field mapper (iMDB 1–10 → our 0–5; Letterboxd 0.5-step →
      our 0.5-step)
    - A status vocabulary mapper (e.g., MAL "Watching" →
      `currentlyConsuming`; Steam "Abandoned" → `dropped`;
      Letterboxd "Watched" → `inCollection`)
    - A provider resolver step (free-text title → `tmdb_id` /
      `rawg_id` / etc. via `MediaSearchClient`)
    - Progress UI + per-item error handling + rollback path

  The `source` and `imported_at` columns on `media_items` (see §4.1)
  carry provenance from v1 onward — v2 import populates them without
  schema changes.
- **Mega-database for search and discovery (v2)** — hosted on
  **Supabase Postgres** as a `media_universe` table — *not* bundled
  with the app, *not* a lazy on-device cache. Populated by an ETL
  pipeline maintained server-side, ingesting from each provider in
  §4.3 (TMDB, RAWG, Open Library, AniList, Apple Podcasts, Comic
  Vine). The app queries `media_universe` via PostgREST/Realtime and
  falls back to provider APIs on cache miss to refresh the universe.

  Strict separation by location:
    - `media_items` (local, device) — the user's library.
    - `media_universe` (backend, Supabase) — the system's knowledge of
      every known media item.

  Join key between the two: the per-type external id columns
  (`tmdb_id`, `rawg_id`, `anilist_id`, `olid`, `itunes_id`,
  `comic_vine_id`) defined in §4.3. v1 ships these columns already;
  the join is forward-compatible.

  D12 (v2 auth via Supabase) is expanded in scope: Supabase hosts both
  auth and the mega-DB.

---

## 3. Tech Stack

| Concern | Choice | Why |
|---|---|---|
| Framework | Flutter 3.44.5 / Dart 3.12.2 | Verified working with emulator in Phase 0; cross-platform for mobile/PC/web later |
| Local DB | `drift` + `sqlite3_flutter_libs` + `path_provider` | Drift is the typed, codegen'd SQLite layer for Flutter; `path_provider` gives the docs dir for the SQLite file |
| Codegen | `drift_dev` + `build_runner` | Drift's data classes + queries are generated |
| State | `flutter_riverpod` 3.x | Reactive, type-safe; `ProviderContainer.test` in Riverpod 3 makes provider tests cheap |
| Navigation | `go_router` (Phase 2+) | Declarative, ready for v2 deep linking / web; Phase 1 uses `Navigator.push` |
| HTTP | `dio` | Behind a `MediaSearchClient` interface so v2 can swap to a regenerated client without touching call sites |
| Image cache | `flutter_cache_manager` (direct, **not** `cached_network_image`) | Disk-cached posters; `cached_network_image` last released 23 months ago and is rule #7 suspect — we use `flutter_cache_manager` directly with `Image.network` |
| Fonts | `google_fonts` (verified publisher `flutter.dev`) | Source Serif 4 (display/headline) + Inter (title/body/label); official publisher satisfies rule #7 |
| Icons | Material Symbols Rounded font, bundled as asset | No official Flutter wrapper for Material Symbols; bundling the Google-licensed font respects rule #7 |
| Misc | `intl`, `uuid` | Date formatting in v2; stable IDs across `media_items` and per-type detail tables |
| Test target | Android emulator `emulator-5554`, API 36 | Phase 0 |
| v2 backend | Supabase (Auth + Postgres + RLS + Realtime + Storage) | Postgres matches the roadmap PNG's "Postgres" reference; RLS is purpose-built for community permissions; cheaper than Firebase at scale; open-source so a future move to custom Python+Postgres is feasible |

### 3.1 Why each choice in one line

- **Flutter:** cross-platform, native UI, single codebase for mobile / PC / web later
- **Drift:** more type-safe than `sqflite`; codegen eliminates SQL string bugs
- **Riverpod:** better testing story than `Provider`; better dev-time safety than `setState`
- **go_router:** declarative routing; ready for v2 web target; deep linking built-in
- **Dio:** standard Flutter HTTP choice; interceptor system fits v2's future auth-header needs
- **`flutter_cache_manager`:** disk-cached image loading without `cached_network_image` (rule #7; see D16)
- **`google_fonts`:** verified publisher `flutter.dev` (rule #7) — no third-party risk for Source Serif 4 + Inter
- **Material Symbols Rounded asset:** the only rule #7-compliant path to the Material Symbols icon set
- **Supabase:** open-source; Postgres-portable; built-in RLS for community feature permissions

### 3.2 Flutter 3.44 Material migration watch

Material and Cupertino code is **frozen** in Flutter 3.44.5 but still
importable via `package:flutter/material.dart`. The old code will be
deprecated in the stable release after 3.44 and deleted some time after
that. When the project upgrades past 3.44.x, migrate to the new
`material_ui` and `cupertino_ui` first-party packages in a single
dedicated commit. Tracking: [flutter/flutter#184093](https://github.com/flutter/flutter/issues/184093).

For v1 we ship against 3.44.5 with the existing `package:flutter/material.dart`
imports — no action required until the next Flutter major bump.

---

## 4. Data Model

### 4.1 Schema

```text
media_items                          movie_details
─────────────                        ──────────────
id (PK, uuid)                        media_item_id (PK, FK → media_items.id)
title (TEXT, NOT NULL)               director (TEXT, nullable)
year (INT, nullable)                 runtime_minutes (INT, nullable)
type (TEXT)                          studio (TEXT, nullable)
status (TEXT)                        tmdb_id (INT, nullable, unique)
rating (REAL, nullable, 0–5)         poster_url (TEXT, nullable)
source (TEXT, NOT NULL, default      backdrop_url (TEXT, nullable)
        'manual')
imported_at (DATETIME, nullable)
created_at (DATETIME)
updated_at (DATETIME)
```

`source` values: `'manual'` (default for v1 writes), then v2 extends
with `'letterboxd'`, `'imdb'`, `'notes'`, `'mal'`, etc. Stored as plain
TEXT per §4.1 rule; vocabulary enforced at the app boundary.

`imported_at` is nullable: `NULL` = manually added; non-NULL = imported
at that time. Filtering and rollback logic use
`WHERE imported_at IS NULL` / `IS NOT NULL`. See §11.3 for the v1 → v1.1
migration that introduces these columns.

`type` is stored as plain `TEXT` — no CHECK constraint, no SQL ENUM.
Widening the type set (`'movie'` → adding `'tv_show'`, `'anime'`, etc.)
is a **zero schema change** in SQLite; only application code changes.

`status` is also plain `TEXT` for the same reason.

### 4.2 Hybrid model rationale

A future iteration adds TV, Anime, Books, Games, etc. Each type has type
metadata that doesn't fit cleanly on a shared row. The hybrid model:

- `media_items` holds **shared fields** (id, title, year, type, status,
  rating, timestamps). Querying "all my media" hits this table directly.
- `*_details` tables (one per type) hold **type-specific fields**.
  `movie_details` is the only one in v1.

Adding a new type later = new `*_details` table + a new value for the
`type` column (no schema change). Queries cross types via `media_items`;
type-specific queries join to the detail table.

### 4.3 Provider-per-type mapping (locked at v1 planning)

One provider per media type. Re-evaluated only when a new media type is
added. No multi-provider reconciliation per type (e.g., a book that's in
both Google Books and OpenLibrary uses only the canonical provider below).

| Type | Provider | Detail table | External id column | Auth model | Notes |
|---|---|---|---|---|---|
| Movie | TMDB | `movie_details` | `tmdb_id` (INT, nullable, unique) | API key in `lib/secrets.dart` | TMDB v3 `/movie/{id}` and `/search/movie` |
| TV Show | TMDB | `tv_show_details` | `tmdb_id` (INT, nullable, unique) | Same TMDB API key | TMDB v3 `/tv/{id}` and `/search/tv`; movie and TV IDs are in separate id-spaces |
| Book | Open Library *(TBD v2)* | `book_details` | `olid` (TEXT, nullable, unique) | None — read endpoints are unauthenticated | Canonical id is OLID (`OL…W` for works, `OL…M` for editions) |
| Game | **RAWG** | `game_details` | `rawg_id` (INT, nullable, unique) | API key in `lib/secrets.dart` | [rawg.io/apidocs](https://rawg.io/apidocs); **attribution hyperlink required** on every page using RAWG data or images |
| Anime | AniList *(TBD v2)* | `anime_details` | `anilist_id` (INT, nullable, unique) | None — GraphQL is keyless | [docs.anilist.co](https://docs.anilist.co/); supports `idMal` cross-reference to MAL |
| Podcast | Apple Podcasts via iTunes Search API *(TBD v2)* | `podcast_details` | `itunes_id` (INT, nullable, unique) | None — unauthenticated JSON | Returns RSS feed URL stored alongside |
| Comic | Comic Vine *(TBD v2)* | `comic_details` | `comic_vine_id` (INT, nullable, unique) | API key (historical signup flakiness) | Fallback if key unobtainable: defer Comics to v3 |

**Why RAWG over IGDB for Games (locked):** IGDB rate-limits at
**4 requests per second per Client ID**, not per user — verified against
[Twitch Developer Forum](https://discuss.dev.twitch.com/t/igdb-authentication-and-tokens-need-server-app/28394).
Per-user Twitch OAuth does not give per-user rate-limit pools. RAWG's
20,000 requests/month quota is predictable and adequate for v2 scale;
no OAuth dance, no proxy backend needed.

### 4.4 Type-safe enum mapping

Both `media_items.type` and `media_items.status` are stored as plain TEXT
(see §4.1) but are wrapped at the column level with Drift's built-in
`EnumNameConverter`. Zero schema change; eliminates typos at the write
boundary; gives Postgres a CHECK-equivalent when migrating to Supabase
in v2.

```dart
TextColumn get type  => text().map(const EnumNameConverter<MediaType>())();
TextColumn get status => text().map(const EnumNameConverter<MediaStatus>())();
```

Every write path goes through these enums — see Codebase Rule #3.

### 4.5 Local vs backend tables

v1's `media_items` table is the user's library — local, on-device. v2
introduces a separate `media_universe` table on Supabase Postgres (the
system's knowledge of every known media item). The two are **strictly
separated by location** — they must never be merged, even conceptually:

- Local `media_items` holds what the user has chosen to track; row
  count is dozens to thousands.
- Backend `media_universe` holds what the system knows exists; row
  count is millions.
- The per-type external id columns (`tmdb_id`, `rawg_id`, etc., see
  §4.3) are the join key — `media_universe.tmdb_id = movie_details.tmdb_id`
  for rows the user has added.
- v1 ships the join-key columns already; v2 builds the backend table
  and the join logic.

This separation is intentional. Conflating "library" with "universe"
corrupts the user's catalogue with items they never chose to track.

---

## 5. Status Enum

Two states in v1, locked:

| State | Meaning | Hub card |
|---|---|---|
| `onWatchlist` | Want to consume | ✅ To Consume |
| `inCollection` | Consumed | ✅ Collection |

`onCollabLists` is deferred to v2.

### 5.1 Hub mapping (strict, v1)

- Collection card → filters `media_items` where `status = 'inCollection'`
- To Consume card → filters `media_items` where `status = 'onWatchlist'`

### 5.2 v2 status states (deferred)

Three additional states — `currentlyConsuming`, `dropped`, `upcoming` —
are added in v2 when the detail/edit sheet and the import flow have a
real use for them. The platform-to-status mappings (e.g., MAL
"Watching" → `currentlyConsuming`; Steam "Abandoned" → `dropped`) are
decided at v2 planning and documented in §2.3, not §5.2.

Adding a TEXT column with a default is a trivial Drift migration — no
migration debt is being avoided by shipping them schema-only in v1, and
storing values the UI can't surface creates invisible QA debt.

---

## 6. App Shell

### 6.1 v1 — single page

The app is **single-page for v1**. There is no bottom nav, no drawer, no
tabs. `MaterialApp.home = CataloguePage` is the entire app entry.

This is intentional: bottom nav needs three or four destinations
(Explore, Catalogue, Community, possibly Dashboard) and v1 has only
Catalogue. Showing greyed-out / "coming soon" tabs in v1 adds maintenance
without user value.

### 6.2 v2 — bottom nav (deferred)

PNG shows 3 tabs (Explore / Catalogue / Community). When v2 ships:

- Phase 7 introduces `go_router` routing and the shell scaffold.
- Bottom nav lives at the bottom of the scaffold with three destinations.
- Community is `greyed out "coming soon"` until Phase 7+ lands social
  features.

---

## 7. Add-Movie Flow

The single most important interaction in v1. Flow:

```
Catalogue hub (Collection + To Consume cards)
         │ tap [+]
         ▼
SearchPage — TMDB search input, media-type filter (Movies only in v1)
         │ user types title, e.g. "The Matrix"
         ▼
SearchResultsPage — grid (3×3 / 4×4 / 6×6 / list toggle), multi-select
         │ user taps one (or many)
         ▼
AddSheet — status toggle (Collection ⇄ To Consume), rating (0–5)
         │ tap Save
         ▼
back to hub; HubCard updates with new entry
```

### 7.1 Idempotency on add

The search-results grid supports multi-select (see flow above). A user can
tap the same result twice across sessions, and TMDB can return the same
movie under similar queries. Before any `INSERT` into `media_items`, the
repository runs:

```dart
final existing = await movieDao.findByTmdbId(tmdbId);
if (existing != null) {
  throw const AlreadyInCollection(existingId: existing.id);
}
```

`SearchRepository` translates `AlreadyInCollection` into a user-facing
snackbar in `AddSheet`:

- `existing.status == inCollection` → **"Already in your Collection"**
- `existing.status == onWatchlist`  → **"Already on your To Consume list"**

The exception type lives at `lib/data/repositories/errors.dart`. The
unique index on `movie_details.tmdb_id` (see §4.1) is the last-line
defense; the pre-check is what surfaces the friendly message.

### 7.2 Offline fallback

If TMDB is unreachable, `MediaSearchClient` returns a typed error.
`SearchPage` catches it and switches to a **manual-entry form**:

```text
Title: ___________  (text)
Year:  _____       (number)
Genre: ___ ___ ___ (chips, multi)
Rating: ☆☆☆☆☆     (0–5)
Status: [● Collection] [  To Consume ]
[ Cancel ]           [ Save ]
```

Same `Save` path; just no `movie_details` populated beyond what's typed.

### 7.3 Saved search sessions — REMOVED

Originally proposed in the planning session: a way to save a TMDB search
session and resume later. **Removed entirely.** No `search_sessions`
table, no save button, no resumption UI.

---

## 8. Theme & Design

### 8.1 Visual language

- **Color seed:** **one** custom Material 3 seed color, locked in
  Phase 6 polish. Direction: deep blue / indigo. Both light and dark
  themes are derived from the same seed via
  `ColorScheme.fromSeed(seedColor: …, brightness: Brightness.light/dark)`.
  Two seeds = visual whiplash on theme toggle; one seed is correct.
- **Typography:** Material 3 type-scale baseline with intentional
  overrides, sourced via `google_fonts` (verified publisher `flutter.dev`):
    - Display + Headline: serif — **Source Serif 4**
    - Title + Body + Label: sans-serif — **Inter**
    - Movie titles in `MovieCard` use display/headline weight
- **Spacing:** 8px grid baseline. Cards 12px inner padding; 16px gaps.
- **Shape:** 12dp card radius; full radius on buttons.
- **Light + dark:** Dark theme ships in v1. Light is derived from the
  same seed via `ColorScheme.fromSeed(seedColor: …, brightness:
  Brightness.light)` but not shipped in v1. v1.1+ adds the OS-handler
  to switch to light. Both palettes are derived from the single seed
  at runtime; no design work is needed when v1.1 ships.
- **Icons:** **Material Symbols Rounded font, bundled as an asset**.
  Use `IconData(fontFamily: 'MaterialSymbolsRounded', fontPackage: …)`.
  Tonal variants for status. No official Flutter package wraps Material
  Symbols (Flutter's built-in `Icons` class is the legacy Material Icons
  set, not Symbols); bundling the Google-licensed font is the
  rule #7-compliant path.

### 8.2 Component library

Built-in Flutter **Material 3** widgets. No third-party UI library.

Widgets in active use:
- `MaterialApp` + `Scaffold`
- `Card` for `MovieCard` and `HubCard`
- `ListView.builder` for Collection / To Consume lists
- `GridView.builder` for search results
- `ModalBottomSheet` for `AddSheet`
- `FilledButton`, `IconButton`, `TextField`, `Chip`
- `Image.network(url, cacheManager: DefaultCacheManager())` for posters
  (Phase 5+). `flutter_cache_manager` provides the disk cache layer
  directly — `cached_network_image` is **not** used (rule #7; last
  release 23 months ago).

### 8.3 High-level layout

```text
┌─────────────────────────────────┐
│  Catalogue  (single page)       │
│                                 │
│  ┌───────────────────────────┐  │
│  │  ◉ Collection (3)         │  │   ← HubCard 1
│  │    tap to view list       │  │
│  └───────────────────────────┘  │
│                                 │
│  ┌───────────────────────────┐  │
│  │  ◉ To Consume (2)         │  │   ← HubCard 2
│  │    tap to view list       │  │
│  └───────────────────────────┘  │
│                                 │
│                       [+]        │   ← FAB → SearchPage
└─────────────────────────────────┘
              ↓ tap [+]
┌─────────────────────────────────┐
│  Search                         │
│  ┌─────────────────────┐ [▾]    │
│  │ "The Matrix"        │        │
│  └─────────────────────┘        │
│  ┌──┐┌──┐┌──┐                  │
│  │  ││  ││  │  ← 3×3 grid     │
│  └──┘└──┘└──┘                  │
│  ┌──┐┌──┐┌──┐                  │
│  │  ││  ││  │                  │
│  └──┘└──┘└──┘                  │
│  View: [3×3] [4×4] [6×6] [list] │
└─────────────────────────────────┘
              ↓ tap a result
┌─────────────────────────────────┐
│  Add "The Matrix"               │
│  ┌─────────────────────────┐    │
│  │  poster | 1999 | Sci-Fi │    │
│  └─────────────────────────┘    │
│  Add to:  [● Collection]        │
│           [  To Consume ]       │
│  Rating: ☆☆☆☆☆                │
│  [ Cancel ]      [ Save ]       │
└─────────────────────────────────┘
```

v2 layout (deferred): bottom nav (Explore / Catalogue / Community), plus
a drawer (Profile / Home / Dashboard / Settings). v1 is single-page by
design — see `agent_docs_tutor/04-PHASE-GUIDE.md` and the v2 phase slots
in §18 below.

---

## 9. System Boundaries (folder layout)

Current state — Phase 1 in progress:

```
lib/
├── main.dart
└── features/
    └── catalogue/
        ├── data/         # value objects + sample data
        ├── widgets/      # MovieCard, HubCard
        └── *_page.dart   # CataloguePage, MyCollectionPage, ToConsumePage
```

Target state — what each layer owns once Phase 3+ lands:

```
lib/
├── main.dart                          # App entry, MaterialApp, ProviderScope
├── app/
│   ├── theme.dart                     # Material 3 theme + custom seed + typography
│   └── router.dart                    # go_router config (Phase 2+)
├── core/                              # Cross-cutting utilities
│   ├── ids.dart                       # uuid wrappers
│   └── http/
│       ├── media_search_client.dart         # abstract interface
│       ├── dio_media_search_client.dart     # v1 impl with Dio + interceptors
│       └── tmdb/                            # TMDB DTOs and parsers
├── data/                              # Persistence layer (Drift)
│   ├── database.dart                  # AppDatabase, MigrationStrategy
│   ├── tables/
│   │   ├── media_items.dart
│   │   ├── movie_details.dart
│   │   └── (future: tv_show_details.dart, …)
│   ├── daos/
│   │   ├── media_item_dao.dart
│   │   └── movie_dao.dart
│   └── repositories/                  # Domain-facing
│       ├── movie_repository.dart
│       └── search_repository.dart     # depends on MediaSearchClient
├── features/                          # UI by feature
│   ├── catalogue/
│   ├── add_movie/                     # Phase 5
│   │   ├── search_page.dart
│   │   ├── search_results_page.dart
│   │   └── add_sheet.dart
│   └── (future: explore/, community/)
├── providers/                         # Riverpod providers, top-level
│   ├── database_provider.dart
│   ├── movies_list_provider.dart
│   └── search_provider.dart
└── shared/                            # Reusable widgets, helpers

test/
├── data/        # drift repository tests (Phase 3)
├── providers/   # riverpod provider tests (Phase 4)
├── features/    # widget tests (Phase 5)
└── integration/ # optional (Phase 6)
```

Boundary rules:
- `data/` knows nothing about UI.
- `features/` knows nothing about HTTP — UI talks only to repositories via providers.
- `core/http/` knows nothing about Drift or features.
- `providers/` are the glue between data layer and UI.

---

## 10. Codebase Rules (must never violate)

1. **No silent data loss.** Drift migrations must preserve existing user
   data. Each migration step has a test.
2. **Status enum is the locked 2 states.** v1 ships `onWatchlist` and
   `inCollection` only. `onCollabLists` does not appear anywhere in v1
   code. The other three states (`currentlyConsuming`, `dropped`,
   `upcoming`) are added in v2 — see §5.2.
3. **Type-safe enums only at the boundary.** `media_items.type` and
   `.status` are plain TEXT in storage, but every write path must go
   through the value-object enums in
   `lib/features/catalogue/data/movie.dart` (and successors). Drift
   `EnumNameConverter` (see §4.4) is wired at the column level — no
   free-form strings reach SQLite.
4. **No comments unless asked.** Per original working doc section H.
5. **One commit per phase** (or sub-phase when a phase contains two
   independent concerns — see §13 Phase 3 split). Per original working
   doc section H.
6. **Pinned dependency versions.** No `^` or `>=` in `pubspec.yaml` —
   only exact pins.
7. **Official packages only.** No unverified third-party packages.
   Concrete exceptions and reasons are tracked in the Decisions log
   (D16, D17, D18). Where a third-party package is the only viable
   option, document the security/maintenance trade-off in a Decisions
   row before adopting it.
8. **`MediaSearchClient` is the only call site for TMDB.** No `dio`
   imports inside `features/`. The v2 swap to a regenerated client
   (e.g., `openapi_generator`) touches the impl, not the call sites.
9. **Widgets never import Drift directly.** UI reads from Riverpod
   providers; providers read from repositories; repositories read from
   DAOs.
10. **No `setState` for shared state.** Local UI state is fine; anything
    cross-widget goes through Riverpod.
11. **Tests live next to the code they cover** — repository tests in
    `test/data/`, provider tests in `test/providers/`, widget tests in
    `test/features/<feature>/`.
12. **Material import strategy (Flutter 3.44 watch).** All Material
    imports go through `package:flutter/material.dart` while we are on
    Flutter 3.44.x. When the project upgrades past 3.44.x, migrate to
    `material_ui` / `cupertino_ui` first-party packages in a single
    dedicated commit. Tracking: [flutter/flutter#184093](https://github.com/flutter/flutter/issues/184093).

### 10.1 Cross-references to the 14 invariants

The 12 rules above cover the v1-critical subset. Three invariants
maintained in the tutor doc set are referenced from here rather than
restated, to avoid drift between the two doc sets:

- **I-11** — `MediaSearchClient.search` signature is locked at
  `Future<List<MediaSearchResult>> search({required String query, required MediaType mediaType})`.
  See `agent_docs_tutor/02-ARCHITECTURE.md` §I-11. Enforced in chat
  during code review.
- **I-13** — No `user_id` column on `media_items` in v1. Auth and
  multi-tenant logic are deferred to v2 (Supabase + RLS, see D12).
  See `agent_docs_tutor/02-ARCHITECTURE.md` §I-13.
- **I-14** — `TMDB_API_KEY` must be set at boot (via
  `lib/secrets.dart` for dev or `--dart-define=…` for CI). Missing key
  fails fast at the `MediaSearchClient` constructor. See
  `agent_docs_tutor/02-ARCHITECTURE.md` §I-14.

The canonical list of all 14 invariants is in
`agent_docs_tutor/02-ARCHITECTURE.md` §"The 14 invariants" (I-1
through I-14). This section is the v1 subset restated for
readability; the tutor doc is authoritative.

---

## 11. Migrations

Additive migrations per phase via `MigrationStrategy.onUpgrade(from, to)`.

Drift's new `stepByStep` codegen helper is available — it produces
per-step migration files based on schema diffs. Use it where it
shortens the work; fall back to manual `onUpgrade` where it doesn't.

### 11.1 Adding a new media type

When v2 adds TV Shows, Anime, etc.:

1. Create `lib/data/tables/tv_show_details.dart` (etc.) joined by
   `media_item_id` to `media_items`.
2. Bump `schemaVersion` (e.g. 1 → 2 for TV, 2 → 3 for Anime).
3. Add a new `if (from < 2) { await m.createTable(tvShowDetails); }` step
   in `onUpgrade`.
4. Write a test that:
    - Opens v1 schema, inserts a Movie, closes
    - Opens v2 schema against the same DB file
    - Asserts the Movie is still present and the new table exists

`media_items.type` and `.status` are plain TEXT, so widening the type
set is **zero schema change** in SQLite.

### 11.2 Migration test pattern (drift in-memory)

```dart
test('migration v1 → v2 preserves existing Movies', () async {
  // Open as v1, insert
  final v1 = AppDatabase.forTesting(NativeDatabase.memory());
  await v1.movieDao.insert(Movie(...));
  await v1.close();

  // Reopen as v2 — drift runs onUpgrade automatically
  final v2 = AppDatabase.forTesting(NativeDatabase.memory());
  expect(await v2.movieDao.all(), hasLength(1));
});
```

(Drift tests run on the host — no emulator needed.)

### 11.3 v1 → v1.1 schema additions (forward-compatible with v2 import)

When v1 source column and imported_at are added (§4.1):

1. Bump `schemaVersion` (e.g., 1 → 2).
2. Add to `onUpgrade`:

   ```dart
   if (from < 2) {
     await m.addColumn(mediaItems, mediaItems.source);
     await m.addColumn(mediaItems, mediaItems.importedAt);
     await database.customStatement(
       "UPDATE media_items SET source = 'manual' WHERE source IS NULL",
     );
   }
   ```

3. Write a migration test (drift in-memory, see §11.2 pattern):
   - Open as v1, insert a Movie, close.
   - Open as v2 against the same DB file.
   - Assert: the existing Movie has `source = 'manual'` and
     `imported_at IS NULL`.

The default `'manual'` backfill ensures existing v1 user data is
correctly attributed as manual after the migration.

---

## 12. Testing

**Tests per layer per phase.** ~150 lines of test code total across v1.

| Phase | Layer | Tests | ~Lines |
|---|---|---|---|
| 3 | Drift repository | insert, query, delete, migration v1→v2, hybrid join | 50 |
| 4 | Riverpod providers | 2-3 via `ProviderContainer.test` | 30 |
| 5 | Widget UI | hub cards render, search-page renders, AddSheet submits | 80 |
| 6 | Integration (optional) | "open app → add movie → see on hub" end-to-end | TBD |

Drift tests run on the host against `NativeDatabase.memory()` — no
emulator, no device. Riverpod provider tests use `ProviderContainer.test`
(new in Riverpod 3). Widget tests use `WidgetTester` from the `test`
package. Integration tests use the `integration_test` package.

---

## 13. Build Order

| # | Phase | Produces | Status |
|---|---|---|---|
| 0 | Tooling | `flutter doctor` clean; emulator `emulator-5554` online; default counter app launched | ✅ Done |
| 1 | Widget fundamentals + static catalogue hub | Hardcoded `Movie`s, `MovieCard`, `HubCard`, hub page (Collection → My Collection / To Consume) | 🚧 In progress |
| 2 | App shell | App stays single-page (1 tab) for v1; `go_router` setup for future routing needs; MediaSearchClient interface defined | ⏳ Pending |
| 3a | Drift data model | `AppDatabase` with `schemaVersion = 1`; `media_items` + `movie_details`; **2-state enum** (`onWatchlist`, `inCollection`) as TEXT; `EnumNameConverter<MediaType>` and `EnumNameConverter<MediaStatus>` wired at column level (see §4.4); DAOs; **Drift repository tests added here** | ⏳ Pending |
| 3b | TMDB search interface | `MediaSearchClient` abstract interface (locked signature); `DioMediaSearchClient` impl with API-key interceptor; TMDB DTOs; `SearchRepository`; **idempotency on add** with `AlreadyInCollection` exception (see §7.1); offline fallback (manual-entry form); API key in `lib/secrets.dart` | ⏳ Pending |
| 4 | Riverpod over drift | `databaseProvider`, `moviesListProvider`, `searchProvider`; CRUD via providers; **provider tests added here** | ⏳ Pending |
| 5 | Full CRUD UI (Movies only) | Add / Edit / Delete on Movies; TMDB search page; results grid; AddSheet; widget tests. **No TV Shows mirror in v1.** | ⏳ Pending |
| 6 | Polish | Material 3 theme + custom seed + typography ramp; empty states; offline UX; accessibility; error states; optional integration test | ⏳ Pending |
| 7 | Wrap-up | `ROADMAP.md` documents v2 features; Supabase plan; multi-user migration plan; one retrospective on locked decisions vs. hunches | ⏳ Pending |

One commit per phase (or per sub-phase when a phase contains two
independent concerns — see Phase 3a / 3b), per the convention in the
working doc.

### 13.1 Iteration ↔ phase mapping

- **v1 ships Movies only (I1).** Phases 1–6 cover Movies end-to-end.
- **TV Shows (I2) and Anime (I3) are deferred to v2+.** v2 phase structure
  is in §18 below; the actual v2 phases are placeholders until this plan
  is extended.
- **v2** (sharing + community + recommendations + Supabase + import) = §18
  phase slots — explicitly out of v1 scope.

---

## 14. Done Definitions

### U1 — Tooling (✅ done)

- `flutter doctor` clean
- emulator-5554 online
- default counter app launched

### U2 — Static catalogue hub (🚧 in progress)

- `lib/features/catalogue/data/movie.dart` — value object
- `lib/features/catalogue/data/sample_movies.dart` — 5 `const Movie(...)` entries + `collectedMovies` / `toConsumeMovies` getters
- `lib/features/catalogue/widgets/movie_card.dart`
- `lib/features/catalogue/widgets/hub_card.dart`
- `lib/features/catalogue/my_collection_page.dart`
- `lib/features/catalogue/to_consume_page.dart`
- `lib/features/catalogue/catalogue_page.dart` + `main.dart` rewrite

**Verify:** launch → Catalogue hub shows → tap Collection card → 3 movies visible → back → tap To Consume card → 2 movies visible.

### U3 — Drift schema (Phase 3a)

- `lib/data/database.dart` — `AppDatabase extends GeneratedDatabase`, `schemaVersion = 1`
- `lib/data/tables/media_items.dart` — `EnumNameConverter<MediaType>` and `EnumNameConverter<MediaStatus>` wired at the column level (see §4.4)
- `lib/data/tables/movie_details.dart` — joined by `media_item_id`; unique partial index on `tmdb_id`
- `MigrationStrategy.onCreate` builds both tables + indexes
- `MigrationStrategy.onUpgrade` includes additive migration steps (placeholder for v2 — no steps needed in v1)
- `lib/data/daos/movie_dao.dart` — typed queries, including `findByTmdbId(int)` for idempotency (§7.1)
- 4-5 repository tests: insert, query, delete, migration v1→v2, `findByTmdbId` returns existing row

### U4 — TMDB search interface (Phase 3b)

- `lib/core/http/media_search_client.dart` — abstract interface with locked signature: `Future<List<MediaSearchResult>> search({required String query, required MediaType mediaType})`
- `lib/core/http/dio_media_search_client.dart` — Dio-backed v1 impl with API-key interceptor; routes `/search/movie` and `/search/tv` based on `mediaType`
- `lib/core/http/tmdb/dtos.dart` — TMDB response DTOs
- `lib/data/repositories/errors.dart` — `AlreadyInCollection` exception type
- `lib/data/repositories/search_repository.dart` — wraps `MediaSearchClient`; translates `AlreadyInCollection` into user-facing snackbar
- API key source: `lib/secrets.dart` (gitignored) or env var
- Offline fallback: manual-entry form when `MediaSearchClient` returns `MediaSearchUnavailable`
- `MediaSearchClient` is the integration point for v2's `resolveTitle`
  import primitive (free-text title → `tmdb_id` lookup). v1 interface
  signature is forward-compatible; no v1 refactor needed.

### U5 — Providers

- `lib/providers/database_provider.dart`
- `lib/providers/movies_list_provider.dart`
- `lib/providers/search_provider.dart`
- 2-3 provider tests via `ProviderContainer.test`

### U6 — Full CRUD UI

- SearchPage → SearchResultsPage → AddSheet flow
- Edit sheet (tap MovieCard → EditSheet)
- Delete confirmation
- Pull-to-refresh scaffold
- Offline behavior verified manually
- 3-4 widget tests

### U7 — *(removed — TV Shows deferred to v2; see §18 v2a)*

### U8 — Polish

- Material 3 theme finalized
- **Single seed color** locked; dark theme shipped in v1, light palette derived from the same seed via `ColorScheme.fromSeed(seedColor: …, brightness: Brightness.light)` but not shipped
- Typography ramp: Source Serif 4 (display/headline) + Inter (title/body/label) via `google_fonts`
- Material Symbols Rounded font bundled as asset; `IconData(fontFamily: 'MaterialSymbolsRounded', fontPackage: …)` used everywhere
- Spacing scale locked (8px baseline, 12px card padding, 16px gaps, 12dp card radius)
- Dark theme verified
- Empty-state widgets
- Accessibility pass (semantics labels, focus order)

### U9 — Wrap-up

- `ROADMAP.md` documents v2 features + Supabase plan + migration plan
- One retrospective on locked decisions vs. original hunches

---

## 15. Conventions recap

Carried over from `Users decisions & current progress.md` section H:

- One commit per phase boundary — or per sub-phase when a phase contains
  two independent concerns (e.g., Phase 3a schema + Phase 3b TMDB
  client).
- No comments in code unless explicitly requested.
- Official packages only — no unverified third-party ones.
- All dependency versions pinned exactly in `pubspec.yaml` to avoid drift
  mid-build.

---

## 16. Decisions log

All decisions made in this planning session, locked at the time of writing.

### 16.1 Product & scope

| # | Decision | Choice |
|---|---|---|
| D1 | Product positioning | Unified tracker + local-first growth + social-as-core (community features are the long-term value, deferred to v2) |
| D2 | v1 sharing | Deferred to v2 — v1 is personal-tracking only |
| D3 | v1 bottom nav | Single-page for v1; nav ships with v2 |
| D4 | Add-movie flow scope | TMDB search + results grid + AddSheet in v1; saved-search-session feature REMOVED |

### 16.2 Data

| # | Decision | Choice |
|---|---|---|
| D5 | Data model | Hybrid — `media_items` (base) + `*_details` (per type). Movie is the only v1 type. |
| D6 | `media_items.type` storage | Plain `TEXT` — no CHECK or ENUM. Schema-change-free when widening type set. |
| D7 | Status enum | **2 states** in v1: `onWatchlist`, `inCollection`. `onCollabLists` deferred to v2. The other three states (`currentlyConsuming`, `dropped`, `upcoming`) are added in v2 with the detail/edit sheet that surfaces them — see §5.2. |
| D8 | Hub mapping | Strict 2-card (Collection = `inCollection`, To Consume = `onWatchlist`). |

### 16.3 Tech stack

| # | Decision | Choice |
|---|---|---|
| D9 | TMDB client | `Dio` for v1, behind `MediaSearchClient` interface (`search({query, mediaType}) → List<MediaSearchResult>`). Swap to a regenerated client (e.g., `openapi_generator`) in v2 when all 12 media types ship — touches the impl only. |
| D10 | Theme | Material 3 + **single** custom seed color + intentional typography/spacing. Light + dark both derived from the same seed. Vivaldi-style customization stays v2. |
| D11 | `copyWith` source | Drift-generated in Phase 3. Freezed wrapper is a future-refactor option (probably Phase 5/6 if sealed unions needed). |
| D12 | v2 auth | **Supabase** (Postgres + Auth + RLS + Realtime + Storage). Open-source; Postgres-portable; cheap at scale; RLS purpose-built for community permissions. Migration to custom Python+Postgres is feasible (`pg_dump` + auth re-implementation, ~2 weeks). |

### 16.4 Process

| # | Decision | Choice |
|---|---|---|
| D13 | Migration story | Additive migrations per phase via `MigrationStrategy.onUpgrade`. `stepByStep` codegen helper when useful. Existing user data preserved across every migration. |
| D14 | Testing breadth | Per layer per phase: drift repo tests in Phase 3a, provider tests in Phase 4, widget tests in Phase 5, optional integration test in Phase 6. ~150 lines of test code total across v1. |

### 16.5 Cross-cutting decisions (locked during revision)

These were added after the initial planning session, in response to
review of the original plan. Each is locked at the time of writing.

| # | Decision | Choice |
|---|---|---|
| D15 | Material import strategy | `package:flutter/material.dart` while on Flutter 3.44.x. Migrate to `material_ui` / `cupertino_ui` first-party packages in a single dedicated commit on the next Flutter major bump. Tracking: flutter/flutter#184093. |
| D16 | Image caching | `flutter_cache_manager` directly with `Image.network`, **not** `cached_network_image`. Reason: cached_network_image last released 23 months ago, publisher is `baseflow.com` (not Flutter team), active community concerns about maintenance — violates rule #7. `flutter_cache_manager` provides the same disk-cache primitive with no third-party UI dependency. |
| D17 | Icons | **Material Symbols Rounded font, bundled as asset**. Use `IconData(fontFamily: 'MaterialSymbolsRounded', fontPackage: …)`. Reason: no official Flutter-team package wraps Material Symbols; bundling the Google-licensed font respects rule #7. |
| D18 | Fonts | **`google_fonts`** for Source Serif 4 (display/headline) + Inter (title/body/label). Reason: verified publisher `flutter.dev` — satisfies rule #7. |
| D19 | Seed color | **One** seed for both brightness modes. `ColorScheme.fromSeed(seedColor: …, brightness: Brightness.light/dark)` derives both palettes. Two seeds = visual whiplash on theme toggle. |
| D20 | Status enum v1 | **2 states only** (`onWatchlist`, `inCollection`). The other 3 states (`currentlyConsuming`, `dropped`, `upcoming`) are added in v2 with the detail/edit sheet that surfaces them. Reason: storing values the UI cannot surface creates invisible QA debt; the trivial Drift migration cost is not worth paying in v1. |
| D21 | Add-movie idempotency | Repository runs `findByTmdbId` before `INSERT`; throws `AlreadyInCollection` on hit. `SearchRepository` translates it into a user-facing snackbar ("Already in your Collection" / "Already on your To Consume list"). The unique index on `movie_details.tmdb_id` is the last-line defense. |
| D22 | Provider per type | Locked table in §4.3. One provider per media type. No multi-provider reconciliation (e.g., a book in both Google Books and OpenLibrary uses only the canonical provider). Re-evaluated only when a new media type is added. |
| D23 | Games provider | **RAWG** (not IGDB). Reason: verified against [Twitch Developer Forum](https://discuss.dev.twitch.com/t/igdb-authentication-and-tokens-need-server-app/28394) that IGDB rate-limits at 4 req/s **per Client ID, not per user** — per-user Twitch OAuth does not give per-user rate-limit pools. RAWG's 20k req/month is predictable, requires no OAuth, and needs no proxy backend. |
| D24 | Games attribution (v2) | Every page displaying RAWG data or images must include an active hyperlink back to RAWG (per [RAWG API ToS](https://rawg.io/apidocs)). Implementation: per-card "View on RAWG" link on `MovieCard`-equivalent for Games; or page-level footer. Locked when Games ships in v2. |
| D25 | `source` + `imported_at` columns in v1 | `media_items.source TEXT NOT NULL DEFAULT 'manual'`; `media_items.imported_at DATETIME NULL`. Forward-compatible with v2 import — no v2 schema migration needed. NULL `imported_at` means manual; non-NULL means imported at that time. Migration pattern: §11.3. |
| D26 | Backend mega-database lives on Supabase | `media_universe` table on Supabase Postgres, populated by ETL pipeline from each provider in §4.3. App queries via PostgREST/Realtime; falls back to provider APIs on miss. Strict separation from local `media_items` (§4.5). Join key: per-type external id columns. D12 is expanded: Supabase hosts both auth and the mega-DB. |
| D27 | `resolveTitle` signature deferred to v2 | `MediaSearchClient` (§U4) is the integration point; actual `resolveTitle(String) → ...` signature is locked at v2 planning when the import pipeline shape is concrete. v1 interface is forward-compatible. |
| D28 | `MediaType` enum v1 | Only `MediaType.movie` is valid in v1. `EnumNameConverter<MediaType>` wired at column level (see §4.4). Extension to `tv_show`, `anime`, etc. in v2 via the converter; no schema change required for `media_items.type` since it is plain TEXT. |
| D29 | Routing library | `go_router` (verified publisher `flutter.dev`). Last release: 49 days ago, v17.3.0. Reason: Flutter Favorite; feature-complete; declarative routing. v1 ships a single `/` route (single-page per D3); v2 uses nested routes + deep links. License: BSD-3-Clause. |

---

## 17. Next step

**Phase 1, Step 2** — `lib/features/catalogue/data/sample_movies.dart`.
About 30 lines: 5 `const Movie(...)` entries + two getters
(`collectedMovies`, `toConsumeMovies`) filtering by `status`.

When ready to move to Phase 3, the Data Model changes above are the
source of truth; cross-reference `Users decisions & current progress.md`
for the prior progress.

---

## 18. v2 and v3 Phases

v1 ships Movies only (I1). v2 widens the type set to TV Shows, Anime,
Books, Games, Podcasts, Comics, Documentaries, Music videos, K-Drama,
and Cartoons; adds a Supabase backend, sharing, community circles, and
import pipelines. v3 adds cross-platform targets (iOS, Web, Desktop)
and customizable theming.

The slots below are placeholders. Each phase entry is filled in
when v2/v3 work begins; the user (or the tutor, with the user
pasting) populates the "From PROJECT_PLAN.md §13" and "Done
Definition" lines from this plan once it is extended.

See `agent_docs_tutor/04-PHASE-GUIDE.md` §"v2 phase slots" and
§"v3 phase slots" for the same structure in the tutor doc set.

### Phase v2a — Widen type enum + first new type (TV Shows)

**From PROJECT_PLAN.md §13:** *(paste here)*
**Done Definition from §14:** *(paste here)*

### Phase v2b — Add Supabase backend + auth

**From PROJECT_PLAN.md §13:** *(paste here)*
**Done Definition from §14:** *(paste here)*

### Phase v2c — Add Explore page + recommendation algorithm

**From PROJECT_PLAN.md §13:** *(paste here)*
**Done Definition from §14:** *(paste here)*

### Phase v2d — Add Community + sharing (web links, circles)

**From PROJECT_PLAN.md §13:** *(paste here)*
**Done Definition from §14:** *(paste here)*

### Phase v2e — Add import pipeline (Letterboxd CSV, iMDB ratings.csv, etc.)

**From PROJECT_PLAN.md §13:** *(paste here)*
**Done Definition from §14:** *(paste here)*

### Phase v2f — Add export (JSON / CSV) + data portability

**From PROJECT_PLAN.md §13:** *(paste here)*
**Done Definition from §14:** *(paste here)*

### Phase v3a — Cross-platform: iOS

**From PROJECT_PLAN.md §13:** *(paste here)*
**Done Definition from §14:** *(paste here)*

### Phase v3b — Cross-platform: Web + Desktop (PC app)

**From PROJECT_PLAN.md §13:** *(paste here)*
**Done Definition from §14:** *(paste here)*

### Phase v3c — Customizable UI (Vivaldi-style theming)

**From PROJECT_PLAN.md §13:** *(paste here)*
**Done Definition from §14:** *(paste here)*

---

## 19. Open questions for v2/v3

These are roadmap features (per `Media Tracking Roadmap.png`) that
need explicit decisions before they can be phased. Until then, they
are aspirational; v2/v3 phase slots above are placeholders.

- **"MOB databases"** — the roadmap image mentions "Import from
  MyAnimeList, IMDB, MOB databases." `MOB` is not defined. Possibilities:
  Moby (manga/books), an internal project name, or a typo. Needs
  resolution at v2 planning.
- **PC App and Website** — listed in the roadmap as separate from
  Mobile. v3b slot covers both; if they need separate phases, the slot
  count grows.
- **Vivaldi-style theming** — listed in roadmap and in §2.3 as v2
  scope. v3c slot is the placeholder; could be v2c or v3c depending on
  prioritization.
- **Start / Dashboard page** — roadmap shows a separate "Start" page
  with current consumption overview (e.g., stats, recently added).
  Not currently in any v1, v2, or v3 phase slot. Either folds into v1
  catalogue hub or needs its own slot.
- **Swipe-based mutual watchlist matching ("Tinder for media")** —
  listed in §2.3 as v2 scope. No specific phase slot; could be v2c
  (recommendation) or its own v2g.
- **Custom user themes** — listed in §2.3 as v2 scope. v3c slot
  covers "Vivaldi-style" theming; if simpler customization ships first,
  it may need its own slot.

Each question above needs a decision (typically in a future revision
of this plan) before the corresponding v2/v3 phase slot can be
populated.
