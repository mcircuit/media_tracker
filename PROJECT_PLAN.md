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
to consume in one unified library — Movies in v1; TV Shows, Anime,
Video Games, Books, and Comics in v2 — eventually with sharing and
recommendations for people I trust.

### 1.2 Primary user and core need

**v1:** the developer themselves. A self-described media omnivore who
currently bounces between Letterboxd, MyAnimeList, Goodreads, Backloggd,
and podcast apps. Core need: one place that holds every kind of media
and grows with them.

**v2:** the user's close circles — family, friends — who want to see
recommendations and send them back.

### 1.3 First-session flow (v1, no sign-up)

The v1 user journey follows the wireframes in `images/` and `Idea.png`
(D-L1). Surface terminology: HubCards are "Collection" and "Bucketlist";
the Catalogue Page is the hub; the Search Page is a full-page route with
5 states A–E (see §7 for details). Status enum is `MediaStatus.onBucketlist`
(D-L13); UI label "Bucketlist".

1. Launch app → **Landing Page** opens immediately. Movies tile is the
   only tappable surface; below it, the text "Next Media Type: TV Shows
   — coming soon!" is displayed (D-L7).
2. Tap the Movies tile → **Home Page** opens, showing the Watchlist
   horizontal carousel. The Collab and Upcoming carousels are deferred
   to v2 (D-L8).
3. The bottom nav has 2 tabs in v1: **Home** and **Catalogue**. The
   Community and Explore tabs are reserved for v2 (D-L3).
4. Tap the **Catalogue** tab → **Catalogue Page** opens, the hub with 2
   large HubCards (Collection, Bucketlist). No FAB on this page (D-L9).
5. Tap the **Collection** HubCard → **Collection Page** opens
   (Statistics block + Search field + Media Filter button + 3-col grid
   + FAB; D-L10).
6. Tap the **Bucketlist** HubCard → **Bucketlist Page** opens (mirror
   of Collection Page; data filtered to `MediaStatus.onBucketlist`; D-L11).
7. Tap the **+** FAB on Home, Collection, or Bucketlist → **Search
   Page** opens as a full-page route at `/search?q=<query>&type=movie`
   (Q10). 'X' close button at top right; exit-confirm prompt at State C
   and State E.
8. Type a movie title → TMDB returns results in a 3-col grid below the
   search bar (Search Page **State B**).
9. Tap a result → the status toggle + rating screen for the selected
   title appears inline in the Search Page (**State C**). Two bottom
   buttons: **Done** (saves the single title and exits) or **Explore
   Similar Titles** (continues to State D).
10. If continuing, similar titles populate the screen (**State D**).
    Long-press to multi-select; tap **Add** at the bottom.
11. The selected titles appear in a confirmation screen with a
    Collection / Bucketlist toggle at the top and per-item remove
    (**State E**). Tap **Add to \<Destination\>** at the bottom to save
    all selections to the toggle's destination and exit. The label
    updates reactively as the user toggles (Q2 E2).
12. Returning to the FAB's origin page → the new movie(s) appear on the
    matching HubCard or list.

### 1.4 Three most important v1 features

1. **Add a movie via TMDB search** — creates all the data the rest of
   the app shows.
2. **Hub catalogue (Collection / Bucketlist cards)** — the place the
   user returns to daily.
3. **Edit / rate / move between statuses** — the action that rewards
   repeat visits.

If any of these break, v1 fails.

---

## 2. Scope

### 2.1 In scope for v1

- Movies media type only
- Local-first persistence (Drift + SQLite, no backend)
- TMDB read-only search for adding movies
- Manual-entry fallback when TMDB is unreachable
- Hub catalogue page (Collection / Bucketlist cards)
- 2-state status enum (`onBucketlist`, `inCollection`)
- Material 3 theming with custom seed color
- Both light and dark themes shipped in v1 (D-L2). Both palettes derive
  from a single seed color via `ColorScheme.fromSeed(seedColor: …,
  brightness: Brightness.light/dark)`. `themeMode: ThemeMode.system`
  lets the OS toggle decide.
- Offline-first behavior

### 2.2 Out of scope for v1

