# 02 — Architecture

## TL;DR

Media Tracker is a layered Flutter app:

```
main → app → core/http → data → providers → features → shared
```

Each layer has one job and one direction of dependency. UI talks
to data through Riverpod providers; data talks to disk through
Drift; HTTP talks to TMDB through a single interface
(`MediaSearchClient`). **No layer imports the layer above it.**
The 14 invariants below codify the rules that keep this layered.

This file is the agent's reference for system structure, schema,
migrations, theme wiring, and invariants. It absorbs the content
the agent needs from the project's source-of-truth plan: system
scope, tech stack, data model, status enum, App Shell
(architectural view), migrations, and the 14 invariants. The
9 codebase rules also live in `03-code-standards.md`. The agent's
read set is self-contained.

## The layers, in plain English

### `lib/main.dart` (entry point)

Owns: `runApp`, `ProviderScope`, app boot.
Does not own: business logic, persistence, HTTP.

One job: hand control to `app/`. About 10 lines.

### `lib/app/`

Owns: theme, router, app-level config.
Does not own: per-feature logic, HTTP calls, data access.

What lives here: `theme.dart` (the Material 3 `ThemeData`),
`router.dart` (Phase 2+, `go_router`), `secrets.dart`
(gitignored; loads the TMDB API key at boot).

### `lib/core/`

Owns: cross-cutting utilities.
Does not own: persistence, UI.

Cross-cutting means "used by more than one layer, but isn't
a layer itself." Example: `core/http/` is the only HTTP
interface; nothing else in the app imports `dio` directly.

### `lib/core/http/`

Owns: `MediaSearchClient` interface + Dio implementation + TMDB DTOs.
Does not own: drift types, Riverpod, widgets.

The single funnel for all TMDB calls. If you find yourself
wanting to import `dio` from `features/`, that's invariant I-5
territory — push it through `MediaSearchClient` instead.

### `lib/data/`

Owns: drift `AppDatabase`, tables, DAOs, repositories, error types.
Does not own: UI, HTTP, Riverpod (repositories return plain
values; providers lift them).

Repositories are domain-facing methods like
`MovieRepository.add(...)`. They throw typed exceptions, not
`Result<Error>` types.

### `lib/data/repositories/`

Owns: domain methods, idempotency checks.
Does not own: UI states, side-effects beyond the DB write.

Example: `MovieRepository.add` checks `findByTmdbId` first;
if the row exists, it throws `AlreadyInCollection`. The
provider catches this and surfaces it as a snackbar. The
repository doesn't know what a snackbar is.

### `lib/features/`

Owns: per-feature UI (catalogue, search, future explore /
community).
Does not own: persistence, HTTP, drift types.

`features/` reads only through Riverpod providers. Never
imports `drift` or `dio`. This is invariant I-5 (no dio) + I-6
(no drift).

### `lib/providers/`

Owns: top-level Riverpod providers that bridge data and UI.
Does not own: widgets, drift DAOs, raw HTTP.

The glue layer. If a widget needs data, it asks a provider;
if a provider needs data, it asks a repository; if a
repository needs data, it asks a DAO or an HTTP client.

### `lib/shared/`

Owns: reusable widgets, helpers, extensions.
Does not own: anything feature-specific.

A `MovieCard` widget lives in `features/catalogue/`, not
`shared/`, because it's specific to that feature. A `Chip`
widget with our spacing tokens might live in `shared/` because
it's reused.

### `test/`

Mirrors `lib/` 1:1:

```
test/data/             mirrors lib/data/
test/providers/        mirrors lib/providers/
test/features/<feat>/ mirrors lib/features/<feat>/
test/integration/      end-to-end (Phase 6, optional)
```

Drift tests run on the host against
`NativeDatabase.memory()` — no emulator needed. Riverpod
provider tests use `ProviderContainer.test` (Riverpod 3).
Widget tests use `flutter_test` and pump widgets inside a
`ProviderScope`.

## Layer matrix (Layer | Folder | Technology | Role)

