# 03 — Code Standards

## TL;DR

This file is the **conventions reference** the tutor agent uses
to write code-review checklists and quiz questions. It absorbs
the 9 codebase rules (formerly PROJECT_PLAN §10). The D-card
decisions log (D1–D33) lives in `08-decisions-log.md` as a
separate file — this file references those D-cards by number
when it matters, but does not embed the card text.

Every rule here is graded for **enforcement** in three states:

- **CI-enforced** (a script catches it): the agent can trust the
  repo state and quiz on the rule's WHY.
- **Code-review-only** (the tutor checks code during P4 review):
  the agent reads user-supplied code and calls the violation.
- **Chat-only** (a design choice the agent just knows):
  the agent enforces during P2 quizzes.

For the tutor, the **enforcement column** is the cheat sheet —
when triaging a review or a quiz, look here first.

---

## 1. Dart language conventions

### 1.1 Formatting (CI-enforced: `dart format`)

`dart format` is mandatory. Run it before every commit.

- **Line length**: prefer ≤80 characters. `dart format` will
  reflow where it can; long string literals and URIs may exceed.
- **Curly braces**: required for all flow-control statements
  (even single-line `if` blocks) — avoids the dangling-else
  trap. Single-statement exception: `if (x == null) return
  defaultValue;` is fine.
- **Wildcards**: unused callback parameters use `_`. Dart 3.7+.

### 1.2 Naming

| Element | Convention | Example |
|---|---|---|
| Types (class, enum, typedef, extension) | `UpperCamelCase` | `MovieRepository`, `MediaStatus`, `ListExt` |
| Packages, directories, source files | `lowercase_with_underscores` | `lib/data/database.dart` |
| Import prefixes | `lowercase_with_underscores` | `import 'dart:math' as math;` |
| Other identifiers (variables, methods, parameters) | `lowerCamelCase` | `movieRepository`, `findByTmdbId(int tmdbId)` |
| Constants (compile-time `const`, enum values) | `lowerCamelCase` (NOT `SCREAMING_CAPS`) | `const defaultTimeout = 1000;` |
| Acronyms (>2 letters) | Capitalize like a word | `HttpRequest`, `Url`, `TmdbId` |
| 2-letter acronyms | All caps only when the source language does | `ID`, `TV`, `UI` stay caps; `Mr`, `Rd` are words |

### 1.3 Imports (CI-enforced: `directives_ordering`)

```
import 'dart:async';
import 'package:drift/drift.dart';
import 'package:flutter/material.dart';

import 'package:media_tracker/app/theme.dart';
import 'package:media_tracker/data/database.dart';

import '../core/http/media_search_client.dart';
```

- `dart:` imports first
- `package:` imports next (alphabetical)
- Relative imports last (alphabetical)
- `export` statements in a separate section after all imports

### 1.4 Comments (chat-only / relaxed v1)

**v1 exception**: comments are allowed throughout `lib/**/*.dart`.
This is invariant **I-8** (RELAXED in v1). Re-tighten at v2 start
by writing the `check_no_comments.sh` script (see
`00-tutor-workflow-rules.md` §"Norms Ladder").

| Use case | Convention |
|---|---|
| Doc comments (`///`) | Required for every public API and every class/library. Generated docs depend on them. |
| Inline (`//`) | Allowed v1; use sparingly to explain non-obvious behavior. |
| Block (`/* ... */`) | Reserved for generated files (`*.g.dart`). Don't hand-edit. |
| TODO/FIXME | Reference the relevant D-card or phase number, e.g., `// TODO(Phase 4): wire to Riverpod`. |

### 1.5 Naming cross-reference (`02-architecture.md` invariant I-2)

`MediaStatus.onBucketlist` and `MediaStatus.inCollection` are
the canonical status enum values. UI label is `"Bucketlist"`
(D-L13 / D33 in `08-decisions-log.md`). Tutor quizzes these by
name; the agent never types `MediaStatus.onWatchlist` or
`"To Consume"` or `"Bucket List"`.

---

## 2. File organization

### 2.1 Layer folders (mirroring `02-architecture.md` §Layer matrix)

