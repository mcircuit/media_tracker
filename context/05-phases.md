# 05 — Phases

## TL;DR

This file is the **per-step working document** for v1. Each
phase has Done Definitions (per `PROJECT_PLAN.md` §14) and
each sub-step has the **5-sub-block template** the tutor runs
through (P1 explain → P2 quiz → P3 guide → P4 review → P5 quiz).

**v1 only:** when the user reaches v2, this file is **rewritten
from scratch** — v2 phase slots, new D-cards, new surface
decisions land in `PROJECT_PLAN.md` §18 first, and the new
`05-phases.md` aligns. Until then, this is v1-only.

The file mirrors `PROJECT_PLAN.md` §13 / §14 / §15. If
`PROJECT_PLAN.md` and this file disagree, treat the
`PROJECT_PLAN.md` row as authoritative and surface the drift.

---

## How this file relates to the rest of the doc set

- **Run a step:** paste the step's preamble, paste "Tutor mode
  P1/P2/P3/P4/P5:", and follow the per-step template below.
- **Verify Done Definition:** at end of phase, run the §14
  Done Definition verification steps.
- **Tests:** each phase has a Test Plan row in §"Test Plan
  (§15 — v1 only)" of this file. Drift / Riverpod / widget
  tests live next to the code they cover (`test/data/`,
  `test/providers/`, `test/features/<feat>/`).
- **5-step tutor flow + Norms Ladder:** see
  `00-tutor-workflow-rules.md`.
- **D-cards:** see `08-decisions-log.md`. The per-step P5 quiz
  cites D-cards by number.
- **Invariants (I-1 through I-14):** see `02-architecture.md`
  §14 invariants. P4 review cites invariant numbers.
- **Design tokens (colors / typography / spacing):** see
  `04-ui-context.md`. P4 review cites token names.
- **Code patterns / framework conventions:** see
  `03-code-standards.md`.

---

## Iteration ↔ phase mapping (PROJECT_PLAN.md §13.1)

v1 ships Movies only (I1). Phases 1–6 cover Movies end-to-end.
TV Shows (I2) and Anime (I3) are deferred to v2 and gain their
own rewrite of this file in `PROJECT_PLAN.md` §18.

**Quick mapping (v1 only):**
- I1 (Movies) → Phases 1, 3a, 3b, 4, 5, 6
- v2-only (I2, I3; sharing; community; recommendations; Supabase;
  import) → outside this file. Pointer: redo `05-phases.md` in
  `PROJECT_PLAN.md` §18.

---

## Build Order (PROJECT_PLAN.md §13 — v1 only)

| # | Phase | Produces |
|---|---|---|
| 0 | Tooling | `flutter doctor` clean; emulator `emulator-5554` online; default counter app launched |
| 1 | Widget fundamentals + static catalogue hub | Hardcoded `Movie`s, `MovieCard`, `HubCard`, hub page (Collection / Bucketlist) |
| 2 | App shell | `go_router` config with 11 routes; 2-tab bottom nav in v1; `MediaSearchClient` interface defined; `MaterialApp.router` wiring (D-L3, D-L4) |
| 3a | Drift data model | `AppDatabase` `schemaVersion = 1`; `media_items` + `movie_details`; 2-state enum as TEXT; `EnumNameConverter` wired at column level (D7, D20, D28); DAOs; Drift repo tests |
| 3b | TMDB search interface | `MediaSearchClient` abstract (locked signature); `DioMediaSearchClient` impl with API-key interceptor; TMDB DTOs; `SearchRepository`; idempotency via `AlreadyInCollection` (§7.7); offline fallback; API key in `lib/secrets.dart` |
| 4 | Riverpod over drift | `databaseProvider`, `moviesListProvider`, `searchProvider`, `filterProvider`; CRUD via providers; provider tests |
| 5 | Full CRUD UI (Movies only) | Add / Edit / Delete on Movies; Search Page 5-state flow; AddSheet as State C inline; EditSheet as `ModalBottomSheet`; ManualEntryForm; 6 files under `lib/features/search/`; widget tests |
| 6 | Polish | Verify light + dark palettes; typography ramp; empty states; offline UX; accessibility (semantics labels, focus order); error states; optional integration test |
| 7 | Wrap-up | Retrospective on locked decisions vs. hunches; v2 handoff brief |

One commit per phase (or per sub-phase when a phase contains two
independent concerns — Phase 3a / 3b), per `03-code-standards.md`
§6.4.

---

## Phase 0 — Tooling (DONE)

### Done Definition (U1)
- `flutter doctor` clean
- emulator-5554 online
- default counter app launched

### Verify (run once)
```bash
flutter doctor
flutter emulators                    # emulator-5554 listed
flutter run                          # default counter app launched
```

This is the only phase with no sub-steps. The shipped Phase 0
output is the green "default counter app" on the emulator. From
here, every phase replaces the counter app with a v1-shaped
surface.

---

## Phase 1 — Static catalogue hub (DONE with D33 amendment)

**Banner — D33 amendment:** Phase 1 is shipped. The code
checked in used `MediaStatus.onWatchlist` / `"Bucket List"` /
`to_consume_page.dart`; the canonical rename cascade (per
D-L13 → `onBucketlist` / `"Bucketlist"` /
`bucketlist_page.dart`) is captured in `08-decisions-log.md` D33
and runs as a separate v1 cleanup commit. This phase's sub-step
templates are recorded for archival reference; the user does
NOT redo Phase 1 by hand.

### Done Definition (U2)
- `lib/features/catalogue/data/movie.dart` — value object
- `lib/features/catalogue/data/sample_movies.dart` — 5 `const Movie(...)` entries + `collectedMovies` / `bucketListMovies` getters
- `lib/features/catalogue/widgets/movie_card.dart`
- `lib/features/catalogue/widgets/hub_card.dart`
- `lib/features/catalogue/my_collection_page.dart`
- `lib/features/catalogue/bucketlist_page.dart`
- `lib/features/catalogue/catalogue_page.dart` + `main.dart` rewrite

**Verify:** launch → Catalogue hub shows → tap Collection card → 3 movies visible → back → tap Bucketlist card → 2 movies visible.

### Phase 1.1 — Theme scaffolding + main.dart rewrite