| Layer | Folder(s) | Technology | Role |
|---|---|---|---|
| Entry | `lib/main.dart` | Dart | `runApp`, `ProviderScope`, app boot (≤ 10 lines) |
| App | `lib/app/` | `MaterialApp.router` + `go_router` | Theme wiring (`theme.dart`), routing (`router.dart`), `secrets.dart` loading |
| Core HTTP | `lib/core/http/` | `Dio` + 3rd-party interceptors | `MediaSearchClient` abstract + `DioMediaSearchClient` impl + TMDB DTOs |
| Core utilities | `lib/core/` | Dart | `ids.dart` (uuid wrappers); future cross-cutting modules |
| Data | `lib/data/` | `drift` + `sqlite3_flutter_libs` + `path_provider` | `AppDatabase`, tables, DAOs, repositories, error types. Background isolate for SQL. |
| Repositories | `lib/data/repositories/` | Dart | Domain methods (`MovieRepository.add(...)`); throw typed exceptions; idempotency on add via `findByTmdbId` |
| Providers | `lib/providers/` | `flutter_riverpod` 3.x | Glue: `databaseProvider`, `moviesListProvider`, `searchProvider`, `filterProvider` |
| Features UI | `lib/features/` | Flutter Material 3 widgets | `catalogue/`, `search/` (5-state Search Page), `AppScaffold` consumer sites. No `drift` or `dio` imports (I-5, I-6). |
| Shared | `lib/shared/` | Flutter | `app_scaffold.dart` (every page wrapper), reusable widgets, helpers |
| Tests | `test/` mirroring `lib/` | `flutter_test`, `ProviderContainer.test`, `integration_test` | Drift in-memory, provider tests, widget tests, optional integration |

Path resolution: `lib/` is the runtime tree, `test/` is the
test tree. The published APK contains only `lib/`. TS/JS-style
compilation outputs (`*.js`, `*.d.ts`) are not applicable;
Flutter compiles Dart to native code (AOT) on iOS/Android and
to JS (web) on web targets.

## Boundary rules (and the invariants that enforce them)

| Rule | Enforced by |
|---|---|
| `data/` knows nothing about UI. | Code review (you + tutor). |
| `features/` knows nothing about HTTP — UI talks only to repositories via providers. | Invariant I-5 (no `dio` import in `lib/features/`). |
| `features/` knows nothing about drift — UI reads via providers. | Invariant I-6 (no `drift` import in `lib/features/`). |
| `core/http/` knows nothing about drift or features. | Code review. |
| `providers/` is the glue; nothing else crosses layers. | Code review. |

## Scope

### In scope (v1)

- Movies catalogue only
- Android-only build
- Single device, single user; no account, no cloud sync
- Local-first persistence with offline search and add-movie
  fallback
- TMDB read-only search via API key in `lib/secrets.dart`
  (gitignored)
- 2-state status enum (`MediaStatus.onBucketlist`,
  `MediaStatus.inCollection`)
- Material 3 with both light and dark themes shipped in v1;
  `themeMode: ThemeMode.system` decides
- Multi-page app (Landing, Home, Catalogue hub, list pages,
  Search Page; 2-tab bottom nav)

### Out of scope (v1)

- All non-Movies media types (TV Shows, Anime, Video Games,
  Books, Comics come in v2 per the wireframe)
- Auth, multi-user accounts, cloud sync, backend
- Sharing, community circles, recommendations, swipe-based
  matching
- PDF or web-link export
- Similar-media discovery (handled in Search Page State D only)
- Bottom-nav Community and Explore tabs (added in v2)
- iOS, web, desktop targets
- Custom user themes (Vivaldi-style)
- Push notifications
- Localization beyond English
- Theme switch toggle inside the app (system-handler only)

### Out of scope (v2)

- All other media types, iterated type-by-type
- Supabase auth (email + social providers)
- Cloud sync of local catalogue to Supabase Postgres
- Sharing via PDF / web link
- Community circles (family, friends, internet friends,
  coworkers; per-media-type circles: gamer, reader, manga,
  etc.)
- Cross-user `Recommendation` entity with stored / unstored
  status