```
lib/
├── main.dart                 ← Entry
├── app/                       ← Theme, router, secrets
├── core/                      ← Cross-cutting (ids, future utilities)
│   └── http/                 ← MediaSearchClient seam
├── data/                      ← Drift tables, DAOs, repositories
│   └── repositories/
├── providers/                 ← Riverpod glue
├── features/                  ← UI (no drift, no dio imports — I-5, I-6)
│   ├── catalogue/
│   └── search/               ← 5-state Search Page (Q8 file split)
│       ├── search_page.dart
│       ├── search_input_view.dart
│       ├── search_results_view.dart
│       ├── add_sheet_view.dart
│       ├── similar_titles_view.dart
│       └── confirm_selection_view.dart
└── shared/                    ← app_scaffold.dart, reusable widgets

test/                          ← Mirrors lib/, + test/integration/
```

### 2.2 One file per widget (chat-only)

- One public widget per file, named after the widget.
- Private widgets (those starting with `_`) can co-exist in the
  same file as their public owner, but only if they don't grow
  beyond ~30 lines.

### 2.3 Public surface vs. private impl (chat-only)

| Visibility | Use | Naming |
|---|---|---|
| `public` (no underscore) | Library API: pages, repos, providers, models | `SearchPage`, `MovieRepository` |
| `library-private` (leading `_`) | Internal helpers, sub-widgets, sub-state | `_SearchState`, `_MovieDaoImpl` |

`lib/features/` only sees public APIs from other layers. If you
find yourself importing `lib/data/movie_dao_impl.dart` from
`features/`, that's invariant **I-6** (no drift import in `features/`).

### 2.4 Tests mirror `lib/` (invariant I-10)

```
lib/data/database.dart          → test/data/database_test.dart
lib/features/search/.../        → test/features/search/.../
lib/providers/foo_provider.dart → test/providers/foo_provider_test.dart
```

The `test/` directory tree should be obvious by analogy.

### 2.5 Generated files (CI-enforced: gitignored + auto-regenerated)

Generated files are checked into `.gitignore` and regenerated by
build_runner:

- `*.g.dart` (drift + Riverpod codegen)
- `*.freezed.dart`
- `*.gr.dart`

Do not hand-edit. If the analyzer complains, run:

```bash
dart run build_runner build --delete-conflicting-outputs
```

---

## 3. Framework patterns

This section codifies how we use each framework in this codebase.
It is the answer to "is `FooProvider` or `FooNotifier` right?" and
similar architecture choices.

### 3.1 Drift (data layer; invariant I-1, I-2)

**Schema is the source of truth.** Tables are defined as Dart
classes extending `Table`, with column getters:

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

- **Plain TEXT for `type` and `status`** so widening the type
  set is a zero-schema-change operation (D6 in
  `08-decisions-log.md`).
- **`EnumNameConverter` at the column level** — enforces
  invariant I-2 (`status` 2 values) and I-3 (`type = movie` in
  v1) at the storage boundary.

**Database class** in `lib/data/database.dart`, with one table
per media type registered in `@DriftDatabase(tables: [...])`.
Migrations live in `MigrationStrategy`; see
`02-architecture.md` §Migrations for the stepByStep worked
example.

**DAOs live in `lib/data/daos/`.** They are typed query
objects that wrap the database access:

```dart
@DriftAccessor(tables: [MediaItems, MovieDetails])
class MovieDao extends DatabaseAccessor<AppDatabase>
    with _$MovieDaoMixin {
  Future<MovieWithDetails?> findByTmdbId(int tmdbId) =>
      (select(movieDetails)
        ..where((md) => md.tmdbId.equals(tmdbId)))
        .getSingleOrNull();
}
```

### 3.2 Riverpod 3 (state layer; invariant I-7)

**Code generation is used.** Riverpod 3's `@riverpod` syntax is
enabled project-wide. Reasons:

- One syntax for sync / async / stream providers
- Built-in autoDispose (matching our v1 single-tenant posture)
- Stateful hot-reload
- Eliminates the global-variable feel of older Provider syntax

Generate via:

```bash
dart run build_runner build --delete-conflicting-outputs
```

**Provider patterns:**

| Use case | Provider type | Class-based when | Function-based when |
|---|---|---|---|
| Read-only computed value | `@riverpod` | — | yes (default) |
| Mutation primitive | `@riverpodclass` extends `_$Foo` | yes | — |
| Async fetch (Future) | `@riverpodFuture` | yes | yes |
| Async stream | `@riverpodStream` | yes | yes |