**P1 — Concepts (read first):**
- Material 3 `ThemeData`: 2-3 minute read; the spec at [m3.material.io/styles/system/typography](https://m3.material.io/styles/system/typography) covers `ColorScheme.fromSeed`.
- `ColorScheme.fromSeed(seedColor: …, brightness: …)`: derives both palettes from one seed.

**P2 — Programming quiz (before coding):**
- "What does `themeMode: ThemeMode.system` do?" — answer: follows the OS light/dark setting; v1 ships both palettes so no in-app override is needed.

**P3 — Step work:**
- Create `lib/app/theme.dart` with `buildAppTheme({Brightness brightness})` returning `ThemeData` with `ColorScheme.fromSeed(seedColor: const Color(0xFF6B7FE0), brightness: ...)` (any deep-blue/indigo seed).
- Rewrite `lib/main.dart`: `runApp(const MaterialApp(theme: buildAppTheme(brightness: Brightness.light), darkTheme: buildAppTheme(brightness: Brightness.dark), themeMode: ThemeMode.system, home: const CataloguePage()))`.

**P4 — Tutor review:** `app/theme.dart` reads `colorScheme.<token>` never raw hex; `main.dart` imports `package:flutter/material.dart` (I-12); both palettes compile.

**P5 — Project quiz (after review passes):**
- "Why is one seed used for both palettes?" — answer: visual whiplash on theme toggle (D19 in `08-decisions-log.md`).

### Phase 1.2 — Data: `movie.dart` + `movie_status.dart`

**P1:** Dart `enum` (project already familiar). Light intro to value objects vs entities.

**P2:** "Is `MediaStatus` a Dart enum? Could it be a String for simplicity?" — answer: Dart enum; `EnumNameConverter` at column level catches typos at storage boundary (D20).

**P3:** Create `lib/features/catalogue/data/movie_status.dart`:
```dart
enum MediaStatus { onWatchlist, inCollection }  // historical D33
```
Create `lib/features/catalogue/data/movie.dart` with title, year, genre(s), rating (nullable), status.

**P4:** File names use `lowercase_with_underscores`; one public class per file; the enum file has no other content; `MediaStatus.onBucketlist` is the canonical name per D-L13 / D33.

**P5:** "Why does v1 ship only 2 states?" — answer: invisible QA debt from shipping values the UI can't surface (D20).

### Phase 1.3 — Data: `sample_movies.dart`

**P1:** Dart `const` constructors; `List<T>` with named getters.

**P2:** "Why `const`?" — answer: compile-time immutability, can be shared across rebuilds.

**P3:** Create `sample_movies.dart` with 5 `const Movie(...)` entries + `List<Movie> get collectedMovies` and `List<Movie> get bucketListMovies` getters.

**P4:** All 5 movies are `const`; getters are immutable `final` lists; no I/O is hit at construction time.

**P5:** "What does this file get replaced by in v1?" — answer: the Drift-backed `media_items` table; `sample_movies.dart` is scaffolding for Phase 1 only (no longer referenced after Phase 3a lands).

### Phase 1.4 — Widget: MovieCard

**P1:** Flutter `Card` widget; `Card` + `ListTile` (per `04-ui-context.md`).

**P2:** "Why `ListTile` vs `Row` + `Column`?" — answer: ListTile pre-handles `title` / `subtitle` / `trailing` with theme-aware typography tokens.

**P3:** Create `lib/features/catalogue/widgets/movie_card.dart` with `Card(child: ListTile(title: Text(...), subtitle: Text(year), trailing: status pill))`. Status pill is a small `Container` with `color/primary` (Bucketlist) or `color/secondary` (Collection) bg + `labelMedium` text.

**P4:** Title uses `headlineSmall` Source Serif 4; subtitle uses `bodyMedium` Inter; `Card` uses `color/surface` per `04-ui-context.md` §2.1.

**P5:** "Why a serif title and a sans body?" — answer: editorial weight + legibility (D18).

### Phase 1.5 — HubCard + Catalogue + Collection + Bucketlist pages

**P1:** Material `Scaffold` + `AppBar` + body; `Stack` + `Positioned.fill` for the HubCard's full-bleed image.

**P2:** "Why a Stack on HubCard?" — answer: full-bleed image with centered text overlay (per the wireframe `Catalogue Page.png`).

**P3:** Create `lib/features/catalogue/widgets/hub_card.dart` (`Card` + `Stack` + image overlay + centered label). Create `lib/features/catalogue/my_collection_page.dart`, `bucketlist_page.dart`, `catalogue_page.dart` (in v1 the latter shows two HubCards in a `ListView`).

**P4:** `path.startsWith('/catalogue')` light condition is not implemented yet (that lands in Phase 2); Phase 1 uses `MaterialApp.home: const CataloguePage()` only.

**P5:** "How does Phase 1 set up Phase 5's MovieCard re-use?" — answer: `MovieCard`'s `Card` + `ListTile` shape carries forward to the Search Results tile in Phase 5 with the same token mapping.

---

## Phase 2 — App shell (DONE)

### Done Definition (Phase 2 had no U#; fills the §13 row)
- `lib/app/router.dart` — `buildAppRouter` factory returning a 11-route `GoRouter` (D29 in `08-decisions-log.md`)
- `lib/main.dart` rewritten to `MaterialApp.router(routerConfig: buildAppRouter())` (per the lesson from `02-architecture.md` §3.2)
- `lib/core/http/` supporting types: `media_type.dart`, `media_search_result.dart`, `errors.dart`
- `lib/core/http/media_search_client.dart` — abstract interface per I-11

### Phase 2.1 — pubspec.yaml + supporting types

**P1:** Dart `pubspec.yaml` (`flutter pub add`); Dart `sealed class` for `MediaSearchResult`; `enum MediaType { movie }`.

**P2:** "What does `sealed class` do here?" — answer: switches pattern-matching at compile time; the v2 widen (TV, Books, etc.) makes exhaustive switches mandatory.

**P3:**
- `flutter pub add go_router` (D29; v17.3.0)
- Create `lib/core/http/media_type.dart`:
  ```dart
  enum MediaType { movie }  // v1; D28 widens in v2
  ```
- Create `lib/core/http/media_search_result.dart` (sealed class with `tmdbId`, `title`, `year`, `posterUrl`)
- Create `lib/core/http/errors.dart` with `MediaSearchUnavailable` (impl lands Phase 3b)

**P4:** `pubspec.yaml` uses caret ranges in v1 (I-9 relaxed); pin v2 cleanup.

**P5:** "Why is `MediaSearchClient` a v1 requirement even though it's not used yet?" — answer: the seam enables Phases 3b/4 to plug in without touching call sites (D9; I-5).

### Phase 2.2 — `MediaSearchClient` abstract interface

**P1:** Dart abstract class with positional/named/required parameters (per [dart.dev/effective-dart/design](https://dart.dev/effective-dart/design)).

**P2:** "What's the difference between `abstract class` and `interface`?" — answer: Dart has no `interface` keyword; `abstract class` with no constructors serves as the interface.

**P3:** Create `lib/core/http/media_search_client.dart`:
```dart
abstract interface class MediaSearchClient {
  Future<List<MediaSearchResult>> search({
    required String query,
    required MediaType mediaType,
  });
}
```

**P4:** I-11 verified — signature exact: `Future<List<MediaSearchResult>> search({required String query, required MediaType mediaType})`.

**P5:** "Why does the interface lock parameters here?" — answer: v2 widens the type set; v1 forbids extending the required set (D27).

### Phase 2.3 — `buildAppRouter` (go_router config)

**P1:** `MaterialApp.router` + `GoRouter` + `GoRoute` (per `03-code-standards.md` §3.3).

**P2:** "Why `path.startsWith('/catalogue')` for active-tab?" — answer: child routes inherit parent path; the active-tab check follows.

**P3:** Create `lib/app/router.dart`:
```dart
GoRouter buildAppRouter() => GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (_, __) => const LandingPage()),
    GoRoute(path: '/home', builder: (_, __) => const HomePage()),
    GoRoute(path: '/catalogue', builder: (_, __) => const CataloguePage(),
        routes: [
          GoRoute(path: 'collection', builder: (_, __) => const CollectionPage()),
          GoRoute(path: 'bucketlist', builder: (_, __) => const BucketlistPage()),
        ]),
    GoRoute(path: '/search', builder: (_, __) => const SearchPage()),
    // /profile, /media-type, /settings, /help, /about — stub pages
  ],
);
```

**P4:** 11 routes total (per `02-architecture.md` §6.5). Initial route `/`.

**P5:** "Why does `MaterialApp(routerConfig: …)` not compile on Flutter 3.44.x?" — answer: the constructor doesn't accept `routerConfig:`; only `MaterialApp.router(routerConfig: …)` works (per `02-architecture.md` §3.2).

### Phase 2.4 — main.dart rewiring (`MaterialApp.router`)

**P1:** already covered in Phase 1.1 (theme). `MaterialApp.router(...)` specifics per `03-code-standards.md` §3.3.

**P2:** (skip; covered in 1.1)

**P3:** Rewrite `lib/main.dart`:
```dart
runApp(const ProviderScope(
  child: MaterialApp.router(
    title: 'Media Tracker',
    theme: buildAppTheme(brightness: Brightness.light),
    darkTheme: buildAppTheme(brightness: Brightness.dark),
    themeMode: ThemeMode.system,
    routerConfig: buildAppRouter(),
  ),
));
```

**P4:** `MaterialApp.router(...)` is the canonical constructor; no `MaterialApp(routerConfig: …)` shortcut.

**P5:** "Why `ProviderScope` at the root?" — answer: it's the Riverpod host that makes providers available to descendant widgets (Phase 4 details).

---


## Phase 3a — Drift data model (CURRENT WORK)

### Done Definition (U3)
- `lib/data/database.dart` — `AppDatabase extends GeneratedDatabase`, `schemaVersion = 1`
- `lib/data/tables/media_items.dart` — `EnumNameConverter<MediaType>` and `EnumNameConverter<MediaStatus>` wired at the column level (D6/D7/D20/D28)
- `lib/data/tables/movie_details.dart` — joined by `media_item_id`; unique partial index on `tmdb_id`
- `MigrationStrategy.onCreate` builds both tables + indexes
- `MigrationStrategy.onUpgrade` includes additive migration steps (placeholder for v2 — no steps needed in v1)
- `lib/data/daos/movie_dao.dart` — typed queries, including `findByTmdbId(int)` for idempotency (§7.7)
- 4-5 repository tests: insert, query, delete, migration v1→v2, `findByTmdbId` returns existing row

### Phase 3a.1 — pubspec.yaml deps + dev deps

**P1:** Dart packages; codegen pattern (`build_runner`); Drift 2.x package layout per [drift.simonbinder.eu/docs/setup](https://drift.simonbinder.eu/docs/setup/).

**P2:** "Why does Drift need `build_runner`?" — answer: code generation; `drift_dev` runs over table definitions to produce `database.g.dart` (`03-code-standards.md` §2.5).

**P3:**
```bash
flutter pub add drift sqlite3_flutter_libs path_provider
flutter pub add --dev drift_dev build_runner
```
Add to `build.yaml`:
```yaml
targets:
  $default:
    builders:
      drift_dev:
        options:
          databases:
            app_database: lib/data/database.dart
```

**P4:** `drift` 2.34.x; `drift_dev` 2.34.x; `build_runner` 2.15.x; gitignore `*.g.dart`.

**P5:** "Why split runtime vs dev dependencies?" — answer: `drift_dev` and `build_runner` are build-time only; shipping them increases the APK.

### Phase 3a.2 — Tables: `media_items` + `movie_details`

**P1:** Drift tables (Dart classes extending `Table`); `IntColumn`, `TextColumn`, `RealColumn`, `DateTimeColumn`, `BoolColumn`; column types per [drift.simonbinder.eu/docs/dart-tables](https://drift.simonbinder.eu/docs/dart-tables/).

**P2:** "Why `text()` for `type` and `status` instead of `int().map(EnumIndexConverter())`?" — answer: D6 — zero schema change when widening; serializer-friendly across Postgres migration (D26).

**P3:** Create `lib/data/tables/media_items.dart`:
```dart
class MediaItems extends Table {
  IntColumn   get id          => integer().autoIncrement()();
  TextColumn  get title       => text().withLength(min: 1, max: 256)();
  TextColumn  get type        => text().map(const EnumNameConverter<MediaType>())();
  TextColumn  get status      => text().map(const EnumNameConverter<MediaStatus>())();
  RealColumn  get rating      => real().nullable()();
  TextColumn  get source      => text().withDefault(const Constant('manual'))();
  DateTimeColumn get importedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}
```
Create `lib/data/tables/movie_details.dart`:
```dart
class MovieDetails extends Table {
  IntColumn       get mediaItemId => integer().references(MediaItems, #id)();
  TextColumn      get director    => text().nullable()();
  IntColumn       get runtimeMin  => integer().nullable()();
  TextColumn      get studio      => text().nullable()();
  IntColumn       get tmdbId      => integer().unique()();
  TextColumn      get posterUrl   => text().nullable()();
  TextColumn      get backdropUrl => text().nullable()();
  @override
  String get tableName => 'movie_details';
}
```

**P4:** I-2 / I-3 verified (converts wired at column level); I-1 verified (no migration required for v1 columns); unique index on `tmdb_id` is the last-line idempotency defense (D21).

**P5:** "Why `text().withDefault(Constant('manual'))` for source?" — answer: D25 — v1 always manual; v2 import populates with non-default values.

### Phase 3a.3 — `AppDatabase` class + `MigrationStrategy`

**P1:** Drift `@DriftDatabase` annotation; `MigrationStrategy.onCreate`; `MigrationStrategy.onUpgrade` per [drift.simonbinder.eu/docs/advanced-features/migrations](https://drift.simonbinder.eu/docs/advanced-features/migrations).

**P2:** "What does `MigrationStrategy.onCreate` do?" — answer: runs only on fresh database creation, *not* on schema upgrades. The right place to call `m.createAll()`.

**P3:** Create `lib/data/database.dart`:
```dart
@DriftDatabase(tables: [MediaItems, MovieDetails])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async => m.createAll(),
    onUpgrade: _schemaUpgrade,
  );
}
```
Run `dart run build_runner build --delete-conflicting-outputs` — generates `database.g.dart`.

**P4:** `MigrationStrategy.onUpgrade` is empty in v1 (no columns to migrate); placeholder extension `extension on AppDatabase { onUpgrade: (m, from, to) async {} }` for v2 (D13 + drift `stepByStep`).

**P5:** "Why `schemaVersion = 1` even though there are no v1 migrations?" — answer: D13 + I-1 — the version is the *current* schema state, used as the baseline for future migrations.

### Phase 3a.4 — `MovieDao`

**P1:** Drift `@DriftAccessor` + `DatabaseAccessor` mixin; typed query DSL per [drift.simonbinder.eu/docs/dart-api](https://drift.simonbinder.eu/docs/dart-api).

**P2:** "Why a separate `MovieDao` rather than putting queries on `AppDatabase`?" — answer: separation of concerns; tests instantiate `MovieDao` with a test database without spinning up full app context (D14).

**P3:** Create `lib/data/daos/movie_dao.dart`:
```dart
@DriftAccessor(tables: [MediaItems, MovieDetails])
class MovieDao extends DatabaseAccessor<AppDatabase>
    with _$MovieDaoMixin {
  MovieDao(super.db);

  Future<MediaItem?> findById(int id) =>
      (select(mediaItems)..where((m) => m.id.equals(id))).getSingleOrNull();

  Future<MediaItemWithDetails?> findByTmdbId(int tmdbId) =>
      (select(movieDetails)..where((md) => md.tmdbId.equals(tmdbId)))
          .getSingleOrNull();

  Stream<List<MediaItem>> watchByStatus(MediaStatus status) =>
      (select(mediaItems)..where((m) => m.status.equalsValue(status))).watch();

  Future<int> insertMovie(MediaItemsCompanion entry) =>
      into(mediaItems).insert(entry);

  // Add update / delete / update-status variants as needed.
}
```

**P4:** I-6 enforced — `lib/features/` never imports `drift`; only `lib/data/` does. The `findByTmdbId` method's existence enforces D21.

**P5:** "Why `Stream<List<MediaItem>>` for watches?" — answer: Drift emits rows on change; the in-memory provider (`Riverpod 3`) re-emits to the UI via `StreamProvider` (Phase 4 wires this).

### Phase 3a.5 — Drift repository tests

**P1:** Drift `NativeDatabase.memory()` for tests (no emulator); `SchemaVerifier`; `package:test` per [drift.simonbinder.eu/docs/advanced-features/migrations](https://drift.simonbinder.eu/docs/advanced-features/migrations).

**P2:** "Why `memory` and not a temp file?" — answer: `memory` is faster, no I/O, and the schema is the same.

**P3:** Create `test/data/movie_dao_test.dart`:
```dart
import 'package:drift/native.dart';
import 'package:test/test.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  test('insert + findById returns the row', () async {
    final id = await db.movieDao.insertMovie(
      MediaItemsCompanion.insert(
        title: 'The Matrix',
        type: const Value(MediaType.movie),
        status: const Value(MediaStatus.onBucketlist),
      ),
    );
    final row = await db.movieDao.findById(id);
    expect(row, isNotNull);
    expect(row!.title, 'The Matrix');
  });

  test('findByTmdbId returns existing row (idempotency)', () async {
    await db.movieDetails.insert(
      MovieDetailsCompanion.insert(mediaItemId: 1, tmdbId: 603),
    );
    final row = await db.movieDao.findByTmdbId(603);
    expect(row, isNotNull);
  });

  // + delete, + migration v1→v2, + enum round-trip (Bucketlist ↔ String).
}
```

**P4:** I-10 (test mirror) — `test/data/` mirrors `lib/data/`; ~50 lines for these 5 tests (per §"Test Plan (§15 — v1 only)" below).

**P5:** "Why a migration test if v1 has no migrations?" — answer: future-proofs v2 — when v2 adds a migration, this test stub becomes the pattern (D13).

---

## Phase 3b — TMDB search interface

### Done Definition (U4)
- `lib/core/http/media_search_client.dart` — abstract interface; locked signature
- `lib/core/http/dio_media_search_client.dart` — Dio-backed v1 impl with API-key interceptor; routes `/search/movie` and `/search/tv` based on `mediaType` (TV routes are v2-only; v1 hard-codes `/search/movie`)
- `lib/core/http/tmdb/dtos.dart` — TMDB response DTOs (search results, image URLs)
- `lib/data/repositories/errors.dart` — `AlreadyInCollection` exception
- `lib/data/repositories/search_repository.dart` — wraps `MediaSearchClient`; idempotency via `findByTmdbId`
- API key source: `lib/secrets.dart` (gitignored) or env var
- Offline fallback: manual-entry form when `MediaSearchUnavailable`

### Phase 3b.1 — TMDB DTOs (image URLs, response shape)

**P1:** TMDB API v3 search-and-details (per [developer.themoviedb.org/docs/search-and-query-for-details](https://developer.themoviedb.org/docs/search-and-query-for-details)); TMDB image basics (per [developer.themoviedb.org/docs/image-basics](https://developer.themoviedb.org/docs/image-basics)).

**P2:** "What's the poster URL shape?" — answer: `https://image.tmdb.org/t/p/{size}/{poster_path}` where `size ∈ {w92, w154, w185, w342, w500, w780, original}`.

**P3:** Create `lib/core/http/tmdb/dtos.dart`:
```dart
class _MediaSearchResultDto {
  final int id;
  final String? title;
  final String? release_date;
  final String? poster_path;
  final double? vote_average;
  // deserializer
  factory _MediaSearchResultDto.fromJson(Map<String, dynamic> json) =>
      _MediaSearchResultDto(
        id: json['id'] as int,
        title: json['title'] as String?,
        release_date: json['release_date'] as String?,
        poster_path: json['poster_path'] as String?,
        vote_average: (json['vote_average'] as num?)?.toDouble(),
      );
  // + toDomain() → MediaSearchResult
}
```
Image URL helper:
```dart
String tmdbImageUrl(String? path, {String size = 'w500'}) =>
    path == null ? '' : 'https://image.tmdb.org/t/p/$size$path';
```

**P4:** No raw JSON reaches `lib/features/`; only the typed `MediaSearchResult` from the DTO mapper does.

**P5:** "Why a separate `_MediaSearchResultDto` private class?" — answer: the wire format may evolve separately from the domain type; the boundary hides that.

### Phase 3b.2 — `DioMediaSearchClient` impl

**P1:** Dio basics + interceptors (per [pub.dev/packages/dio](https://pub.dev/packages/dio)); interceptor order matters.

**P2:** "What does the Dio interceptor stack look like in v1?" — answer: (1) `AuthInterceptor` (injects `api_key` query param) → (2) `LogInterceptor` (last, only in DEBUG).

**P3:** Create `lib/core/http/dio_media_search_client.dart`:
```dart
class DioMediaSearchClient implements MediaSearchClient {
  DioMediaSearchClient(this._dio);
  final Dio _dio;

  @override
  Future<List<MediaSearchResult>> search({
    required String query,
    required MediaType mediaType,
  }) async {
    try {
      final path = mediaType == MediaType.movie
          ? '/search/movie'
          : '/search/tv';  // v2 only
      final res = await _dio.get<Map<String, dynamic>>(path,
        queryParameters: {'query': query, 'api_key': _apiKey()},
      );
      return (res.data!['results'] as List)
          .map((j) => MediaSearchResult.fromJson(j))
          .toList();
    } on DioException catch (e) {
      throw MediaSearchUnavailable(cause: e);
    }
  }
}
```

**P4:** I-5 verified — `package:dio` import only in `lib/core/http/`, never `lib/features/`.

**P5:** "Why throw `MediaSearchUnavailable` instead of returning a `Result`?" — answer: Dart has no `Result`; exceptions are typed (per `02-architecture.md` §Error contract).

### Phase 3b.3 — `SearchRepository` + Errors + idempotency

**P1:** Idempotency pattern (check-then-act); repositories throw typed exceptions.

**P2:** "Why is `add` idempotent at all?" — answer: D21 — re-adding the same TMDB movie is a UX bug; the user shouldn't see two `The Matrix` rows.

**P3:** Create `lib/data/repositories/errors.dart`:
```dart
class AlreadyInCollection implements Exception {
  final int existingId;
  AlreadyInCollection({required this.existingId});
}
```
Create `lib/data/repositories/search_repository.dart`:
```dart
class SearchRepository {
  SearchRepository(this._db, this._client);
  final AppDatabase _db;
  final MediaSearchClient _client;

  Future<MediaItem> addOrThrow(MediaItemsCompanion entry, int tmdbId) async {
    final existing = await _db.movieDao.findByTmdbId(tmdbId);
    if (existing != null) {
      throw AlreadyInCollection(existingId: existing.id);
    }
    final id = await _db.movieDao.insertMovie(entry);
    final inserted = await _db.movieDao.findById(id);
    return inserted!;
  }
}
```

**P4:** D21 — repo throws → provider catches → snackbar (per `02-architecture.md` §Error contract).

**P5:** "Why throw before insert instead of catching a unique-index violation?" — answer: the pre-check surfaces a friendly snackbar; the unique index on `tmdb_id` is last-line defense for race-condition duplicate inserts.

### Phase 3b.4 — Provider wire (skeleton; full wire in Phase 4)

**P1:** Already covered in Phase 2 + Phase 4 ahead.

**P2:** (skip)

**P3:** Create placeholder in `lib/providers/search_provider.dart` (Rivepod `searchProvider` lands in Phase 4; this step signs the search repo into the provider graph).

**P4:** Repository holds a `MediaSearchClient` reference; provider holds a `SearchRepository` reference.

**P5:** "Why wire the search repo in Phase 3b if the provider isn't done?" — answer: future-proofs Phase 4 — the repo already exists.

---

## Phase 4 — Riverpod over drift

### Done Definition (U5)
- `lib/providers/database_provider.dart`
- `lib/providers/movies_list_provider.dart`
- `lib/providers/search_provider.dart`
- `lib/providers/filter_provider.dart` (Genre-only, per Q4)
- 2-3 provider tests via `ProviderContainer.test`

### Phase 4.1 — `databaseProvider`

**P1:** Riverpod 3 `Provider<T>`; `@riverpod` codegen (per [riverpod.dev/docs/concepts/about_code_generation](https://riverpod.dev/docs/concepts/about_code_generation)).

**P2:** "Why `keepAlive: true` for the database?" — answer: only one `AppDatabase` instance lives for the app's lifetime; creating it is expensive.

**P3:** Create `lib/providers/database_provider.dart`:
```dart
@Riverpod(keepAlive: true)
AppDatabase appDatabase(Ref ref) {
  final db = AppDatabase(NativeDatabase.createInBackground(
    File('${(await getApplicationSupportDirectory()).path}/media_tracker.sqlite'),
  ));
  ref.onDispose(() => db.close());
  return db;
}
```
Run `dart run build_runner build --delete-conflicting-outputs`.

**P4:** I-7 verified (no `setState`); `Ref.onDispose` cleans up on teardown.

**P5:** "Why keep this provider alive?" — answer: Drift's isolate-based DB initialization is one-shot per app run; rebuilding on every consumer detach would be wasteful.

### Phase 4.2 — `moviesListProvider`

**P1:** `Stream<List<T>>` providers in Riverpod (per [riverpod.dev/docs/concepts/providers](https://riverpod.dev/docs/concepts/providers)).

**P2:** "What's the difference between `Provider`, `FutureProvider`, and `StreamProvider`?" — answer: sync, future-once, stream-of-many. For drift `watch()`, use StreamProvider.

**P3:** Create `lib/providers/movies_list_provider.dart`:
```dart
@riverpod
Stream<List<MediaItem>> moviesList(Ref ref, MediaStatus status) {
  final db = ref.watch(appDatabaseProvider);
  return db.movieDao.watchByStatus(status);
}
```

**P4:** `StreamProvider` rebuilds on each emission; UI gets auto-rebuilds when the DB changes.

**P5:** "Why take `MediaStatus` as a parameter?" — answer: D8 — Collection / Bucketlist are filtered views on the same table; one provider parameterized by status beats two near-identical providers.

### Phase 4.3 — `searchProvider`

**P1:** Already covered in Phase 3b.4.

**P2:** "Why is `searchProvider` here and not Phase 3b?" — answer: 3b creates the search *repo*; here we make it reactive (`AsyncNotifier` / `AsyncValue`).

**P3:** Create `lib/providers/search_provider.dart`:
```dart
@riverpod
class Search extends _$Search {
  @override
  AsyncValue<List<MediaSearchResult>> build() =>
      const AsyncValue.loading();

  Future<void> query(String q) async {
    state = const AsyncValue.loading();
    try {
      final repo = ref.watch(searchRepositoryProvider);
      final results = await repo.query(q, MediaType.movie);
      state = AsyncValue.data(results);
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }
}
```

**P4:** `AsyncValue<T>` (loading/data/error) is the Riverpod 3 standard.

**P5:** "Why expose the search as `query(String)` and not a `query(Filters)`?" — answer: Q4 + D-L9 — Genre-only filter is Phase 5's surface; v1 ships single-query search.

### Phase 4.4 — `filterProvider` (Genre)

**P1:** Sealed-class filter state; Riverpod `Notifier`.

**P2:** "Why a separate filter provider, not part of `searchProvider`?" — answer: filter selection persists across search queries; independent of search results.

**P3:** Create `lib/providers/filter_provider.dart`:
```dart
@riverpod
class CollectionFilter extends _$CollectionFilter {
  @override
  MediaGenre? build() => null;  // null = "all genres"

  void set(MediaGenre? genre) => state = genre;
}
```

**P4:** Q4 — single-select Genre chips in the Media Filter sheet (Phase 5.9).

**P5:** "Why a Notifier instead of a single-slot provider?" — answer: `set(genre)` is the mutation point; v2 widens with multi-select.

### Phase 4.5 — Provider tests via `ProviderContainer.test`

**P1:** Riverpod 3 `ProviderContainer.test` (per [riverpod.dev/docs/guides/testing](https://riverpod.dev/docs/guides/testing)).

**P2:** "Why `ProviderContainer.test` and not pump a widget?" — answer: provider tests are pure-logic; widget tests are integration. Keep them separate (D14).

**P3:** Create `test/providers/movies_list_provider_test.dart`:
```dart
test('moviesListProvider reflects insert', () async {
  final container = ProviderContainer(overrides: [
    appDatabaseProvider.overrideWithValue(_memoryDb()),
  ]);
  addTearDown(container.dispose);

  // Insert a row.
  await container.read(moviesListProvider(MediaStatus.onBucketlist).future);

  // Subscribe to emissions.
  container.listen(moviesListProvider(MediaStatus.onBucketlist),
      (prev, next) {});
  // Assert list has row after insert.
});
```

**P4:** D14 verified — 2-3 provider tests; ~30 lines.

**P5:** "Why `listen` after reading?" — answer: the read triggers loading; the listen captures emissions to assert idempotency / progress.

---

## Phase 5 — Full CRUD UI (Movies only)

### Done Definition (U6)
- Search Page 5-state flow (State A → B → C → D → E; per `02-architecture.md` §7)
- AddSheet as State C inline
- EditSheet as `ModalBottomSheet` from `MovieCard.onTap` (D-L6, `04-ui-context.md` §3.6)
- ConfirmSelection as State E with toggle + per-item remove (Q2 E2)
- 'X' close button + exit-confirm dialog at States C and E (§7.6)
- URL: `/search?q=<query>&type=movie` (Q10)
- 6 files under `lib/features/search/` (Q8)
- Media Filter button (Q4) opens Genre-only modal sheet
- Hamburger Menu stubs (Profile / Settings / Help / About; Q5)
- MediaTypePage lists 6 types (Q6)
- ManualEntryForm at State B' when TMDB unavailable, status defaults to Bucketlist (Q7)
- Delete confirmation
- 3-4 widget tests

### Phase 5.1 — 6-file structure under `lib/features/search/`

**P1:** Dart file-per-widget convention (per `03-code-standards.md` §2.2).

**P2:** "Why 6 files for one page?" — answer: each state is its own widget; one file per public widget makes review diffs reviewable.

**P3:** Create the 6 files:
- `lib/features/search/search_page.dart` — `SearchPage` (route entry + state machine)
- `lib/features/search/search_input_view.dart` — State A
- `lib/features/search/search_results_view.dart` — State B
- `lib/features/search/add_sheet_view.dart` — State C
- `lib/features/search/similar_titles_view.dart` — State D
- `lib/features/search/confirm_selection_view.dart` — State E

Run `dart run build_runner build --delete-conflicting-outputs` if any gen files touched.

**P4:** §2.2 — one public widget per file; private widgets prefixed with `_`.

**P5:** "Why not a single `_SearchPageState` enum + giant switch?" — answer: split files keep each state's widget short and reviewable; tests target one state at a time.

### Phase 5.2 — Search Page State A (input)

**P1:** Flutter `TextField` (per `04-ui-context.md` §2.1).

**P2:** "When does `Search Page` open?" — answer: when `context.push('/search')` is called from the FAB on Home/Collection/Bucketlist (Q1).

**P3:** Create `search_input_view.dart`:
```dart
class SearchInputView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        TextField(
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Search movies…',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12), // radius/md
              borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
            ),
            contentPadding: EdgeInsets.all(16), // space/md
          ),
          onSubmitted: (q) => ref.read(searchProvider.notifier).query(q),
        ),
      ],
    );
  }
}
```

**P4:** `color/outline` token; `radius/md` value; `space/md` padding — all per `04-ui-context.md` §1.4 / §1.3.

**P5:** "Why `autofocus: true`?" — answer: the user opens Search to search; pre-focus saves a tap.

### Phase 5.3 — Search Page State B (results) + ManualEntryForm fallback

**P1:** `GridView.builder` for results; `MediaSearchResultTile`; `MediaSearchUnavailable` exception → manual entry.

**P2:** "When does ManualEntryForm take over?" — answer: state B catches `MediaSearchUnavailable` from the search provider; falls back to a manual-entry form (Q7).

**P3:** Create `search_results_view.dart`:
```dart
class SearchResultsView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(searchProvider);
    return state.when(
      loading: () => Center(child: CircularProgressIndicator(
        color: Theme.of(context).colorScheme.primary,
      )),
      error: (_, __) => ManualEntryForm(),  // offline fallback
      data: (results) => results.isEmpty
        ? Center(child: Text('No matches'))
        : GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: results.length,
            itemBuilder: (context, i) => MediaSearchResultTile(
              result: results[i],
              onTap: () => /* transition to State C */,
            ),
          ),
    );
  }
}
```
Create `manual_entry_form.dart` with Title / Year / Genre (chips) / Rating / Status toggle fields.

**P4:** `CircularProgressIndicator` uses `color/primary`; tiles match the Search Result tile token recipe (per `04-ui-context.md` §4.4).

**P5:** "Why `state.when` instead of `state.maybeWhen`?" — answer: exhaustive switches are mandatory on sealed-class state; `when` forces the three branches.

### Phase 5.4 — Search Page State C (AddSheet inline)

**P1:** `SegmentedButton` is banned per `04-ui-context.md` §2.2; use a `FilledButton` pair or a custom segmented row.

**P2:** "Why does State C default to Collection?" — answer: in the search-add flow, the user is curating what to add; Collection ("already consumed") is the more common entry.

**P3:** Create `add_sheet_view.dart`:
```dart
class AddSheetView extends ConsumerStatefulWidget {
  final MediaSearchResult picked;
  const AddSheetView({required this.picked, super.key});

  @override
  ConsumerState<AddSheetView> createState() => _AddSheetViewState();
}

class _AddSheetViewState extends ConsumerState<AddSheetView> {
  late MediaStatus _status = MediaStatus.inCollection; // default
  double _rating = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(...poster + status toggle...),  // see §4.5 of 04-ui-context.md
        // Rating: 0–10 slider (filled with color/secondary amber tone)
        Slider(
          value: _rating,
          min: 0,
          max: 10,
          divisions: 20,
          onChanged: (v) => setState(() => _rating = v),
          activeColor: Theme.of(context).colorScheme.secondary,
        ),
        Row(
          children: [
            FilledButton(
              onPressed: () async {
                // call SearchRepository.addOrThrow(...) — throws on dup
              },
              child: Text('Done'),
            ),
            TextButton(
              onPressed: () => /* transition to State D */,
              child: Text('Explore Similar Titles'),
            ),
          ],
        ),
      ],
    );
  }
}
```

**P4:** I-6 — `features/search/` does NOT import `drift`; the "Done" handler calls a provider, which calls the repo, which calls `MovieDao`.

**P5:** "Why `setState` for the rating slider?" — answer: I-7 — local UI state only; the rating's source of truth is the AddSheet itself, not a Riverpod provider.

### Phase 5.5 — Search Page State D (similar titles multi-select)

**P1:** `GestureDetector` + `onLongPress`; selection state local widget state.

**P2:** "Why long-press, not tap?" — answer: long-press is the cross-platform convention for "selection mode" in grids.

**P3:** Create `similar_titles_view.dart` with a 3-column `GridView`; tracks selected indices in a `Set<int>` local state; "Add" button transitions to State E.

**P4:** I-7 — selection mode is local UI state.

**P5:** "Why a separate widget file rather than folding into State B?" — answer: distinct state machine; one file per state keeps each under ~150 lines (Q8).

### Phase 5.6 — Search Page State E (ConfirmSelection)

**P1:** Per-item remove icons; responsive toggle label (Q2 E2).

**P2:** "Why does the 'Add' button label change reactively?" — answer: the button text refers to the destination; showing "Add to Collection" vs "Add to Bucketlist" reflects the current toggle state (Q2 E2).

**P3:** Create `confirm_selection_view.dart`:
```dart
// 3-col GridView of selected tiles, each with a remove icon top-right
// Top toggle: Collection / Bucketlist (single-select)
// Bottom: FilledButton showing 'Add to <currentDestination>'
```

**P4:** All tokens per `04-ui-context.md`.

**P5:** "Why per-item remove?" — answer: user may have bulk-added and wants to drop one before committing (per `01-project-overview.md` §First-session flow step 11).

### Phase 5.7 — Search Page chrome ('X' close + exit-confirm)

**P1:** Flutter `AlertDialog`; `Navigator.pop` and `exit` patterns.

**P2:** "When does the exit-confirm fire?" — answer: only at States C and E (per `01-project-overview.md` §First-session flow step 11); A / B / D exit silently.

**P3:** Wrap `SearchPage`'s `IconButton(close)` in an `onPressed` that checks the active state and shows the confirm dialog when needed.

**P4:** `SnackBar.floating` + `AlertDialog` are the only error-and-confirm primitives allowed (per `04-ui-context.md` §2.1).

**P5:** "Why the confirm dialog only at C and E?" — answer: A / B / D haven't accumulated unsaved selections; C and E have.

### Phase 5.8 — EditSheet

**P1:** `ModalBottomSheet.show`; pre-fill from existing `MediaItem`.

**P2:** "What happens when the user deletes from EditSheet?" — answer: confirm `AlertDialog` → `MovieDao.delete` → `Navigator.pop`.

**P3:** Create `lib/features/catalogue/widgets/edit_sheet.dart`:
```dart
class EditSheet extends ConsumerStatefulWidget {
  final MediaItemWithDetails item;
  const EditSheet({required this.item, super.key});

  @override
  ConsumerState<EditSheet> createState() => _EditSheetState();
}

// In build():
//   AppBar with title (from item.title), close icon
//   Body: poster image (left) + status toggle (right) + rating slider
//   Actions:
//     TextButton 'Delete' → confirm dialog → delete
//     FilledButton 'Save' → update MediaItem → pop
```

**P4:** Use `ModalBottomSheet` chrome per `04-ui-context.md` §3.6.

**P5:** "Why a `ModalBottomSheet` and not State C-style inline?" — answer: EditSheet modifies one item; State C is part of the broader add flow. They use different surfaces.

### Phase 5.9 — Media Filter sheet (Genre-only)

**P1:** `Chip` with `selected: bool`; Q4 single-select.

**P2:** "Why single-select in v1?" — answer: Q4 — multi-select widens in v2.

**P3:** Create `lib/features/catalogue/widgets/media_filter_sheet.dart`:
```dart
// Grid of Genre chips
Wrap(
  spacing: 8,
  children: MediaGenre.values.map((g) => ChoiceChip(
    label: Text(g.displayName),
    selected: selected == g,
    onSelected: (_) => setState(() => selected = g),
  )).toList(),
)
// Row of actions: Clear / Apply
```

**P4:** `Chip` tokens per `04-ui-context.md` §2.1; `radius/sm` (8 dp).

**P5:** "Why chips and not checkboxes?" — answer: chips match media-picker patterns; `Checkbox` is banned per `04-ui-context.md` §2.2.

### Phase 5.10 — Hamburger Menu stubs

**P1:** `Scaffold` + `AppBar(leading: BackButton)` for stub pages.

**P2:** "Why stubs instead of feature pages?" — answer: Q5 — kept simple; detailed behaviour defined at coding time.

**P3:** Create `lib/features/profile/profile_page.dart`, `settings_page.dart`, `help_page.dart`, `about_page.dart` — each is `Scaffold(appBar: AppBar(leading: BackButton(), title: Text('Profile' /* or ... */)), body: Center(child: Text('Stub — see TODO')))`.

**P4:** `BackButton()` in `AppBar.leading` standard.

**P5:** "Why is `MediaTypePage` not a stub?" — answer: Q6 — MediaType lists the 6 types with Movies-only-tappable; not a stub.

### Phase 5.11 — MediaTypePage (6 types; Movies-only-tappable)

**P1:** Tile list with disabled vs enabled states; Q6.

**P2:** "Why does MediaTypePage exist if you can't pick a type?" — answer: it's the agent-visibility of "v1 is movies-only"; ships 6 tiles with 5 disabled.

**P3:** Create `lib/features/media_type/media_type_page.dart`:
```dart
class MediaTypePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: BackButton(), title: Text('Media Type')),
      body: ListView(
        children: MediaType.values_v1.map((t) => ListTile(
          title: Text(t.displayName),
          enabled: t == MediaType.movie,
          onTap: t == MediaType.movie
              ? () => context.go('/home')
              : null,
        )).toList(),
      ),
    );
  }
}
```

`MediaType.values_v1` is a hard-coded 6-tuple per Q6:
(Movies, TV Shows, Anime, Video Games, Books, Comics).

**P4:** `ListTile` per `04-ui-context.md` §2.1.

**P5:** "Why hard-code 6 types, not read from a provider?" — answer: v2 widens the type set; v1 locks at 6 known values (the wireframe set per §18).

### Phase 5.12 — Wire FAB → `context.push('/search')`

**P1:** Already covered in `02-architecture.md` §FAB.

**P2:** "What does FAB `onPressed` do?" — answer: pushes `/search` onto the router stack.

**P3:** Find `floatingActionButton:` in `AppScaffold` and confirm: `onPressed: () => context.push('/search')` — exact route per `02-architecture.md` §6.7.

**P4:** No additional widgets needed.

**P5:** "Why `push` and not `go`?" — answer: `push` adds to the back stack so the user can return to the FAB's origin page; `go` replaces the current route.

### Phase 5.13 — Widget tests (3-4 tests per U6)

**P1:** Flutter `WidgetTester`; `ProviderScope`; `find.byType`, `find.byKey`.

**P2:** "Why test widgets and not the full app?" — answer: D14 — widget tests are isolated to the surface; integration tests come in Phase 6 (optional).

**P3:** Create `test/features/search/search_page_test.dart`:
```dart
testWidgets('Hub cards render', (tester) async {
  await tester.pumpWidget(MaterialApp(home: Scaffold(body: MyApp())));
  expect(find.byType(Hero), findsWidgets); // example
});

testWidgets('EditSheet prefill', (tester) async {
  // pump EditSheet with mock item; assert fields are populated
});

testWidgets('Delete confirm dialog', (tester) async {
  // tap Delete; tap Discard; assert repository delete not called
});

testWidgets('TMDB unavailable → manual entry form', (tester) async {
  // mock MediaSearchClient throwing; pump State B; assert form renders
});
```

**P4:** `test/features/<feat>/` mirrors `lib/features/<feat>/` per I-10.

**P5:** "Why 3-4 tests and not exhaustive?" — answer: D14 ~80 lines v1; targeted minimum.

---


## Phase 6 — Polish

### Done Definition (U8)
- Material 3 theme finalized
- Single seed color locked; both light and dark palettes shipped (D-L2)
- Typography ramp: Source Serif 4 + Inter via `google_fonts` (D18)
- Material Symbols Rounded font bundled as asset (D17, Apache 2.0); `IconData(fontFamily: 'MaterialSymbolsRounded', fontPackage: 'media_tracker')` used everywhere (per `04-ui-context.md` §4.1)
- Spacing scale locked (8px baseline, 12dp card radius)
- Both palettes verified (light + dark; OS-handler toggles between them)
- Empty-state widgets
- Accessibility pass (semantics labels, focus order)
- Error states

### Phase 6.1 — Verify both palettes render correctly

**P1:** `themeMode: ThemeMode.system`; `MediaQuery.platformBrightnessOf(context)`; manual override via `debugDefaultTargetPlatformOverride`.

**P2:** "How do I manually test dark mode in debug?" — answer: in the OS-level developer options toggle; in widget tests, override `MediaQuery` with `dark: MediaQueryData(platformBrightness: Brightness.dark, ...)`.

**P3:** Run `flutter run`; flip OS dark mode while running; verify every surface renders without text-color-on-same-color bleed.

**P4:** No widget uses `Theme.of(context).colorScheme` differently between the two palettes; both paths exercise all tokens.

**P5:** "Why does the test only check `platformBrightness`?" — answer: `themeMode.system` follows the OS setting; the test simulates that switch without touching widgets.

### Phase 6.2 — Verify typography ramp (Source Serif 4 + Inter)

**P1:** `google_fonts` runtime fetch (per D18); Source Serif 4 for display/headline; Inter for body/title/label.

**P2:** "Why are fonts runtime-fetched and not bundled?" — answer: per D18 — `google_fonts` is the verified `flutter.dev` publisher; bundling would bloat the APK.

**P3:** Verify `MovieCard` title renders in Source Serif 4 (`headlineSmall`); body in Inter (`bodyMedium`); FAB icon in Material Symbols Rounded (`add`).

**P4:** I-7 verified (verified publisher).

**P5:** "What happens offline on first launch?" — answer: `google_fonts` caches after first fetch; cached thereafter until OS evict.

### Phase 6.3 — Empty states

**P1:** Empty-state `Center + Text`; placeholder widget per `02-architecture.md` §6.10.

**P2:** "Where are empty states needed?" — answer: HubCards (both: Collection & Bucketlist empty on first launch); Search State B with no results; empty list of similar titles in State D.

**P3:** Render "No movies yet — tap + to add one." in each empty Collection / Bucketlist body. "No matches for '<query>'." for empty Search State B results.

**P4:** `bodyMedium` Inter; `color/on-surface-variant` (per `02-architecture.md` §6.10 Empty).

**P5:** "Why are HubCards empty even before first launch?" — answer: HubCards show counts ("3 movies", "2 movies"); empty HubCards show "0 movies" with a CTA hint.

### Phase 6.4 — Offline UX (TMDB unavailable → manual-entry form)

**P1:** Already covered in Phase 5.3.

**P2:** "What does the user see when offline?" — answer: Search Page State B catches `MediaSearchUnavailable`; renders the ManualEntryForm (Q7).

**P3:** Verify: turn off network; tap FAB → search → no results; manual-entry form visible; fill Title / Year / Rating / Status; Save → row inserted.

**P4:** Same path — `SearchRepository` calls `MovieDao.insertMovie`; offline or online doesn't matter once TMDB is bypassed.

**P5:** "Why a manual entry rather than 'try again'?" — answer: offline is determined by the network state, not the user's intent; the form gives the user agency.

### Phase 6.5 — Accessibility pass

**P1:** `Semantics(label: ...)`; focus traversal; `a11y/touch-target/min = 48 dp` (per `04-ui-context.md` §1.6).

**P2:** "Why wrap with `Semantics` instead of using a tooltip?" — answer: tooltips are visual cues; `Semantics.label` is the screen-reader name (D24; TalkBack compatibility).

**P3:** Wrap every `IconButton`, `FilledButton`, `FloatingActionButton`, and `Chip` in `Semantics(label: '<action description>')`. Verify with `talkBackEnabled: true` via `debugDefaultTargetPlatformOverride = TargetPlatform.android`.

**P4:** Touch targets ≥ 48 dp; color contrast ≥ 4.5:1 (WCAG 2.2 AA per `01-project-overview.md` §Non-functional).

**P5:** "What's the cost of `Semantics` wrapping?" — answer: zero runtime cost in release; debug-only logging.

### Phase 6.6 — Error states

**P1:** `AlertDialog` for save-failed / network-failed; `SnackBar` for transient.

**P2:** "What counts as 'error state' in v1?" — answer: network failure on Save (SnackBar), repository constraint violation (`AlertDialog`), missing `TMDB_API_KEY` at boot (fail-fast per D29).

**P3:** Verify: stop server; try to save Add → expect `SnackBar` "Search failed." with an AlertDialog fall-through for retry. Disconnect DB query → expect `AlertDialog`.

**P4:** Per `02-architecture.md` §Error contract — repositories throw typed exceptions; providers surface them; UI maps to snackbars or dialogs.

**P5:** "Why does missing `TMDB_API_KEY` fail-fast?" — answer: I-14 + D29 — better to surface at boot than halfway through a search.

### Phase 6.7 — Optional integration test

**P1:** `integration_test` package; `IntegrationTestWidgetsFlutterBinding`.

**P2:** "What does this test cover that Phase 5 widget tests don't?" — answer: the actual run-time initialization path (provider graph, Drift initialization, TMDB API call if reachable).

**P3:** Create `integration_test/app_test.dart`:
```dart
testWidgets('open app → add movie → see on hub', (tester) async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  // pump the full app with a mock TMDB
  // search, save, verify HubCard count updated
});
```

**P4:** Integration tests are slower; mark as optional in §15.

**P5:** "Why optional?" — answer: per D14 §15; covers optional scope; not blocking v1 ship.

---

## Phase 7 — Wrap-up

### Done Definition (U9)
- `PROJECT_PLAN.md` documents v2 features + Supabase plan + migration plan — **but per v1-only scope, defer to redo of `05-phases.md` and `PROJECT_PLAN.md`**
- One retrospective on locked decisions vs. original hunches

### Phase 7.1 — Retrospective on locked decisions vs. hunches

**P1:** D-card review (per `08-decisions-log.md`).

**P2:** "Which D-card reflects the early hunch?" — answer: per Phase 7.1 review, the early hunch was "all media types in v1"; locked D-card refutes that.

**P3:** Walk `08-decisions-log.md` top-to-bottom; for each, note "original hunch vs. locked decision". Capture in `07-progress-tracker.md` (or in a sibling file).

**P4:** Self-reflective; no code changes.

**P5:** "Why now?" — answer: D14 + D-L13 — the canon of locked decisions is stable enough by Phase 7 to draw meaningful comparisons.

### Phase 7.2 — v2 handoff brief

**P1:** v1 → v2 transition scope per `08-decisions-log.md` (D12, D23–D27, D33 cascade full apply).

**P2:** "What does the v2 handoff brief include?" — answer: one-page summary of the v2 type set (per `08-decisions-log.md` D9 — 6 types), Supabase auth model (D12), mega-DB (D26), import pipeline (D25–D27), RAWG provider (D23–D24).

**P3:** Create `v2_handoff_brief.md` at the project root (or in `07-progress-tracker.md`); one page; lists D-cards relevant to v2.

**P4:** Not a code change; documentation only.

**P5:** "Why document the handoff before v1 ships?" — answer: the user knows what's deferred; v1 ships with the door ajar.

---

## Test Plan (§15 — v1 only)

Per the test-mirror rule, tests live next to the code they
cover. Test scope and line budgets per phase:

| Phase | Layer | Test scope | ~Lines |
|---|---|---|---|
| 1 | Widget | CataloguePage renders two HubCards; tap each navigates | ~20 |
| 3a | Drift repository | insert, query, delete, migration v1→v2, `findByTmdbId` returns existing row | ~50 |
| 4 | Riverpod providers | `moviesListProvider` reflects insert; `searchProvider` resolves; `filterProvider` set/clear | ~30 |
| 5 | Widget UI | HubCards render; Search Page 5-state flow; Media Filter; EditSheet prefill; Delete confirm | ~80 |
| 6 | Integration (optional) | "open app → add movie → see on hub" end-to-end | TBD |

Total v1 test budget: **~180 lines** (per `PROJECT_PLAN.md` §15).

Drift tests run on the host against `NativeDatabase.memory()`
(no emulator needed). Riverpod provider tests use
`ProviderContainer.test` (Riverpod 3). Widget tests use
`flutter_test`. Integration tests use `integration_test`.

---

## One-commit-per-phase (git workflow)

| Phase | Commit pattern |
|---|---|
| 0 | (none — pre-version-control) |
| 1 | `phase(1): static catalogue hub with hardcoded movies` |
| 2 | `phase(2): app shell with go_router and MediaSearchClient interface` |
| 3a | `phase(3a): add media_items table` |
| 3b | `phase(3b): add dio MediaSearchClient with TMDB` |
| 4 | `phase(4): wire Riverpod providers` |
| 5 | `phase(5): full CRUD UI with Search Page 5-state flow` |
| 6 | `phase(6): polish light+dark, accessibility, error states` |
| 7 | `phase(7): retrospective + v2 handoff brief` |

Branch per phase: `feat/<phase>-<short-name>` (per
`current_agent_docs_tutor/09-WORKFLOW.md` — git workflow in
`00-tutor-workflow-rules.md` §Git workflow).

Tag `v1.0` at the end of Phase 7 per `PROJECT_PLAN.md` §14 U9.

---

## Cross-references

- Architecture, layers, App Shell, theme wiring, invariants
  (I-1 through I-14): `02-architecture.md`
- Conventions, framework patterns, file organization,
  styling rules, the 9 codebase rules: `03-code-standards.md`
- Design tokens (color, typography, spacing, radius, motion),
  8 layout patterns, icon usage: `04-ui-context.md`
- Programming concepts with internet sources (per-step P1
  blocks; the agent uses `webfetch` / `websearch` for current
  sources)
- D-cards (locked decisions D1–D33), decision rationales:
  `08-decisions-log.md`
- Project framing (v1 surfaces, goals, glossary):
  `01-project-overview.md`
- Tutor's role & 5-step flow, Norms Ladder, git workflow:
  `00-tutor-workflow-rules.md`
- Session status (Phase 3a progress, open questions):
  `07-progress-tracker.md`
- Repo-root charter: `/AGENTS.md`
- For v2 phase slots (Community/Sharing/Supabase/Import),
  this file is **rewritten from scratch** when v2 work begins;
  source-of-truth is `PROJECT_PLAN.md` §18 (currently placeholder
  in this v1-only file).