- Swipe-based mutual watchlist matching ("Tinder for media")
- Random genre / language / era explore
- Same-genre recommendation algorithm
- Custom UI theming (Vivaldi-style)
- `onCollabLists` 6th media status state
- Import from external platforms (Letterboxd CSV,
  iMDB `ratings.csv`, primitive plain-text lists, MAL via
  JIKAN / Trakt / Backloggd / Steam / Spotify / Goodreads)
- Backend mega-database for search and discovery (v2) —
  hosted on Supabase Postgres as `media_universe`, populated by
  an ETL pipeline from each provider; app queries
  `media_universe` via PostgREST/Realtime and falls back to
  provider APIs on cache miss

## Tech stack

| Concern | Choice | Why |
|---|---|---|
| Framework | Flutter 3.44.5 / Dart 3.12.2 | Verified working with emulator in Phase 0; cross-platform for mobile/PC/web later |
| Local DB | `drift` + `sqlite3_flutter_libs` + `path_provider` | Drift is the typed, codegen'd SQLite layer for Flutter; `path_provider` gives the docs dir for the SQLite file |
| Codegen | `drift_dev` + `build_runner` | Drift's data classes + queries are generated |
| State | `flutter_riverpod` 3.x | Reactive, type-safe; `ProviderContainer.test` in Riverpod 3 makes provider tests cheap |
| Navigation | `go_router` | Declarative, ready for v2 deep linking / web |
| HTTP | `dio` | Behind a `MediaSearchClient` interface so v2 can swap to a regenerated client without touching call sites |
| Image cache | `flutter_cache_manager` (direct, **not** `cached_network_image`) | Disk-cached posters; `cached_network_image` last released 23 months ago and is rule #7 suspect — we use `flutter_cache_manager` directly with `Image.network` |
| Fonts | `google_fonts` (verified publisher `flutter.dev`) | Source Serif 4 (display/headline) + Inter (title/body/label); official publisher satisfies I-7 |
| Icons | Material Symbols Rounded font, bundled as asset | No official Flutter wrapper exists for Material Symbols as of plan-date; bundling the **Apache License 2.0** font at `assets/fonts/MaterialSymbolsRounded.ttf` respects I-7 (D17) |
| Misc | `intl`, `uuid` | Date formatting in v2; stable IDs across `media_items` and per-type detail tables |
| Test target | Android emulator `emulator-5554`, API 36 | Phase 0 |
| v2 backend | Supabase (Auth + Postgres + RLS + Realtime + Storage) | Postgres matches the roadmap PNG's "Postgres" reference; RLS is purpose-built for community permissions |

### Why each choice (one line)

- **Flutter:** cross-platform, native UI, single codebase for mobile / PC / web later
- **Drift:** more type-safe than `sqflite`; codegen eliminates SQL string bugs
- **Riverpod:** better testing story than `Provider`; better dev-time safety than `setState`
- **go_router:** declarative routing; ready for v2 web target; deep linking built-in
- **Dio:** standard Flutter HTTP choice; interceptor system fits v2's future auth-header needs
- **`flutter_cache_manager`:** disk-cached image loading without `cached_network_image` (I-7; see D16)
- **`google_fonts`:** verified publisher `flutter.dev` (I-7) — no third-party risk
- **Material Symbols Rounded asset:** the only I-7-compliant path to the Material Symbols icon set
- **Supabase:** open-source; Postgres-portable; built-in RLS for community feature permissions

### Flutter 3.44 Material migration watch