**AutoDispose is the default.** `keepAlive: true` is reserved
for providers intentionally kept alive for the app's lifetime
(e.g., `databaseProvider`, `movieSearchClientProvider`).

**No globals.** Provider lookups via `ref.watch(...)` only. UI
never has a `lateinit var foo = SomeGlobal();` pattern.

### 3.3 `go_router` (routing; invariant I-12)

**Always `MaterialApp.router(...)`, never the
`MaterialApp(routerConfig: ...)` shortcut** — that shortcut
doesn't compile on Flutter 3.44.x (Phase 2 lesson log). The
dedicated `MaterialApp.router(...)` constructor is the only
entry point that wires a `GoRouter` (also see D29 in
`08-decisions-log.md`).

**Route shape**:

```dart
GoRoute(
  path: '/catalogue/collection',
  name: 'collection',
  builder: (context, state) => CollectionPage(
    filter: state.uri.queryParameters['genre'],
  ),
),
```

- Use `name: 'snake_case'` for `context.goNamed(...)` lookups.
- For list filters, prefer query parameters over path segments:
  `/catalogue/collection?genre=action` rather than
  `/catalogue/collection/genre/action`. Path segments should
  reflect resource identity (a single record); query strings
  reflect filters (a collection view).
- The Search Page lives at `/search?q=<query>&type=<mediaType>`
  — Q10 locked shape, forward-compatible with v2 widening
  (`type=movie` is the v1 default).

**Sub-routes for nested pages:**

```
/catalogue             → CataloguePage (hub)
/catalogue/collection  → CollectionPage (child)
/catalogue/bucketlist  → BucketlistPage (child)
```

Children share the parent's path prefix; `path.startsWith('/catalogue')`
lights up the "Catalogue" tab in the bottom nav (see
`00-tutor-workflow-rules.md` §Step-work for the active-tab
decision).

**`MaterialApp.router` parameters** (per `02-architecture.md`
§App Shell):

```dart
MaterialApp.router(
  title: 'Media Tracker',
  theme:        buildAppTheme(brightness: Brightness.light),
  darkTheme:    buildAppTheme(brightness: Brightness.dark),
  themeMode:    ThemeMode.system,                       // D-L2
  routerConfig: buildAppRouter(),
);
```

### 3.4 `dio` (HTTP; invariant I-5)

**`Dio` is wrapped behind `MediaSearchClient`.** Nothing in
`lib/features/` imports `package:dio/...`. The features layer
calls `MediaSearchClient.search(...)`; the implementation lives
in `lib/core/http/dio_media_search_client.dart`. See D9 in
`08-decisions-log.md`.

**Singleton per `MediaSearchClient` instance.** Reuse one client;
DI it via `MediaSearchClientProvider`.

**Interceptors:**

- **Auth/API-key**: injects `TMDB_API_KEY` (or v2 Supabase token)
  into every request.
- **Logging**: `LogInterceptor` in DEBUG mode only; never in
  release. Place LAST in the interceptor chain so downstream
  modifications are logged.