- All other media types (TV Shows, Anime, Video Games, Books, Comics)
- Sharing via PDF / web link
- Community circles, recommendations, swipe-matching
- Auth, multi-user, backend, cloud sync 
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
- Custom UI theming (Vivaldi-style)
- `onCollabLists` 6th media status state
- **Import from external platforms** — let users bring in their existing
  tracking history. v2 sources to evaluate, in priority order:
    1. **Letterboxd CSV** (movies) — documented import format, no API
       needed, no OAuth.
    2. **iMDB `ratings.csv`** uploaded by user, enriched via TMDB
       lookups per row.
    3. **Primitive plain-text lists** — heuristic parsing + manual
       review UI for low-confidence matches.
    4. **MAL via JIKAN, Trakt, Backloggd, Steam, Spotify, Goodreads**
       — per-platform OAuth + schema work; re-evaluated at v2 kickoff.

  Each source requires:
    - A fetcher (CSV upload, OAuth API, scrape)
    - A field mapper (iMDB 1–10 ; Letterboxd 0.5-step →
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
  §4.3 (TMDB, RAWG, Open Library, AniList, Comic
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
| Navigation | `go_router` | Declarative, ready for v2 deep linking / web; Phase 1 used `MaterialApp` (home: parameter); Phase 2 introduced go_router with 11 routes per §6.5; v1 ships go_router throughout |
| HTTP | `dio` | Behind a `MediaSearchClient` interface so v2 can swap to a regenerated client without touching call sites |
| Image cache | `flutter_cache_manager` (direct, **not** `cached_network_image`) | Disk-cached posters; `cached_network_image` last released 23 months ago and is rule #7 suspect — we use `flutter_cache_manager` directly with `Image.network` |
| Fonts | `google_fonts` (verified publisher `flutter.dev`) | Source Serif 4 (display/headline) + Inter (title/body/label); official publisher satisfies rule #7 |
| Icons | Material Symbols Rounded font, bundled as asset | No official Flutter wrapper exists for Material Symbols as of plan-date; bundling the **Apache License 2.0** font at `assets/fonts/MaterialSymbolsRounded.ttf` respects rule #7 (D17) |
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

**`MaterialApp(routerConfig: ...)` shortcut does not compile on
Flutter 3.44.x.** The main `MaterialApp(...)` constructor does not
accept `routerConfig:` as a parameter (only initializes it to null).
The dedicated `MaterialApp.router(routerConfig: ...)` constructor is
the only entry point that wires a `GoRouter` (lesson from Phase 2).
§6.2 reflects this.

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
rating (REAL, nullable, 0–10)         poster_url (TEXT, nullable)
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
`WHERE imported_at IS NULL` / `IS NOT NULL`. The columns ship in
v1's initial schema; no migration is required.

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
| TV Shows | TMDB | `tv_show_details` | `tmdb_id` (INT, nullable, unique) | Same TMDB API key | TMDB v3 `/tv/{id}` and `/search/tv`; movie and TV IDs are in separate id-spaces |
| Book | Open Library *(TBD v2)* | `book_details` | `olid` (TEXT, nullable, unique) | None — read endpoints are unauthenticated | Canonical id is OLID (`OL…W` for works, `OL…M` for editions) |
| Game | **RAWG** | `game_details` | `rawg_id` (INT, nullable, unique) | API key in `lib/secrets.dart` | [rawg.io/apidocs](https://rawg.io/apidocs); **attribution hyperlink required** on every page using RAWG data or images |
| Anime | AniList *(TBD v2)* | `anime_details` | `anilist_id` (INT, nullable, unique) | None — GraphQL is keyless | [docs.anilist.co](https://docs.anilist.co/); supports `idMal` cross-reference to MAL |
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

Two states in v1, locked (D7, D20):

| Enum value | Meaning | Hub card label (wireframes) |
|---|---|---|
| `MediaStatus.onBucketlist` | Want to consume | **Bucketlist** |
| `MediaStatus.inCollection` | Consumed | **Collection** |

Canonical enum value & UI label: `onBucketlist` / **"Bucketlist"** (D-L13).
Source of truth: the wireframes in `images/`. Earlier draft referred to
the second state as "To Consume" — that label is retired.

`MediaStatus.onCollabLists` is deferred to v2 (D20).

### 5.1 Hub mapping (strict, v1)

- **Collection** HubCard → filters `media_items` where `status = 'inCollection'`
- **Bucketlist** HubCard → filters `media_items` where `status = 'onBucketlist'`

The wireframes in `images/Bucketlist Page.png` and `images/Catalogue Page.png`
are the source of truth for these labels (D-L1).

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

### 6.1 What the App Shell is

The App Shell is the persistent scaffolding around every page: theme, status bar, top app bar, hamburger menu, bottom navigation, FAB, and the `go_router` route table. It does **not** own per-page content (cards, lists, search fields); it owns the chrome around them.

The Shell is implemented once in `lib/app/` (`theme.dart`, `router.dart`) and reused by every page via a single `AppScaffold` widget in `lib/shared/`. Pages declare only their body's content; the chrome is supplied by `AppScaffold` reading the current route.

### 6.2 `MaterialApp.router` configuration (root)

```dart
MaterialApp.router(
  title: 'Media Tracker',
  theme: buildAppTheme(brightness: Brightness.light),  // see §6.3
  darkTheme: buildAppTheme(brightness: Brightness.dark),
  themeMode: ThemeMode.system,                         // D-L2
  routerConfig: buildAppRouter(),                      // see §6.5
);
```

Notes:
- `MaterialApp.router(...)` is the canonical constructor on Flutter 3.44.x;
  the `MaterialApp(routerConfig: ...)` shortcut does **not** compile (Phase 2
  lesson log).
- `themeMode: ThemeMode.system` lets the OS toggle decide; v1 ships both
  palettes so no extra code is needed when the user changes the OS theme.
- `title` shows in the OS app-switcher surface.

### 6.3 Theme (light + dark, single seed)

- **Single seed color** locked in Phase 6 polish. Direction: deep blue /
  indigo. Both palettes derive from this seed via
  `ColorScheme.fromSeed(seedColor: …, brightness: Brightness.light/dark)`
  (D10, D19, D-L2).
- Palette mapping per `lib/app/theme.dart` color tokens — the
  colors table stays; dark hex values fill the "brightness dark" row
  and the equivalent light hex values fill the light row.
- **Typography**: Source Serif 4 (display/headline) + Inter
  (title/body/label) via `google_fonts` (D18). Verified publisher
  `flutter.dev`.
- **Icons**: Material Symbols Rounded, bundled as an asset at
  `assets/fonts/MaterialSymbolsRounded.ttf`. License: **Apache License 2.0**
  (correcting the prior "Google-licensed" wording). Used via
  `IconData(fontFamily: 'MaterialSymbolsRounded', fontPackage: 'media_tracker')`.
  Note: the official Flutter wrapper for Material Symbols is **not yet
  released** as of plan-date; we consume the font directly (D17).
- **Spacing**: 8px grid baseline (5 tokens per `05` §4: 4/8/16/24 dp; plus
  2 dp sub-grid escape hatch).
- **Radius**: 4 tokens (`05` §5: 8/12/20/9999 dp).
- **Motion**: 3 tokens (`05` §6: 150/250/400 ms). Honor
  `MediaQuery.disableAnimations` for OS "reduce motion": replace `motion/
  default` and `motion/slow` with `Duration.zero`, keep `motion/fast`.

### 6.4 Top app bar + hamburger menu

Every page (except Landing and full-screen overlays) renders:

```
+----------------------------------------------+
|  [title]                              [≡]    |  ← AppBar: title + hamburger
+----------------------------------------------+
|                                              |
|  body                                        |
|                                              |
+----------------------------------------------+
|     Home        |       Catalogue            |  ← 2-tab bottom nav (v1)
+----------------------------------------------+
```

- `AppBar(title: Text(<page title>), actions: [hamburger IconButton])`.
- Hamburger button opens the **Hamburger Menu overlay** (D-L12): 5 stacked
  buttons — Profile, Media Type, Settings, Help, About. Each button's
  behavior is "kept simple, defined at coding time" per user direction;
  no admin/config screens in v1.
- The AppBar title is provided by the page; the hamburger icon is fixed
  by `AppScaffold`.

### 6.5 `go_router` route table

| Path | Page | Notes |
|---|---|---|
| `/` | `LandingPage` | Initial route; tile grid (§6 / D-L7). |
| `/home` | `HomePage` | Bottom-nav tab 1; Watchlist carousel (D-L8). |
| `/catalogue` | `CataloguePage` | Bottom-nav tab 2; hub (§6 / D-L9). |
| `/catalogue/collection` | `CollectionPage` | Child route; full Search + Filter + grid (D-L10). |
| `/catalogue/bucketlist` | `BucketlistPage` | Child route; mirror of Collection (D-L11). |
| `/search` | `SearchPage` | Full-page route with 5 states A–E (see §6.9). 'X' pops; exit-confirm at C and E. |
| `/profile` | `ProfilePage` | Hamburger target. Stub. |
| `/media-type` | `MediaTypePage` | Hamburger target. v1 = Movies-only. |
| `/settings` | `SettingsPage` | Hamburger target. Stub. |
| `/help` | `HelpPage` | Hamburger target. Stub. |
| `/about` | `AboutPage` | Hamburger target. Stub. |

`buildAppRouter()` returns a `GoRouter` with `initialLocation: '/'`.
Bottom-nav active-tab state reads `GoRouterState.of(context).uri`:

| Active tab | Condition |
|---|---|
| Home | `path == '/home'` |
| Catalogue | `path.startsWith('/catalogue')` |
| (none) | `/search`, `/profile`, `/media-type`, `/settings`, `/help`, `/about` |

`MaterialApp.router(routerConfig: ...)` is the only entry point on
Flutter 3.44.x. `Navigator.push` remains compatible for legacy code
(verified Phase 2).

### 6.6 Bottom navigation (2 tabs in v1)

```
+----------------------------------------------+
|       Home        |       Catalogue          |  ← v1: 2 tabs only
+----------------------------------------------+
```

- 2 tabs in v1: **Home**, **Catalogue** (D-L3). Community and Explore do
  **not** render in v1; they appear in v2 by widening `BottomNavigationBar.items`
  to length 4 without changing `AppScaffold`'s signature.
- Active tab uses `color/primary` (sapphire per `05` §2); inactive uses
  `color/on-surface-variant`. Tab target ≥ 48dp (`05` §7 a11y).
- v1 routes with no tab (Search, hamburger pages) suppress the
  `BottomNavigationBar` entirely; `AppScaffold` reads the route and
  decides.

### 6.7 Floating Action Button

The FAB renders on **Home, Collection, Bucketlist** pages only (per
updated wireframes). It does **not** render on the Catalogue hub, Search
Page, Hamburger Menu pages, or stubs.

- Icon: `MaterialSymbolsRounded.add` (24dp default per `icon/md`).
- `onPressed`: `context.push('/search')` (pushes onto the route stack).
- Position: `floatingActionButtonLocation:
  FloatingActionButtonLocation.endFloat`.

### 6.8 Page chrome — `AppScaffold`

A single widget in `lib/shared/app_scaffold.dart` wraps every page:

```dart
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.title,
    required this.body,
    this.showFab = false,
  });

  final String title;
  final Widget body;
  final bool showFab;
}
```

It produces: `Scaffold` + `AppBar(title, hamburger)` + body + (optional)
`FloatingActionButton(add → context.push('/search'))` + 2-tab
`BottomNavigationBar` (or none, per §6.6). The page declares only its
body's content; the AppShell supplies everything else.

Visual chrome the page **must not** duplicate: `AppBar`, `Drawer`,
`BottomNavigationBar`, `FloatingActionButton`. Duplicates are code-review
violations (I-7 enforcement via review).

### 6.9 Modal / sheet conventions

- **All 5 states of the Search Page render in v1.** State A (search
  input) → State B (results grid) → State C (status + rating for the
  selected title; user picks "Done" to end or "Explore Similar
  Titles" to continue) → State D (similar-titles multi-select via
  long-press) → State E (final confirm with Collection/Bucketlist
  toggle and per-item remove; "Done" here ends the flow with all
  selections saved).
- **State C of the Search Page is rendered as a full-page state, not a
  `ModalBottomSheet`.** Rationale: the State C → D transition needs a
  continuous scroll and focus context (the page "expands" to show similar
  titles in the same viewport). Splitting State C into a `ModalBottomSheet`
  would force three route transitions (close sheet, push similar-titles,
  push confirm) where one continuous state machine suffices. v2 may refactor
  State C to a separate `ModalBottomSheet` for features that benefit from
  a modal surface (system share intent, drag-to-dismiss gestures, partial-
  state persistence across restarts); v1 ships it inline.
- **EditSheet** is a `ModalBottomSheet` triggered from `MovieCard.onTap`
  on Collection / Bucketlist pages. Same fields as State C's content
  (status + rating), prefilled with the existing data. Has a `Delete`
  action with a confirm dialog per D-L6.
- **AddSheet as a separate `ModalBottomSheet` is v2-only.** v1 absorbs
  it into State C of the Search Page route (above). Future refactor
  documented here so reviewers don't push for the modal form during v1.
- **Exit confirmation**: the Search Page 'X' prompts a confirm dialog
  when leaving State C or State E with unsaved selections (no dialog
  at A, B, D — those states are recoverable by re-tapping a result or
  re-selecting).
- **State machine of Search Page** lives in `lib/features/search/`
  (see §7 Add-Movie Flow rewrite).

### 6.10 Loading / error / empty states

- **Loading**: `CircularProgressIndicator(color: color/primary)` centered
  in the body's available space.
- **Error**: `AlertDialog(color: color/surface, radius: radius/lg)` with
  a retry action. Used for repository failures (e.g., Drift constraint
  violation), HTTP failures outside the Search Page flow.
- **Empty**: placeholder widget centered, `bodyMedium` text,
  `color/on-surface-variant`. Examples:
  - Empty Collection / Bucketlist: "No movies yet — tap + to add one."
  - Empty Search Results: "No matches for '<query>'."
  - Empty Manual Entry list (offline fallback): "TMDB is unavailable —
    type a title above to add it manually."

### 6.11 Asset pipeline summary

| Asset | Path | Source |
|---|---|---|
| Theme | n/a | `lib/app/theme.dart` (`buildAppTheme`) |
| Router | n/a | `lib/app/router.dart` (`buildAppRouter`) |
| AppScaffold | n/a | `lib/shared/app_scaffold.dart` |
| AppBar widget, hamburger IconButton | n/a | `lib/shared/widgets/` |
| Source Serif 4 + Inter fonts | runtime fetch | `google_fonts` 6.x (D18) |
| Material Symbols Rounded font | `assets/fonts/MaterialSymbolsRounded.ttf` | Apache 2.0 bundle (D17) |
| TMDB poster cache | disk | `flutter_cache_manager` (D16) |
| App icon, splash | standard Flutter | n/a |

Pubspec asset declaration:

```yaml
flutter:
  fonts:
    - family: MaterialSymbolsRounded
      fonts:
        - asset: assets/fonts/MaterialSymbolsRounded.ttf
```

### 6.12 Build / dev / test environment

- **Android-only build** (deferred iOS / Web / Desktop targets are v3).
- **TMDB API key**: `lib/secrets.dart` (gitignored, dev) or
  `--dart-define=TMDB_API_KEY=…` (CI). Fail-fast at the
  `DioMediaSearchClient` constructor (I-14).
- **Drift codegen**: `dart run build_runner build --delete-conflicting-outputs`.
  Output `lib/data/database.g.dart` is gitignored; never hand-edit.
- **Test mirror**: `test/data/`, `test/providers/`,
  `test/features/<feat>/`, `test/integration/` (per I-10).
- **Theme editor**: design-time changes to colors/typography live in
  `lib/app/theme.dart` reads of `Theme.of(context).colorScheme`.

### 6.13 Forward-compatibility notes

- **v2 widens the type set** (D6, §4.3) — the Shell and routing layout
  stay; only `MediaType` enum widens and a per-type filter routes in.
- **v2 widens the bottom nav** to 4 tabs (Home, Catalogue, Community,
  Explore) by setting `BottomNavigationBar.items` to length 4 and adding
  the v2 routes. `AppScaffold` signature unchanged.
- **v3 widens to iOS / Web / Desktop** — the Shell is platform-aware via
  Flutter's adaptive widgets; `go_router` URL strategy configures per
  platform.
- **Supabase backend** (D12, D26) — auth gate and per-user routes added
  at `GoRouter.redirect`; the Shell's UI does not change.

---

## 7. Add-Movie Flow

The single most important interaction in v1. The flow is a 5-state
state machine inside the **Search Page route** (`/search?q=<query>&type=movie`
per Q10). The AddSheet UI is **State C**, rendered inline (not a separate
`ModalBottomSheet`); similar-titles multi-select is **State D**; the
final confirmation with toggle + remove is **State E**. The flow ends
when the user presses **"Add to \<Destination\>"** at State E (multi-title)
or **"Done"** at State C (single title). The "X" close button at the
top right exits the flow at any state; an exit-confirm dialog fires at
States C and E when there are unsaved selections (Q2 E2, Q4, Q7, Q8, Q10).
See §6.9 for the rationale on inline-in-route vs. modal-sheet
treatment of AddSheet.

### 7.0 Flow diagram

```
Home / Collection / Bucketlist
  │ tap [+] FAB
  ▼
State A — SearchPage         ◀── URL: /search?q=<query>&type=movie
  │ user types title, e.g. "The Matrix"
  ▼
State B — SearchResultsView  ◀── 3-col grid; results from TMDB;
  │ user taps one result           manual-entry fallback if
  ▼                                MediaSearchClient returns
State C — AddSheetView           MediaSearchUnavailable (Q4)
  │ status toggle + rating
  ├─ tap "Done" ───────────────▶  save single title, exit flow
  └─ tap "Explore Similar Titles"
                                 ▼
State D — SimilarTitlesView    ◀── 3-col grid; long-press to
  │ multi-select via long-press     multi-select
  │ "Add" button at bottom
  ▼
State E — ConfirmSelectionView ◀── Collection / Bucketlist toggle at top
  │                                per-item remove
  ├─ tap "Add to <Destination>"──▶  save all selections, exit flow;
  │                                label updates reactively (Q2 E2)
  └─ tap "X" with unsaved         ▼
      selection ── confirm       user returns to FAB origin page;
                                 HubCards update
```

### 7.1 State A — Search input

- SearchPage opens via `context.push('/search')` from the FAB on Home,
  Collection, or Bucketlist (D-L4, Q1).
- Top-right 'X' close button (`MaterialSymbolsRounded.close`); tap
  exits without prompt (no unsaved state at A).
- Initial URL: `/search` (no query params). When the user types, the
  URL becomes `/search?q=<encoded query>`; `type=movie` is default in
  v1 and is implicit (Q10, v2 reuse path).
- Internal state held by `SearchPage`: `query`, `searchResults`,
  `selectedMediaItem`, `similarTitles`, `pendingSelections`, `pendingDestination`.

### 7.2 State B — Results grid + manual-entry fallback

- As the user types (or after hitting Search), `MediaSearchClient.search(
  {query: query, mediaType: MediaType.movie})` runs.
- On success: a 3-col grid populates below the search bar.
- On `MediaSearchUnavailable`: State B is replaced with a manual-entry
  form (Q4). See §7.8.
- Tapping a result transitions the Search Page to State C with the
  selected media item loaded into `selectedMediaItem`.

### 7.3 State C — AddSheet (status + rating for the selected title)

- Rendered inline within the Search Page route — **not** a separate
  `ModalBottomSheet`. Rationale: the State C → State D transition needs
  a continuous scroll/focus context (the page "expands" to show
  similar titles in the same viewport). Splitting would force three
  route transitions where one state machine suffices (D-L4 §6.9).
- Fields:
  - **Status toggle**: Collection / Bucketlist. **Default: Collection**
    (Q7 — search-flow default; manual-entry default is Bucketlist, §7.8).
  - **Rating**: 0–10 (slider or star display).
- Bottom row: two buttons.
  - **"Done"** — saves the single title to `media_items` +
    `movie_details` and exits the Search Page.
  - **"Explore Similar Titles"** — transitions to State D, populating
    `similarTitles` from TMDB's `/movie/{id}/similar` endpoint.
- 'X' close button at top right; exit-confirm dialog fires if the user
  hasn't saved.
- Idempotency: §7.7.

### 7.4 State D — Similar titles (multi-select)

- 3-col grid of TMDB-similar titles, populated automatically when the
  user enters State D.
- Long-press to multi-select; checkmark overlay indicates selection.
  Tap toggles the selection state.
- Bottom **"Add"** button — transitions to State E with the multi-
  selected list. If the user doesn't long-press any title, the Add
  button still proceeds with zero additional titles (only the original
  AddSheet addition, from State C).

### 7.5 State E — Confirm selection

- View toggle at top-right (3-col grid / list view); default 3-col grid.
- **Top toggle**: Collection / Bucketlist (single-select). Determines
  the destination for every selected title.
- Per-item **remove** icon on each card/row. User can prune the list
  before commit.
- Bottom **"Add to \<Destination\>"** button — label updates reactively
  as the user toggles between Collection and Bucketlist (Q2 E2). On tap:
  every selected title is inserted into `media_items` + `movie_details`
  with the chosen destination; SearchPage exits via `Navigator.pop`;
  user returns to the FAB's origin page.
- 'X' close button at top right; exit-confirm dialog fires if any
  selection is unsaved (i.e., the toggle differs from the original or
  any remove has happened).

### 7.6 'X' exit + confirm

- At States A, B, D: tapping 'X' exits without prompt (nothing
  unsaved; D is recoverable by re-pressing "Add" from State C).
- At States C and E: tapping 'X' pops a confirm dialog: **"Discard
  your changes? You will lose unsaved selections."** Buttons:
  - **Discard** — exits without saving; pops `/search` route.
  - **Stay** — dismisses the dialog; user remains at the state.

### 7.7 Idempotency on add

The multi-select + similar-titles flow (§7.4) means a user can tap the
same result twice across sessions, and TMDB can return the same movie
under similar queries. Before any `INSERT` into `media_items`, the
repository runs:

```dart
final existing = await movieDao.findByTmdbId(tmdbId);
if (existing != null) {
  throw const AlreadyInCollection(existingId: existing.id);
}
```

`SearchRepository` translates `AlreadyInCollection` into a user-facing
snackbar surfaced on the FAB's origin page:

- `existing.status == inCollection` → **"Already in your Collection"**
- `existing.status == onBucketlist` → **"Already on your Bucketlist"**

The exception type lives at `lib/data/repositories/errors.dart`. The
unique index on `movie_details.tmdb_id` (see §4.1) is the last-line
defense; the pre-check is what surfaces the friendly message.

### 7.8 Manual entry (offline fallback)

Replaces State B when `MediaSearchClient` returns `MediaSearchUnavailable`.
Fields (Q7 locked):

| Field | Type | Required | Notes |
|---|---|---|---|
| Title | text | yes | non-empty validation |
| Year | number | no | integers, 1900–current |
| Genre | chip multi-select | no | v1 vocabulary aligned to TMDB genres |
| Rating | 0–10 | no | slider or star display |
| Status | toggle | yes | **default: Bucketlist** (Q7) |

Save validates Title non-empty; inserts into `media_items` (no
`movie_details` row when `tmdb_id` is null). The Save exits the Search
Page directly, skipping State D and State E (no similar-titles without
TMDB).

### 7.9 File structure under `lib/features/search/` (Q8)

| File | Public class | State |
|---|---|---|
| `search_page.dart` | `SearchPage` | n/a (route entry + state machine) |
| `search_input_view.dart` | `SearchInputView` | A |
| `search_results_view.dart` | `SearchResultsView` | B |
| `add_sheet_view.dart` | `AddSheetView` | C |
| `similar_titles_view.dart` | `SimilarTitlesView` | D |
| `confirm_selection_view.dart` | `ConfirmSelectionView` | E |

Each state is a top-level widget in its own file. `SearchPage` owns the
state machine (`_state` enum or `StatefulWidget` private fields) and
swaps which file's widget renders based on `_state`.

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
- **Light + dark:** **Both palettes shipped in v1** (D-L2). Both
  derive from the single seed via
  `ColorScheme.fromSeed(seedColor: …, brightness: Brightness.light/dark)`.
  `themeMode: ThemeMode.system` (per §6.2) lets the OS decide. The
  AppShell reads `MediaQuery.platformBrightnessOf(context)` to swap
  themes at runtime; no design work is needed.
- **Icons:** **Material Symbols Rounded font, bundled as an asset**.
  Use `IconData(fontFamily: 'MaterialSymbolsRounded', fontPackage: 'media_tracker')`.
  Tonal variants for status. License: **Apache License 2.0** (correcting
  prior "Google-licensed" wording; see §3.0 + D17). No official Flutter
  package wraps Material Symbols (Flutter's built-in `Icons` class is
  the legacy Material Icons set, not Symbols); bundling the font is the
  rule #7-compliant path.

### 8.2 Component library

Built-in Flutter **Material 3** widgets. No third-party UI library.

Widgets in active use:
- `MaterialApp.router` + `Scaffold` (see §6.2; `MaterialApp(routerConfig: …)`
  shortcut does not compile on Flutter 3.44.x)
- `Card` for `MovieCard` and `HubCard`
- `ListView.builder` for Collection / Bucketlist lists
- `GridView.builder` for search results (State B / State D of the
  Search Page, see §7)
- `ModalBottomSheet` for `EditSheet` (D-L6, see §7.3) and the Media
  Filter sheet (Q4) — **not** for AddSheet, which is State C inline
  per §6.9 + §7.3
- `FilledButton`, `IconButton`, `TextField`, `Chip`
- `Image.network(url, cacheManager: DefaultCacheManager())` for posters
  (Phase 5+). `flutter_cache_manager` provides the disk cache layer
  directly — `cached_network_image` is **not** used (rule #7; last
  release 23 months ago).

---

## 9. System Boundaries (folder layout)

Current state — v1:

```
lib/
├── main.dart
└── features/
    └── catalogue/
        ├── data/         # value objects + sample data
        ├── widgets/      # MovieCard, HubCard
        └── *_page.dart   # CataloguePage, MyCollectionPage, BucketlistPage
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
│   ├── search/                        # Phase 5; 5-state Search Page
│   │   ├── search_page.dart           # route entry + state machine
│   │   ├── search_input_view.dart     # State A
│   │   ├── search_results_view.dart   # State B
│   │   ├── add_sheet_view.dart        # State C (inline)
│   │   ├── similar_titles_view.dart   # State D
│   │   └── confirm_selection_view.dart # State E
│   └── (future: explore/, community/, hamburger_stubs/)
├── shared/
│   ├── app_scaffold.dart              # AppShell (per §6.8)
│   └── widgets/                       # AppBar, hamburger IconButton, etc.
├── providers/                         # Riverpod providers, top-level
│   ├── database_provider.dart
│   ├── movies_list_provider.dart
│   ├── search_provider.dart
│   └── filter_provider.dart           # Genre-only filter (Q4)

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
2. **Status enum is the locked 2 states.** v1 ships `onBucketlist` and
   `inCollection` only. `onCollabLists` does not appear anywhere in v1
   code. The other three states (`currentlyConsuming`, `dropped`,
   `upcoming`) are added in v2 — see §5.2.
3. **Type-safe enums only at the boundary.** `media_items.type` and
   `.status` are plain TEXT in storage, but every write path must go
   through the value-object enums in
   `lib/features/catalogue/data/movie.dart` (and successors). Drift
   `EnumNameConverter` (see §4.4) is wired at the column level — no
   free-form strings reach SQLite.
4. **One commit per phase** (or sub-phase when a phase contains two
   independent concerns — see §13 Phase 3 split). Per original working
   doc section H.
5. **Pinned dependency versions.** No `^` or `>=` in `pubspec.yaml` —
   only exact pins.
6. **Official packages only.** No unverified third-party packages.
   Concrete exceptions and reasons are tracked in the Decisions log
   (D16, D17, D18). Where a third-party package is the only viable
   option, document the security/maintenance trade-off in a Decisions
   row before adopting it.
7. **`MediaSearchClient` is the only call site for TMDB.** No `dio`
   imports inside `features/`. The v2 swap to a regenerated client
   (e.g., `openapi_generator`) touches the impl, not the call sites.
8. **Widgets never import Drift directly.** UI reads from Riverpod
   providers; providers read from repositories; repositories read from
   DAOs.
9. **No `setState` for shared state.** Local UI state is fine; anything
    cross-widget goes through Riverpod.


---

## 11. Migrations

Additive migrations per phase via `MigrationStrategy.onUpgrade(from, to)`.

Drift's `stepByStep` codegen helper is the preferred path for
writing migrations: it produces per-step migration files (`database.steps.dart`)
based on schema diffs, so each `fromNToN+1: (m, schema) async { ... }`
callback sees the correct schema snapshot and can't accidentally
reference an un-added column. Generated by `dart run drift_dev make-migrations`.
Use it for every migration unless the schema diff is trivial. (Manual
`if (from < N)` blocks remain a fallback for one-line hot-fixes.)

### 11.1 Adding a new media type (stepByStep worked example)

When v2 adds TV Shows, Anime, etc.:

1. Create the new detail table, e.g. `lib/data/tables/tv_show_details.dart`,
   joined by `media_item_id` to `media_items`.
2. Register it in `AppDatabase`'s `@DriftDatabase(tables: [...])` list.
3. Bump `schemaVersion` (e.g. 1 → 2 for TV Shows, 2 → 3 for Anime).
4. Run `dart run drift_dev make-migrations`. The generator writes
   `database.steps.dart` with the per-step closures; reference that file
   from your migration:
   ```dart
   import 'package:drift/drift.dart';
   import 'database.steps.dart';

   part 'database.g.dart';

   @DriftDatabase(tables: [MediaItems, MovieDetails, TvShowDetails])
   class AppDatabase extends _$AppDatabase {
     AppDatabase(super.e);

     @override
     int get schemaVersion => 2; // bumped for TV Shows

     @override
     MigrationStrategy get migration {
       return MigrationStrategy(
         onCreate: (m) async => m.createAll(),
         onUpgrade: _schemaUpgrade,
       );
     }
   }

   // Extracting stepByStep into an extension ensures the migration
   // code does not accidentally refer to the current database schema.
   // Each step brings the database into the correct snapshot.
   extension Migrations on GeneratedDatabase {
     OnUpgrade get _schemaUpgrade => stepByStep(
       from1To2: (m, schema) async {
         await m.createTable(schema.tvShowDetails);
       },
     );
   }
   ```
5. Write a `SchemaVerifier`-based test that opens the v1 schema, inserts
   a Movie, then opens the v2 schema and asserts the Movie is still
   present and the new table exists.

`media_items.type` and `.status` are plain TEXT, so widening the type
set is **zero schema change** in SQLite — only the new detail table
requires migration steps.

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

| # | Phase | Produces |
|---|---|---|
| 0 | Tooling | `flutter doctor` clean; emulator `emulator-5554` online; default counter app launched |
| 1 | Widget fundamentals + static catalogue hub | Hardcoded `Movie`s, `MovieCard`, `HubCard`, hub page (Collection → Collection / Bucketlist) |
| 2 | App shell | `go_router` config with 11 routes; 2-tab bottom nav in v1; MediaSearchClient interface defined; `MaterialApp.router` wiring. **App is multi-page from v1** (D-L3, D-L4). |
| 3a | Drift data model | `AppDatabase` with `schemaVersion = 1`; `media_items` + `movie_details`; **2-state enum** (`onBucketlist`, `inCollection`) as TEXT; `EnumNameConverter<MediaType>` and `EnumNameConverter<MediaStatus>` wired at column level (see §4.4); DAOs; **Drift repository tests added here** |
| 3b | TMDB search interface | `MediaSearchClient` abstract interface (locked signature); `DioMediaSearchClient` impl with API-key interceptor; TMDB DTOs; `SearchRepository`; **idempotency on add** with `AlreadyInCollection` exception (see §7.7); offline fallback (manual-entry form per §7.8, status defaults to Bucketlist); API key in `lib/secrets.dart` |
| 4 | Riverpod over drift | `databaseProvider`, `moviesListProvider`, `searchProvider`, `filterProvider` (Genre-only, per Q4); CRUD via providers; **provider tests added here** |
| 5 | Full CRUD UI (Movies only) | Add / Edit / Delete on Movies; Search Page 5-state flow (§7.0–§7.6); AddSheet as State C inline; EditSheet as `ModalBottomSheet` from Collection/Bucketlist pages; ManualEntryForm (offline); 6 files under `lib/features/search/`; widget tests. **No TV Shows mirror in v1.** |
| 6 | Polish | Verify light + dark palettes render correctly; verify typography ramp is consistent across pages; empty states; offline UX; accessibility (semantics labels, focus order); error states; optional integration test |
| 7 | Wrap-up | Supabase plan; multi-user migration plan; one retrospective on locked decisions vs. hunches |

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
- `lib/features/catalogue/data/sample_movies.dart` — 5 `const Movie(...)` entries + `collectedMovies` / `bucketListMovies` getters
- `lib/features/catalogue/widgets/movie_card.dart`
- `lib/features/catalogue/widgets/hub_card.dart`
- `lib/features/catalogue/my_collection_page.dart`
- `lib/features/catalogue/bucketlist_page.dart`
- `lib/features/catalogue/catalogue_page.dart` + `main.dart` rewrite

**Verify:** launch → Catalogue hub shows → tap Collection card → 3 movies visible → back → tap Bucketlist card → 2 movies visible.

> **Phase 1 amendment note:** the shipped Phase 1 code uses `MediaStatus.onWatchlist` / `'Bucket List'` / `to_consume_page.dart`. The canonical naming locked by D-L13 is `onBucketlist` / `'Bucketlist'` / `bucketlist_page.dart`; the rename cascade is captured in D33 (§16.5). U2's verify line was edited post-shipping; the file names in the Done Definition match the renames.

### U3 — Drift schema (Phase 3a)

- `lib/data/database.dart` — `AppDatabase extends GeneratedDatabase`, `schemaVersion = 1`
- `lib/data/tables/media_items.dart` — `EnumNameConverter<MediaType>` and `EnumNameConverter<MediaStatus>` wired at the column level (see §4.4)
- `lib/data/tables/movie_details.dart` — joined by `media_item_id`; unique partial index on `tmdb_id`
- `MigrationStrategy.onCreate` builds both tables + indexes
- `MigrationStrategy.onUpgrade` includes additive migration steps (placeholder for v2 — no steps needed in v1)
- `lib/data/daos/movie_dao.dart` — typed queries, including `findByTmdbId(int)` for idempotency (§7.7)
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

- Search Page 5-state flow (State A → B → C → D → E; see §7.0–§7.6)
- AddSheet as **State C inline** (not a separate `ModalBottomSheet`; see §7.3 + §6.9)
- EditSheet as `ModalBottomSheet` triggered from `MovieCard.onTap` on Collection / Bucketlist pages (D-L6, §6.9)
- ConfirmSelection as State E with Collection / Bucketlist toggle + per-item remove (Q2 E2)
- 'X' close button + exit-confirm dialog at States C and E (§7.6)
- URL: `/search?q=<query>&type=movie` (Q10)
- 6 files under `lib/features/search/` (Q8; §7.9)
- Media Filter button (Q4) opens Genre-only modal sheet on Collection / Bucketlist pages
- Hamburger Menu stubs (Profile / Settings / Help / About; Q5)
- MediaTypePage lists 6 types (Movies, TV Shows, Anime, Video Games, Books, Comics) with Movies-only-tappable (Q6)
- ManualEntryForm at State B' when TMDB unavailable: Title + Year + Genre + Rating + Status, status defaults to Bucketlist (Q7, §7.8)
- Delete confirmation
- 3-4 widget tests

### U7 — *(removed — TV Shows deferred to v2; see §18 v2a)*

### U8 — Polish

- Material 3 theme finalized
- **Single seed color** locked; **both light and dark palettes shipped in v1**, derived from the same seed via `ColorScheme.fromSeed(seedColor: …, brightness: Brightness.{light,dark})` (D-L2). `themeMode: ThemeMode.system` (Q10 wiring).
- Typography ramp: Source Serif 4 (display/headline) + Inter (title/body/label) via `google_fonts`
- Material Symbols Rounded font bundled as asset; `IconData(fontFamily: 'MaterialSymbolsRounded', fontPackage: 'media_tracker')` used everywhere
- Spacing scale locked (8px baseline, 12px card padding, 16px gaps, 12dp card radius)
- Both palettes verified (light + dark; OS-handler toggles between them)
- Empty-state widgets
- Accessibility pass (semantics labels, focus order)

### U9 — Wrap-up

- `PROJECT_PLAN.md` documents v2 features + Supabase plan + migration plan
- One retrospective on locked decisions vs. original hunches

---

## 15. Test Plan

Per the test-mirror rule, tests live next to the code they
cover. Test mirror applies to `PROJECT_PLAN.md` §14 Done Definitions.

| Phase | Layer | Test scope | ~Lines |
|---|---|---|---|
| 1 | Widget | CataloguePage renders two HubCards; tap Each navigates | ~20 |
| 3a | Drift repository | insert, query, delete, migration v1→v2, `findByTmdbId` returns existing row | ~50 |
| 4 | Riverpod providers | `moviesListProvider` reflects insert; `searchProvider` resolves | ~30 |
| 5 | Widget UI | HubCards render; Search Page 5-state flow; Media Filter; EditSheet prefill; Delete confirm | ~80 |
| 6 | Integration (optional) | "open app → add movie → see on hub" end-to-end | TBD |

Total v1 test budget: **~180 lines** (slightly above the §12 target;
reflects the wider surface added by the wireframes — Collection Page
Statistics, Media Filter, Search Page 5 states, EditSheet, manual-entry
form). Drift tests run on host against `NativeDatabase.memory()`
(no emulator needed). Riverpod provider tests use
`ProviderContainer.test` (Riverpod 3). Widget tests use
`flutter_test`. Integration tests use `integration_test`.

---

## 16. Decisions log

All decisions made in this planning session, locked at the time of writing.

### 16.1 Product & scope

| # | Decision | Choice |
|---|---|---|
| D1 | Product positioning | Unified tracker + local-first growth + social-as-core (community features are the long-term value, deferred to v2) |
| D2 | v1 sharing | Deferred to v2 — v1 is personal-tracking only |
| D3 | v1 bottom nav | nav bar ships with v1 with home & catalogue buttons |
| D4 | Add-movie flow scope | TMDB search + results grid + AddSheet + SimilarResults in v1; saved search sessions deferred to v2. |

### 16.2 Data

| # | Decision | Choice |
|---|---|---|
| D5 | Data model | Hybrid — `media_items` (base) + `*_details` (per type). Movie is the only v1 type. |
| D6 | `media_items.type` storage | Plain `TEXT` — no CHECK or ENUM. Schema-change-free when widening type set. |
| D7 | Status enum | **2 states** in v1: `MediaStatus.onBucketlist`, `MediaStatus.inCollection`. `MediaStatus.onCollabLists` deferred to v2. The other three states (`currentlyConsuming`, `dropped`, `upcoming`) are added in v2 with the detail/edit sheet that surfaces them — see §5.2. Canonical UI label for `onBucketlist`: **"Bucketlist"** (D-L13; see D33). |
| D8 | Hub mapping | Strict 2-card (Collection = `inCollection`, Bucketlist = `onBucketlist`). UI labels per wireframes in `images/`. |

### 16.3 Tech stack

| # | Decision | Choice |
|---|---|---|
| D9 | TMDB client | `Dio` for v1, behind `MediaSearchClient` interface (`search({query, mediaType}) → List<MediaSearchResult>`). Swap to a regenerated client (e.g., `openapi_generator`) in v2 when v2 widens the type set to 6 (Movies + TV Shows + Anime + Video Games + Books + Comics) per the wireframe — touches the impl only. |
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
| D17 | Icons | **Material Symbols Rounded font, bundled as asset**. Use `IconData(fontFamily: 'MaterialSymbolsRounded', fontPackage: 'media_tracker')`. Reason: no official Flutter-team package wraps Material Symbols; bundling the **Apache License 2.0** font respects rule #7. |
| D18 | Fonts | **`google_fonts`** for Source Serif 4 (display/headline) + Inter (title/body/label). Reason: verified publisher `flutter.dev` — satisfies rule #7. |
| D19 | Seed color | **One** seed for both brightness modes. `ColorScheme.fromSeed(seedColor: …, brightness: Brightness.light/dark)` derives both palettes. Two seeds = visual whiplash on theme toggle. |
| D20 | Status enum v1 | **2 states only** (`MediaStatus.onBucketlist`, `MediaStatus.inCollection`). The other 3 states (`currentlyConsuming`, `dropped`, `upcoming`) are added in v2 with the detail/edit sheet that surfaces them. Reason: storing values the UI cannot surface creates invisible QA debt; the trivial Drift migration cost is not worth paying in v1. Canonical UI label for `onBucketlist` is "Bucketlist" (D-L13; see D33). |
| D21 | Add-movie idempotency | Repository runs `findByTmdbId` before `INSERT`; throws `AlreadyInCollection` on hit. `SearchRepository` translates it into a user-facing snackbar ("Already in your Collection" / "Already on your Bucketlist"). The unique index on `movie_details.tmdb_id` is the last-line defense. Per §7.7. |
| D23 | Games provider | **RAWG** (not IGDB). Reason: verified against [Twitch Developer Forum](https://discuss.dev.twitch.com/t/igdb-authentication-and-tokens-need-server-app/28394) that IGDB rate-limits at 4 req/s **per Client ID, not per user** — per-user Twitch OAuth does not give per-user rate-limit pools. RAWG's 20k req/month is predictable, requires no OAuth, and needs no proxy backend. |
| D24 | Games attribution (v2) | Every page displaying RAWG data or images must include an active hyperlink back to RAWG (per [RAWG API ToS](https://rawg.io/apidocs)). Implementation: per-card "View on RAWG" link on `MovieCard`-equivalent for Games; or page-level footer. Locked when Games ships in v2. |
| D25 | `source` + `imported_at` columns in v1 | `media_items.source TEXT NOT NULL DEFAULT 'manual'`; `media_items.imported_at DATETIME NULL`. Forward-compatible with v2 import — no v2 schema migration needed. NULL `imported_at` means manual; non-NULL means imported at that time. Columns ship in v1's initial schema (§4.1); no v1 migration is required. |
| D26 | Backend mega-database lives on Supabase | `media_universe` table on Supabase Postgres, populated by ETL pipeline from each provider in §4.3. App queries via PostgREST/Realtime; falls back to provider APIs on miss. Strict separation from local `media_items` (§4.5). Join key: per-type external id columns. D12 is expanded: Supabase hosts both auth and the mega-DB. |
| D27 | `resolveTitle` signature deferred to v2 | `MediaSearchClient` (§U4) is the integration point; actual `resolveTitle(String) → ...` signature is locked at v2 planning when the import pipeline shape is concrete. v1 interface is forward-compatible. |
| D28 | `MediaType` enum v1 | Only `MediaType.movie` is valid in v1. `EnumNameConverter<MediaType>` wired at column level (see §4.4). Extension to `tv_show`, `anime`, etc. in v2 via the converter; no schema change required for `media_items.type` since it is plain TEXT. |
| D29 | Routing library | `go_router` (verified publisher `flutter.dev`). Last release: 49 days ago, v17.3.0. Reason: Flutter Favorite; feature-complete; declarative routing. v1 ships 11 go_router routes per §6.5 (Landing, Home, Catalogue, Collection, Bucketlist, Search, Profile, Media Type, Settings, Help, About). v2 widens to nested child routes and per-type deep links. License: BSD-3-Clause. |
| D30 | `drift` | `simonbinder.eu` (verified). Last release: 2 days ago, v2.34.3. Reactive SQLite ORM for Flutter/Dart; v1 data layer (`media_items` + `movie_details` tables). Flutter Favorite; MIT; transitively pulls `sqlite3` 3.x. Phase 3a. |
| D31 | `drift_dev` | `simonbinder.eu` (verified). Last release: 7 days ago, v2.34.5. Dev-dependency for `drift`; codegen via `build_runner`. MIT. Companion to D30; not in runtime deps. Phase 3a. |
| D32 | `build_runner` | `tools.dart.dev` (verified; official Dart team). Last release: 2 days ago, v2.15.3. Build system for Dart code generation; runs `drift_dev` codegen. BSD-3-Clause. Outputs `.g.dart` files into `lib/`. Phase 3a. |
| D33 | Status enum & UI label canonicalization | **Renames**: `MediaStatus.onWatchlist` → `MediaStatus.onBucketlist`; UI label `'Bucket List'` → `'Bucketlist'`; file `bucket_list_page.dart` → `bucketlist_page.dart`. Source of truth: the wireframes in `images/`. Affected files: `lib/features/catalogue/data/movie_status.dart` (the enum file), `lib/features/catalogue/catalogue_page.dart` (the AppBar label), `lib/features/catalogue/bucket_list_page.dart` → `bucketlist_page.dart`. Renames cascade into the tutor doc set (`new_agent_docs_tutor/01-project-overview.md`, `02-architecture.md`, `03-code-standards.md`, `05-phases.md`, `06-concepts-and-links.md`, `07-progress-tracker.md`) — deferred per the user's direction. |

---

## 17. Glossary

The technical terms used throughout this plan. Cross-reference:
`current_agent_docs_tutor/06-CONCEPTS-AND-GLOSSARY.md` for the deeper
Flutter / Drift / Riverpod glossary; this section is the project-level
vocabulary.

| Term | Meaning |
|---|---|
| `media_item` | The central entity tracked by the app. In v1, always a Movie. Stored in `media_items` (Drift table). User-facing label "movie" in v1. |
| `status` | The 2-state enum: `MediaStatus.onBucketlist` / `MediaStatus.inCollection`. UI labels: "Bucketlist" / "Collection". |
| `hub` | The Catalogue Page (the wireframe's central screen, with 2 HubCards). Distinct from "list" — the hub never shows individual items, only HubCards pointing at filtered lists. |
| `HubCard` | One of the two large cards on the Catalogue Page: Collection or Bucketlist. |
| `Search Page` | Full-page route at `/search?q=<query>&type=movie`. State machine A → B → C → D → E. 'X' closes; exit-confirm at C and E. |
| `AddSheet` | **State C** of the Search Page; rendered inline, not as a `ModalBottomSheet`. Status toggle (Collection / Bucketlist) + 0–10 rating. |
| `EditSheet` | `ModalBottomSheet` triggered from `MovieCard.onTap`. Same fields as AddSheet, prefilled with the existing data. Has Delete action. |
| `ConfirmSelection` | **State E** of the Search Page; toggle Collection/Bucketlist at top, per-item remove, "Add to \<Destination\>" button at bottom. |
| `ManualEntryForm` | Replaces Search Page State B when TMDB unreachable. Title (required) + Year + Genre + Rating + Status (defaults to Bucketlist). |
| `TMDB` | The Movie Database. Read-only external metadata provider in v1. |
| `drift` | SQLite ORM used for persistence. Generates typesafe Dart from table definitions. |
| `Riverpod 3` | State-management library. `ProviderScope`, `Notifier`, `AsyncNotifier`. |
| `go_router` | Declarative routing library. v1 ships 11 routes per §6.5. |
| `AppShell` | The persistent scaffolding (theme + chrome) wrapping every page. The `AppScaffold` widget in `lib/shared/`. |
| `MediaType` enum | v1 = `MediaType.movie` only. `EnumNameConverter<MediaType>` at column level. v2 widens to `tv_show`, `anime`, etc. |

---

## 18. v2 and v3 Phases

v1 ships Movies only (I1). v2 widens the type set to TV Shows,
Anime, Video Games, Books, and Comics (per the wireframe's
Landing Page in `images/`); adds a Supabase backend, sharing,
community circles, and import pipelines. v3 adds cross-platform
targets (iOS, Web, Desktop) and customizable theming.

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