Material and Cupertino code is **frozen** in Flutter 3.44.5 but
still importable via `package:flutter/material.dart`. The old
code will be deprecated in the stable release after 3.44 and
deleted some time after that. When the project upgrades past
3.44.x, migrate to the new `material_ui` and `cupertino_ui`
first-party packages in a single dedicated commit. Tracking:
[flutter/flutter#184093](https://github.com/flutter/flutter/issues/184093).

For v1 we ship against 3.44.5 with the existing
`package:flutter/material.dart` imports — no action required
until the next Flutter major bump.

`MaterialApp(routerConfig: ...)` shortcut does not compile on
Flutter 3.44.x. The main `MaterialApp(...)` constructor does not
accept `routerConfig:` as a parameter (only initializes it to
null). The dedicated `MaterialApp.router(routerConfig: ...)`
constructor is the only entry point that wires a `GoRouter`
(lesson from Phase 2). §App Shell below reflects this.

## Data model

### Schema

```text
media_items                          movie_details
─────────────                        ─────────────
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

`source` values: `'manual'` (default for v1 writes), then v2
extends with `'letterboxd'`, `'imdb'`, `'notes'`, `'mal'`, etc.
Stored as plain TEXT; vocabulary enforced at the app boundary.

`imported_at` is nullable: `NULL` = manually added; non-NULL =
imported at that time. Filtering and rollback logic use
`WHERE imported_at IS NULL` / `IS NOT NULL`. The columns ship
in v1's initial schema; no migration is required.

`type` is stored as plain `TEXT` — no CHECK constraint, no SQL
ENUM. Widening the type set (`'movie'` → adding `'tv_show'`,
`'anime'`, etc.) is a **zero schema change** in SQLite; only
application code changes (I-3).

`status` is also plain `TEXT` for the same reason (I-2).

### Hybrid model rationale

A future iteration adds TV, Anime, Books, Games, etc. Each
type has type metadata that doesn't fit cleanly on a shared
row. The hybrid model:

- `media_items` holds **shared fields** (id, title, year, type,
  status, rating, timestamps). Querying "all my media" hits
  this table directly.
- `*_details` tables (one per type) hold **type-specific
  fields**. `movie_details` is the only one in v1.

Adding a new type later = new `*_details` table + a new value
for the `type` column (no schema change). Queries cross types
via `media_items`; type-specific queries join to the detail
table.

### Provider-per-type mapping (locked at v1 planning)

One provider per media type. Re-evaluated only when a new media
type is added. No multi-provider reconciliation per type (e.g.,
a book that's in both Google Books and OpenLibrary uses only
the canonical provider below).

| Type | Provider | Detail table | External id column | Auth model | Notes |
|---|---|---|---|---|---|
| Movie | TMDB | `movie_details` | `tmdb_id` (INT, nullable, unique) | API key in `lib/secrets.dart` | TMDB v3 `/movie/{id}` and `/search/movie` |
| TV Shows | TMDB | `tv_show_details` | `tmdb_id` (INT, nullable, unique) | Same TMDB API key | TMDB v3 `/tv/{id}` and `/search/tv`; movie and TV IDs are in separate id-spaces |
| Books | Open Library *(TBD v2)* | `book_details` | `olid` (TEXT, nullable, unique) | None — read endpoints are unauthenticated | Canonical id is OLID (`OL…W` for works, `OL…M` for editions) |
| Video Games | **RAWG** | `game_details` | `rawg_id` (INT, nullable, unique) | API key in `lib/secrets.dart` | [rawg.io/apidocs](https://rawg.io/apidocs); **attribution hyperlink required** on every page using RAWG data or images |
| Anime | AniList *(TBD v2)* | `anime_details` | `anilist_id` (INT, nullable, unique) | None — GraphQL is keyless | [docs.anilist.co](https://docs.anilist.co); supports `idMal` cross-reference to MAL |
| Comics | Comic Vine *(TBD v2)* | `comic_details` | `comic_vine_id` (INT, nullable, unique) | API key (historical signup flakiness) | Fallback if key unobtainable: defer Comics to v3 |

**Why RAWG over IGDB for Games (locked):** IGDB rate-limits at
**4 requests per second per Client ID**, not per user —
verified against [Twitch Developer Forum](https://discuss.dev.twitch.com/t/igdb-authentication-and-tokens-need-server-app/28394).
Per-user Twitch OAuth does not give per-user rate-limit pools.
RAWG's 20,000 requests/month quota is predictable and adequate
for v2 scale; no OAuth dance, no proxy backend needed.

### Type-safe enum mapping (I-2 / I-3)

Both `media_items.type` and `media_items.status` are stored as
plain TEXT (see Schema above) but are wrapped at the column
level with Drift's built-in `EnumNameConverter`. Zero schema
change; eliminates typos at the write boundary; gives Postgres
a CHECK-equivalent when migrating to Supabase in v2.

```dart
TextColumn get type  => text().map(const EnumNameConverter<MediaType>())();
TextColumn get status => text().map(const EnumNameConverter<MediaStatus>())();
```

Every write path goes through these enums — see invariant I-3
in §14 invariants below.

### Local vs backend tables

v1's `media_items` table is the user's library — local, on-device.
v2 introduces a separate `media_universe` table on Supabase
Postgres (the system's knowledge of every known media item).
The two are **strictly separated by location** — they must
never be merged, even conceptually:

- Local `media_items` holds what the user has chosen to track;
  row count is dozens to thousands.
- Backend `media_universe` holds what the system knows exists;
  row count is millions.
- The per-type external id columns (`tmdb_id`, `rawg_id`, etc.,
  see Provider-per-type mapping above) are the join key —
  `media_universe.tmdb_id = movie_details.tmdb_id` for rows the
  user has added.
- v1 ships the join-key columns already; v2 builds the backend
  table and the join logic.

This separation is intentional. Conflating "library" with
"universe" corrupts the user's catalogue with items they never
chose to track.

## Status enum (D7, D20, I-2)

Two states in v1, locked:

| Enum value | Meaning | Hub card label |
|---|---|---|
| `MediaStatus.onBucketlist` | Want to consume | **Bucketlist** |
| `MediaStatus.inCollection` | Consumed | **Collection** |

Canonical enum value & UI label: `onBucketlist` /
**"Bucketlist"** (D-L13). Source of truth: the wireframes in
`images/`. Earlier draft referred to the second state as "To
Consume" — that label is retired (D33 in `03-code-standards.md`).

`MediaStatus.onCollabLists` is deferred to v2.

### Hub mapping (strict, v1)

- **Collection** HubCard → filters `media_items` where
  `status = 'inCollection'`
- **Bucketlist** HubCard → filters `media_items` where
  `status = 'onBucketlist'`

### v2 status states (deferred)

Three additional states — `currentlyConsuming`, `dropped`,
`upcoming` — are added in v2 when the detail/edit sheet and
the import flow have a real use for them.

Adding a TEXT column with a default is a trivial Drift
migration — no migration debt is being avoided by shipping
them schema-only in v1, and storing values the UI can't surface
creates invisible QA debt.

## App Shell (architectural view; UI details in `04-ui-context.md`)

### `MaterialApp.router` configuration

```dart
MaterialApp.router(
  title: 'Media Tracker',
  theme: buildAppTheme(brightness: Brightness.light),  // see §6.3
  darkTheme: buildAppTheme(brightness: Brightness.dark),
  themeMode: ThemeMode.system,                          // D-L2
  routerConfig: buildAppRouter(),                       // see §routes
);
```

`MaterialApp.router(...)` is the canonical constructor on
Flutter 3.44.x; the `MaterialApp(routerConfig: ...)` shortcut
does **not** compile (lesson from Phase 2).

### `go_router` route table

| Path | Page | Notes |
|---|---|---|
| `/` | `LandingPage` | Initial route; tile grid (Movies-only in v1). |
| `/home` | `HomePage` | Bottom-nav tab 1; Watchlist carousel. |
| `/catalogue` | `CataloguePage` | Bottom-nav tab 2; hub (Collection + Bucketlist HubCards). |
| `/catalogue/collection` | `CollectionPage` | Child route; full Search + Filter + grid. |
| `/catalogue/bucketlist` | `BucketlistPage` | Child route; mirror of Collection. |
| `/search` | `SearchPage` | Full-page route with 5 states A–E (see §7 in `05-phases.md`). 'X' pops; exit-confirm at C and E. |
| `/profile` | `ProfilePage` | Hamburger target. Stub. |
| `/media-type` | `MediaTypePage` | Hamburger target. v1 = Movies-only. |
| `/settings` | `SettingsPage` | Hamburger target. Stub. |
| `/help` | `HelpPage` | Hamburger target. Stub. |
| `/about` | `AboutPage` | Hamburger target. Stub. |

`buildAppRouter()` returns a `GoRouter` with
`initialLocation: '/'`. Bottom-nav active-tab state reads
`GoRouterState.of(context).uri`:

| Active tab | Condition |
|---|---|
| Home | `path == '/home'` |
| Catalogue | `path.startsWith('/catalogue')` |
| (none) | `/search`, `/profile`, `/media-type`, `/settings`, `/help`, `/about` |

### Floating Action Button

The FAB renders on **Home, Collection, Bucketlist** pages
only. It does **not** render on the Catalogue hub, Search
Page, Hamburger Menu pages, or stubs.

- Icon: `MaterialSymbolsRounded.add` (24dp default per `icon/md`)
- `onPressed`: `context.push('/search')`
- Position:
  `floatingActionButtonLocation: FloatingActionButtonLocation.endFloat`

### Page chrome — `AppScaffold`

A single widget in `lib/shared/app_scaffold.dart` wraps every
page:

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

It produces: `Scaffold` + `AppBar(title, hamburger)` + body +
(optional) `FloatingActionButton(add → context.push('/search'))`
+ 2-tab `BottomNavigationBar` (or none, on routes without a
tab). The page declares only its body's content; the AppShell
supplies everything else.

Visual chrome the page **must not** duplicate: `AppBar`,
`Drawer`, `BottomNavigationBar`, `FloatingActionButton`.
Duplicates are code-review violations (I-5 / I-6 / I-7).

## Migrations

Additive migrations per phase via
`MigrationStrategy.onUpgrade(from, to)`.

Drift's `stepByStep` codegen helper is the preferred path for
writing migrations: it produces per-step migration files
(`database.steps.dart`) based on schema diffs, so each
`fromNToN+1: (m, schema) async { ... }` callback sees the
correct schema snapshot and can't accidentally reference an
un-added column. Generated by `dart run drift_dev make-migrations`.
Use it for every migration unless the schema diff is trivial.
(Manual `if (from < N)` blocks remain a fallback for one-line
hot-fixes.)

### Adding a new media type (stepByStep worked example)

When v2 adds TV Shows, Anime, etc.:

1. Create the new detail table, e.g.
   `lib/data/tables/tv_show_details.dart`, joined by
   `media_item_id` to `media_items`.
2. Register it in `AppDatabase`'s
   `@DriftDatabase(tables: [...])` list.
3. Bump `schemaVersion` (e.g. 1 → 2 for TV Shows, 2 → 3 for
   Anime).
4. Run `dart run drift_dev make-migrations`. The generator
   writes `database.steps.dart` with the per-step closures;
   reference that file from your migration:

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
   // code does not accidentally refer to the current database
   // schema. Each step brings the database into the correct
   // snapshot.
   extension Migrations on GeneratedDatabase {
     OnUpgrade get _schemaUpgrade => stepByStep(
       from1To2: (m, schema) async {
         await m.createTable(schema.tvShowDetails);
       },
     );
   }
   ```
5. Write a `SchemaVerifier`-based test that opens the v1
   schema, inserts a Movie, then opens the v2 schema and
   asserts the Movie is still present and the new table
   exists.

`media_items.type` and `.status` are plain TEXT, so widening
the type set is **zero schema change** in SQLite — only the
new detail table requires migration steps.

### Migration test pattern (drift in-memory)

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

## The 14 invariants

These are the rules the agent enforces during code review and
quizzing. Each maps to a `D-card` in `03-code-standards.md`,
which also absorbs the 9 codebase rules. The agent's read set
is self-contained.

### I-1 — No silent data loss (D13)

Drift migrations must preserve existing user data. Each
migration step has a test.

### I-2 — `media_items.status` has exactly two values (D7, D20)

`MediaStatus.onBucketlist` and `MediaStatus.inCollection` only.
Free-form strings never reach the column (enforced by
`EnumNameConverter<MediaStatus>` at the column level — I-3).

### I-3 — `media_items.type` is `MediaType.movie` only (D28)

In v1, every row in `media_items` has `type = 'movie'` (enforced
by `EnumNameConverter<MediaType>`).

### I-4 — Type-safe enums only at the boundary

`media_items.type` and `.status` are plain TEXT in storage,
but every write path must go through the value-object enums
in `lib/data/`. Drift's `EnumNameConverter` is wired at the
column level (I-2, I-3). No free-form strings reach SQLite.

### I-5 — No `dio` import under `lib/features/`

All TMDB calls go through `MediaSearchClient`. `lib/features/`
may not import `package:dio/...`. The v2 swap to a Supabase-backed
client touches the impl only.

### I-6 — No `drift` import under `lib/features/`

UI reads through Riverpod providers. `lib/features/` may not
import `package:drift/...`. The data layer is replaceable.

### I-7 — No `setState` for shared state in `lib/features/`

Local widget state is allowed (e.g., a checkbox inside a modal
sheet). Anything that drives another widget elsewhere goes
through Riverpod. (Developer-side companion: codebase rule
"no `setState` for shared state.")

### I-8 — No comments in code (RELAXED in v1) (D16)

The original rule: no `//` outside `lib/main.dart` and `*.g.dart`.
Status in v1: **RELAXED**. Comments are allowed throughout
`lib/**/*.dart`. Re-tightens at v2 start (when CI scripts return).

### I-9 — Dependency versions pinned exactly (D29 — RELAXED in v1)

The original rule: no `^`, no `>=`, no `~` in `dependencies:` in
`pubspec.yaml`. Status in v1: **RELAXED**. `flutter pub add <pkg>`
writes caret ranges; that's fine. Re-pin at v2 cleanup.

### I-10 — Tests live next to the code they cover

`test/data/` mirrors `lib/data/`, `test/features/<feat>/`
mirrors `lib/features/<feat>/`. The directory tree should be
obvious. (Deferred till Phase 3a when the first drift test
lands.)

### I-11 — `MediaSearchClient.search` signature is locked

The signature
`Future<List<MediaSearchResult>> search({required String query, required MediaType mediaType})`
is locked. v2 may add optional parameters; v1 forbids extending
the required set.

### I-12 — Material imports via `package:flutter/material.dart`

Import material from the Flutter first-party package, not from
`package:material_ui/` (a future planned separate package).
The migration to `material_ui` / `cupertino_ui` will happen in
one dedicated commit. Until then, every
`import 'package:flutter/material.dart';` is forward-compatible.

### I-13 — No `user_id` column on `media_items` in v1

Auth, multi-tenant logic, and per-user rows are deferred to v2.
(Single-tenant posture enforced by the schema, not just by code.)

### I-14 — `TMDB_API_KEY` must be set at boot

Loaded from `lib/secrets.dart` (gitignored, dev) or
`--dart-define=...` (env, CI). Missing key fails fast at the
`MediaSearchClient` constructor before any TMDB call runs.
Documented as a deployment prerequisite.

## Storage

| What | Where | Lifetime |
|---|---|---|
| Movies the user has added | SQLite via Drift, `media_items` + `movie_details` tables | until uninstall |
| The SQLite file itself | `<app-docs>/media_tracker.sqlite` via `path_provider` | until uninstall |
| TMDB poster cache | disk via `flutter_cache_manager` | until OS evicts |
| TMDB search responses | in-memory Riverpod provider scope | until provider disposed |
| TMDB API key | `lib/secrets.dart` (gitignored) or env var | process lifetime |
| Drift codegen output | `lib/data/database.g.dart` | regenerated on schema change |
| Material Symbols Rounded font | bundled asset `assets/fonts/MaterialSymbolsRounded.ttf` | shipped with APK |
| Google Fonts (Source Serif 4, Inter) | runtime fetch on first use via `google_fonts` | until network fetch fails; cached thereafter |

**What is NOT in v1:** cloud sync, secure-storage token cache,
encrypted-at-rest SQLite, backup, multi-device.

## Auth and access model

v1 has no auth, no account, no login screen, no logout. The
"user" is whoever owns the device. There is one local SQLite
database; no row is owned by anyone; there is no `user_id`
column (I-13).

v2 introduces Supabase Auth and adds `user_id` with RLS. Until
then, every read and write is unconditional.

## Error and response contract

Errors are typed exceptions thrown from the data or HTTP
layer, caught by the calling Riverpod provider, and surfaced
in the UI as `SnackBar` (transient, e.g., already-in-collection)
or `AlertDialog` (recoverable, e.g., save failed).

| Exception | Origin | Caught at | User sees |
|---|---|---|---|
| `AlreadyInCollection` | `MovieRepository.add` when `findByTmdbId` returns a row | provider-level → `AddSheet` | `"Already in your Collection"` or `"Already on your Bucketlist"` |
| `MediaSearchUnavailable` | `DioMediaSearchClient.search` on network failure / timeout / 5xx | `SearchPage` State B | Search page degrades to manual-entry form (no error shown) |
| drift `InvalidDataException` / `ConstraintViolationException` | drift itself | provider-level `try/catch`; surfaces to `AlertDialog` | generic message; logged at SEVERE |
| `MissingApiKeyException` | `DioMediaSearchClient` constructor if key not set | boot — fails fast before any TMDB call | `assert`-level error in dev; documented as deployment prerequisite (I-14) |

**Contract:** repositories throw, not return `Result<Error>`
types. HTTP errors never surface raw `dio` exception types to UI.

## Concurrency and async model

- Dart single-threaded event loop on the main isolate.
- Drift queries run on a background isolate owned by `drift`;
  UI never blocks.
- Riverpod providers default to main-isolate computation.
- HTTP calls are async; cancellation via `CancelToken` if a
  SearchPage backs out mid-request.
- The codebase never mutates shared state. Riverpod's
  `Notifier.state` setters are the only place writes happen;
  widgets read.

## Background tasks & AI

**v1 has no AI/ML features.** TMDB search is HTTP-only — no
recommender, no embeddings, no LLM calls. The closest v2 gets
to "AI" is the same-genre recommendation algorithm (§Scope —
out of scope for v2).

**Drift runs on a background isolate.** This is the only
background task in v1. `AppDatabase` is constructed with its
own background isolate on Flutter 3.44+; queries run there
and stream results back to the UI. The main isolate never
blocks on SQL. Drift's `Stream<List<Row>>` returns rows via
the isolate's port to the main isolate's event loop.

**HTTP has a `CancelToken` seam.** If a `SearchPage` backs
out mid-request, the `DioMediaSearchClient` cancels the
in-flight `CancelToken`. No "zombie" results corrupt the
user's next search; no stranded network sockets.

**`compute()` for CPU-bound fan-out is reserved for v2.**
Searching through 100k TMDB results client-side is not a v1
use case; `compute()` would be overkill today. v2 may add it
for recommendation algorithms.

**No background fetchers in v1.** Pre-fetching posters ahead
of time is a v2 polish item; in v1, posters load on demand
via `flutter_cache_manager` and stay cached for the OS's
disk-life.

**No scheduled tasks.** v1 has no "remind me about this movie"
feature, no daily-stats cron, no push-notification handlers.
v2 picks these up under the appropriate scoped phases.

## v2 widening (forward-compatibility notes)

- **v2 widens the type set** (D6) — the Shell and routing
  layout stay; only `MediaType` enum widens and a per-type
  filter routes in.
- **v2 widens the bottom nav** to 4 tabs (Home, Catalogue,
  Community, Explore) by setting `BottomNavigationBar.items` to
  length 4 and adding the v2 routes. `AppScaffold` signature
  unchanged.
- **v3 widens to iOS / Web / Desktop** — the Shell is
  platform-aware via Flutter's adaptive widgets; `go_router`
  URL strategy configures per platform.
- **Supabase backend** (D12, D26) — auth gate and per-user
  routes added at `GoRouter.redirect`; the Shell's UI does
  not change.

## Cross-references

- Phase numbering, Done Definitions, per-step 5-sub-block
  templates: `05-phases.md`
- D-cards (locked decisions D1–D33): `08-decisions-log.md`
- Conventions + the 9 codebase rules: `03-code-standards.md`
- Design tokens (color, typography, spacing, components):
  `04-ui-context.md`
- Programming concepts (the agent uses `webfetch` /
  `websearch` for current sources; per-step P1 blocks in
  `05-phases.md` seed canonical URLs)
- Project framing (v1 surfaces, first-session flow, glossary):
  `01-project-overview.md`
- Tutor's role & 5-step flow: `00-tutor-workflow-rules.md`
- Session status: `07-progress-tracker.md`
- Repo-root charter: `/AGENTS.md`