**Error mapping.** Network errors surface as typed domain
exceptions (`MediaSearchUnavailable`) at the client seam, not
as raw `DioException` at the UI. See `02-architecture.md`
§Error contract.

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
      final res = await _dio.get<dynamic>(
        _pathFor(mediaType),
        queryParameters: {'query': query, 'api_key': _apiKey()},
      );
      return (res.data['results'] as List)
          .map((j) => MediaSearchResult.fromJson(j))
          .toList();
    } on DioException catch (e) {
      throw MediaSearchUnavailable(cause: e);
    }
  }
}
```

### 3.5 `MaterialApp` + theme (UI shell; invariant I-12)

- `MaterialApp.router` is the one and only entry (Section 3.3
  above).
- Both light and dark themes are derived from a single seed
  color via `ColorScheme.fromSeed(seedColor: …, brightness:
  Brightness.light/dark)` (D10, D19 in `08-decisions-log.md`).
  `themeMode: ThemeMode.system` lets the OS toggle decide
  (D-L2).
- Don't hand-write a custom `ThemeData`; compose from
  `ColorScheme.fromSeed` + the M3 type scale + the spacing tokens
  in `04-ui-context.md`.

### 3.6 Drift + background isolate (invariant I-1, I-12)

`AppDatabase` is constructed with `driftDatabase(name: …, native:
DriftNativeOptions(databaseDirectory: ...))` from
`package:drift_flutter`. Queries stream back to the main
isolate. The user's main thread never blocks on SQL (see
`02-architecture.md` §Concurrency and async model).

---

## 4. API route structure (TMDB + v2 Supabase)

The HTTP layer is gated through `MediaSearchClient`; this
section codifies the URL shapes it implements.

### 4.1 Route table (TMDB v3, Movies in v1)

| Resource | Endpoint | Method | When called | Auth |
|---|---|---|---|---|
| Search movies | `/search/movie` | GET | Search Page State B | query param `api_key` |
| Movie detail | `/movie/{id}` | GET | Future: movie-detail expand | query param `api_key` |
| Movie similar | `/movie/{id}/similar` | GET | Search Page State D | query param `api_key` |
| Movie poster (image) | `image.tmdb.org/t/p/{size}/{path}` | GET | Poster render via `flutter_cache_manager` | None (image CDN) |
| (v2 TV Shows) | `/search/tv` | GET | Phase 3b widens `MediaType` | query param `api_key` |
| (v2 Books) | Open Library `/search.json` | GET | v2 import pipeline | None (authless) |
| (v2 Video Games) | RAWG `/api/games` | GET | v2 Game detail & search | query param `key=` |
| (v2 Anime) | AniList GraphQL | POST | v2 Anime detail & search | None (keyless) |
| (v2 Comics) | Comic Vine `/api/{resource}/` | GET | v2 Comic detail & search | query param `api_key` (TBD) |

All TMDB responses go through `MediaSearchResult.fromJson(...)`
to strip aliases. No raw `dio` types surface past the
`MediaSearchClient` boundary.

### 4.2 Headers, query params, body shapes

- All TMDB requests: `Accept: application/json`,
  `api_key=<key>` (or `Authorization: Bearer <token>` in v2).
- No request body for GET; POST (AniList GraphQL) takes a
  GraphQL `query` + `variables` JSON body.
- Pagination via `page` query param (TMDB) or `limit/offset`
  (RAWG). `MediaSearchClient.search` accepts one page at a
  time; pagination is the v2+ concern.

### 4.3 v2 widening path

`MediaSearchClient.search({required String query, required
MediaType mediaType})` is the locked signature (I-11 in
`02-architecture.md`; D-card D-canonical-search-signature
in `08-decisions-log.md`). v2 widens the supported `MediaType`
values and may add optional parameters (e.g., `page`,
`language`). v1 forbids extending the required set.

---

## 5. Styling rules

UI styling rules live in `04-ui-context.md` (design tokens,
component inventory, layout patterns). This section only
captures the conventions the tutor enforces during code review
(visible in `lib/`).

### 5.1 Color (code-review-only)

- Read colors via `Theme.of(context).colorScheme.<token>`, never
  hardcode hex values inline.
- The seed color is defined exactly once, in
  `lib/app/theme.dart`'s `buildAppTheme()`. Both palettes derive
  from it.

### 5.2 Typography (code-review-only)

- Use `Theme.of(context).textTheme.<role>` to read tokens.
- Movie titles in `MovieCard` use display/headline weight
  (Source Serif 4).
- Body / label / title use Inter via `google_fonts`.

### 5.3 Spacing (code-review-only)

- 8 px grid: 4 / 8 / 16 / 24 dp tokens (`space/xxs`, `xs`, `sm`,
  `md`, `lg`). 2 dp is the sub-grid escape hatch.
- Cards: 12 dp inner padding, 16 dp gap to neighbors.
- Page margins: 24 dp.

### 5.4 Border radius (code-review-only)

| Context | Token | Value |
|---|---|---|
| `Chip`, `SnackBar`, small `FilledButton` | `radius/sm` | 8 dp |
| `Card` (MovieCard, HubCard), `ListTile`, `TextField` | `radius/md` | 12 dp |
| `AlertDialog`, `ModalBottomSheet` (EditSheet, Media Filter) | `radius/lg` | 20 dp |
| `FloatingActionButton`, `IconButton`, pill-shaped buttons | `radius/full` | 9999 dp |

### 5.5 Icons (code-review-only; invariant I-7)

- Use `Material Symbols Rounded` exclusively. The font is bundled
  at `assets/fonts/MaterialSymbolsRounded.ttf` (**Apache License
  2.0**; D17 in `08-decisions-log.md`).
- Reference icons via
  `IconData(fontFamily: 'MaterialSymbolsRounded', fontPackage: 'media_tracker')`.
- No emoji as UI affordance. No Unicode glyphs as Icons. No
  `Icons.add` (legacy Material Icons set).

### 5.6 Motion (code-review-only)

- Three tokens: `motion/fast` (150 ms, button ripple),
  `motion/default` (250 ms, page transitions),
  `motion/slow` (400 ms, hero animations).
- Honor `MediaQuery.disableAnimations` (OS "reduce motion"):
  substitute `Duration.zero` for `motion/default` and
  `motion/slow`; keep `motion/fast` so button ripples still feel
  responsive.

### 5.7 Accessibility (code-review-only; see `01-project-overview.md` §Non-functional)

- All interactive elements get a `Semantics(label: "...")`.
- Minimum 48 dp touch targets (`a11y/touch-target/min`).
- Color contrast ≥ 4.5:1 for body text (WCAG 2.2 AA).

---

## 6. The 9 codebase rules (formerly PROJECT_PLAN §10; absorbed)

These are the developer-side rules. Each maps to one or more
invariants in `02-architecture.md` §14 invariants and (where
applicable) a D-card in `08-decisions-log.md`.

### 6.1 No silent data loss → I-1
Drift migrations must preserve existing user data. Each migration
step has a sibling `SchemaVerifier` test. (Rationale: D13 in
`08-decisions-log.md`.)

### 6.2 Status enum is the locked 2 states → I-2
v1 ships `MediaStatus.onBucketlist` and `inCollection` only.
`MediaStatus.onCollabLists` does not appear anywhere in v1. The
other 3 states land in v2 with the detail/edit sheet that
surfaces them. (Canonicalization: D7, D20, D33 in
`08-decisions-log.md`.)

### 6.3 Type-safe enums only at the boundary → I-2, I-3
`media_items.type` and `.status` are plain TEXT in storage, but
every write path goes through the value-object enums. Drift's
`EnumNameConverter` is wired at the column level — no free-form
strings reach SQLite. (Rationale: D6 in `08-decisions-log.md`.)

### 6.4 One commit per phase
(or per sub-phase when a phase contains two independent concerns —
Phase 3a / 3b). The Done Definition is the commit boundary.

### 6.5 Pinned dependency versions (relaxed v1) → I-9
No `^` or `>=` in `pubspec.yaml` — only exact pins. **Relaxed v1**:
`flutter pub add <pkg>` writes caret ranges; that's fine. Re-pin at
v2 cleanup.

### 6.6 Official packages only → I-7
No unverified third-party packages. Concrete exceptions and
reasons are tracked in `08-decisions-log.md` (D16, D17, D18,
D23, D30, D31, D32).

### 6.7 `MediaSearchClient` is the only call site for TMDB → I-5
No `dio` imports inside `features/`. The v2 swap to a regenerated
client touches the impl only. (Rationale: D9 in
`08-decisions-log.md`.)

### 6.8 Widgets never import Drift directly → I-6
UI reads from Riverpod providers; providers read from
repositories; repositories read from DAOs.

### 6.9 No `setState` for shared state → I-7
Local UI state is fine; anything that drives another widget
elsewhere goes through Riverpod.

---

## Cross-references

- Architecture, layers, invariants: `02-architecture.md`
- Design tokens (color, typography, spacing, components):
  `04-ui-context.md`
- Phase numbering, Done Definitions, per-step 5-sub-block
  templates: `05-phases.md`
- Programming concepts (agent uses `webfetch` /
  `websearch` for current sources)
- Project framing, success criteria, glossary:
  `01-project-overview.md`
- Tutor's role & 5-step flow, Norms Ladder, git workflow:
  `00-tutor-workflow-rules.md`
- Session status: `07-progress-tracker.md`
- **D-cards (locked decisions D1–D33, full rationale): `08-decisions-log.md`**
- Repo-root charter: `/AGENTS.md`
