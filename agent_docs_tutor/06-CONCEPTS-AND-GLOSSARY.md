# 06 — Concepts and Glossary

This file is your **post-hoc reference index**. The tutor pulls slices
from here during the per-step prerequisite check
(`04-PHASE-GUIDE.md`). You also correct entries here when the tutor
gets something wrong — that's the self-correcting loop the project runs
on.

Read order: don't read this top-to-bottom. Skim the table of contents;
deep-read a lesson when the tutor points you at it.

## Mini-lessons

### 1. Material 3 — `ThemeData`, `ColorScheme`, and `ColorScheme.fromSeed`

**Concept.** Material 3 unifies theming under `ThemeData`. A
`ColorScheme` is the structured palette (`primary`, `secondary`, `surface`,
`error`, etc.); `TextTheme` is the typography scale; `IconTheme` is icon
defaults. You build a `ThemeData` once at app start and `MaterialApp`
injects it into every descendant widget.

`ColorScheme.fromSeed(seedColor: X, brightness: Brightness.dark)` derives
all 25+ palette tokens from one seed. v1's `lib/app/theme.dart` calls
this twice — once for dark (shipped), once for light (derived but
unused; D19).

**In code:**

```dart
final theme = ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF6B7FE0),  // sapphire
    brightness: Brightness.dark,
  ),
  textTheme: Typography.material2021().black.apply(
    fontFamily: 'Inter',  // or google_fonts inter
  ),
  useMaterial3: true,
);

MaterialApp(
  theme: theme,
  home: ...,
);
```

**Try this yourself.** Open a Flutter sample, set `seedColor` to three
different values, run the app. Notice how every component (FAB, button,
chip, badge) shifts palette while staying readable.

### 2. Widget tree — `BuildContext`, parents, descendants

**Concept.** Every Flutter widget returns a tree. `BuildContext` is the
"where am I in the tree" handle passed to every `build` method. Widgets
above you in the tree can be looked up via `Theme.of(context)`,
`MediaQuery.of(context)`, `Navigator.of(context)`, etc.

Inherited widgets (Theme, MediaQuery, ProviderScope, Localizations) ride
the tree. They propagate data without prop-drilling.

**The mental model.** If you've used React, Flutter is the same
mental model with stricter rules: every widget must be `const` if it
doesn't take runtime data, and rebuilds are explicit (the framework
calls `build` on widgets whose inputs changed).

**Try this yourself.** Add a `Theme.of(context).colorScheme.primary`
inside a deeply-nested widget. It works because `MaterialApp` is above
it. Now remove `MaterialApp`. The build fails with
"InheritedWidget not found."

### 3. `async` / `await` and `Future<T>`

**Concept.** Dart is single-threaded. `async` functions return a
`Future<T>` — a "promise" of a value that arrives later. `await` waits
for the future to complete without blocking the event loop.

```dart
Future<int> computeAnswer() async {
  await Future.delayed(Duration(seconds: 1));
  return 42;
}
```

Use `await` for: HTTP calls, DB queries, file I/O, anything that takes
time. Don't use it for synchronous CPU work.

**Try this yourself.** Write a function `Future<String> fetchGreeting()`
that returns `"Hello, ${name}!"` after a 500ms delay. Print the result
from `main()`. Notice that `main()` itself must be `async` if it `await`s.

### 4. Streams vs. Futures — and why drift uses streams

**Concept.** A `Future<T>` resolves once. A `Stream<T>` emits multiple
values over time. Drift returns rows from the DB as a `Stream<List<Row>>`
because the DB is reactive — when a row changes, the stream re-emits.

**When to use which:**
- `Future` for one-shot async work (HTTP GET, DB insert, file read).
- `Stream` for "subscribe to changes" (DB row watch, WebSocket, file
  watch).

In Riverpod 3, a provider returning a `Future<T>` becomes a
`FutureProvider`; one returning a `Stream<T>` becomes a `StreamProvider`.
Drift's `watch` method returns a `Stream` you wrap in a provider.

**Try this yourself.** Drift query: `(select(mediaItems)).watch()` —
returns `Stream<List<MediaItem>>`. Wrap in a `StreamProvider`. Watch the
list re-render when you insert a row from another provider.

### 5. Riverpod 3 — `ProviderScope`, `Provider`, `Notifier`, `AsyncNotifier`

**Concept.** Riverpod replaces `Provider`/`StateNotifierProvider` from v2
with a single, simpler model in v3. The hierarchy:

- **`ProviderScope`** — top-level widget that owns all providers. Set up
  in `main.dart` once. Children can read providers.
- **`Provider<T>`** — read-only computed value. Like a `Stream` exposed
  as a `T`.
- **`Notifier<State>`** — class with a `build()` method returning the
  initial state, plus methods that mutate `state`.
- **`AsyncNotifier<State>`** — same as `Notifier`, but `build()` returns
  a `Future<State>` (or `Stream<State>`). Use it for anything async
  (DB queries, HTTP).

**The mental model.** Think of providers as global variables that
re-render only the widgets that read them, and that have a well-defined
lifecycle (auto-disposed when no one reads).

**Try this yourself.** Create `class Counter extends Notifier<int> {
@override int build() => 0; void increment() => state++; }`. Wrap in
`NotifierProvider<Counter, int>(Counter.new)`. In a widget, `ref.watch(counterProvider)`
and a `FloatingActionButton(onPressed: counter.notifier.increment)`.

### 6. Drift — tables, DAOs, repositories

**Concept.** Drift is a Dart ORM over SQLite. You define tables as Dart
classes, then `build_runner` generates the SQL and the typed query API.

- **Table** — `@DataClassName('MediaItem') class MediaItems extends Table { IntColumn get id => integer().autoIncrement()(); TextColumn get title => text()(); }`.
- **Database** — `@DriftDatabase(tables: [MediaItems]) class
  AppDatabase extends _$AppDatabase { ... }`. The `_$AppDatabase` is
  generated.
- **DAO** — `@DriftAccessor(tables: [MediaItems]) class MediaDao extends
  DatabaseAccessor<AppDatabase> with _$MediaDaoMixin { Future<List<MediaItem>> all() => select(mediaItems).get(); }`.
- **Repository** — Dart class that wraps one or more DAOs and exposes
  domain methods like `add`, `findByTmdbId`, `delete`. Repositories
  throw typed exceptions; providers handle them.

**Try this yourself.** After generating the database, write
`MovieRepository(AppDatabase db)` with one method `Future<List<MediaItem>> all() => _db.mediaDao.all();`
and a test in `test/data/movie_repository_test.dart`.

### 7. Codegen — `build_runner`, `drift_dev`, `*.g.dart`

**Concept.** Drift's table definitions are missing the SQL generation
and the typed query layer. You run `dart run build_runner build
--delete-conflicting-outputs` once per schema change. The generator
writes `lib/data/database.g.dart`, which contains `_$AppDatabase`,
`_$MediaDaoMixin`, the typed `MediaItem` data class, and the
`EnumNameConverter`s.

The `.g.dart` file is **never hand-edited** — if you change it, the
next `build_runner` run overwrites your changes.

**Try this yourself.** After defining `MediaItems` table, run
`build_runner build`. Look at `database.g.dart`. Notice the `MediaItem`
data class with its `copyWith` method (D11) and the typed
`MediaItemsCompanion` for inserts.

### 8. Drift migrations — additive, with a preservation test

**Concept.** When you change the schema (add a column, add a table),
you add a migration step in `MigrationStrategy.onUpgrade`. Drift's
`MigrationStrategy` runs branches per schema version:

```dart
migration: MigrationStrategy(
  onUpgrade: (m, from, to) async {
    if (from < 2) {
      await m.addColumn(mediaItems, mediaItems.rating);
    }
    if (from < 3) {
      await m.createTable(movieDetails);
    }
  },
)
```

**The discipline (invariant I-1):** for every branch, write a sibling
test using drift's `SchemaVerifier`:

```dart
test('migration from v1 to v2 preserves rows', () async {
  final verifier = SchemaVerifier(Schema(1));
  // open v1 schema, insert row, run migration, assert row still present
});
```

The test proves that a user upgrading from an older version doesn't lose
their catalogue. See I-1.

### 9. `MaterialApp` + `Scaffold` + `Theme.of(context)` — the standard trio

**Concept.** Every Flutter app's outermost widget is `MaterialApp`. It
injects the theme, locale, and navigator into the tree. Its `home:` is
the first screen.

`Scaffold` is the visual frame for a screen: app bar, body, FAB,
drawer. Use it on every page.

Inside any descendant widget, `Theme.of(context)` returns the current
`ThemeData`. This is how you read tokens without hardcoding them:

```dart
Container(
  color: Theme.of(context).colorScheme.surface,  // color/surface
  padding: const EdgeInsets.all(16),              // space/md
  child: Text('Hello', style: Theme.of(context).textTheme.bodyLarge),
)
```

**Try this yourself.** Build a screen with a `Scaffold` whose `body` is
a `Container` painted with `color/primary`. Then swap to
`color/secondary`. Notice how the Container and its descendants
(inherited text color) shift without any other change.

### 10. Errors — typed exceptions vs. `Result<Error>`

**Concept.** Dart has no checked exceptions. Repositories throw typed
exceptions (`AlreadyInCollection`, `MediaSearchUnavailable`,
`MissingApiKeyException`); providers `try/catch` and surface the error
to UI as `AsyncValue.error` or `SnackBar`/`AlertDialog`.

We **don't** use `Result<T, E>` types because:
1. The Dart ecosystem doesn't have a standard `Result`.
2. Riverpod's `AsyncValue<T>` already encodes error states cleanly.
3. Stack traces from thrown exceptions are easier to debug than
   wrapped errors.

The provider layer is the boundary between "throw" and "surface." Below
the provider, exceptions fly. Above it, the UI sees `AsyncValue.error`.

**Try this yourself.** Throw `AlreadyInCollection()` from
`MovieRepository.add` when `findByTmdbId` returns a row. Catch in the
provider with `try/catch`. Surface as a `SnackBar` with the message
"Already in your Collection."

---

## Glossary (quick lookup)

| Term | Meaning |
|---|---|
| `BuildContext` | Handle to a widget's position in the tree. |
| `Future<T>` | A value that arrives later. One-shot. |
| `Stream<T>` | A series of values over time. |
| `async` / `await` | Mark a function as asynchronous; wait for a future without blocking. |
| `Provider` (Riverpod) | A read-only computed value exposed to the tree. |
| `Notifier<State>` (Riverpod 3) | Class with `build()` + `state` setter. The v3 way to model mutable state. |
| `AsyncNotifier<State>` (Riverpod 3) | Notifier whose `build()` returns a `Future` or `Stream`. |
| `ProviderScope` | The widget that owns all providers. Wrap `runApp`. |
| `ProviderContainer.test` (Riverpod 3) | Test primitive — create a container, read/write providers, no widget tree. |
| `Table` (drift) | Dart class defining a SQLite table's columns. |
| `DAO` (drift) | `DatabaseAccessor` mixin with typed query methods. |
| `Repository` (drift pattern) | Domain wrapper around one or more DAOs. Throws typed exceptions. |
| `build_runner` | Code-generation tool. Run once per schema/table change. |
| `*.g.dart` | Generated file. Never hand-edit; regenerated by `build_runner`. |
| `SchemaVerifier` (drift) | Test helper that opens a prior schema, runs migrations, asserts preservation. |
| `MediaSearchClient` | Interface for TMDB search; implementation in `lib/core/http/`. |
| `DioMediaSearchClient` | The `dio`-backed implementation; swappable in v2. |
| `MediaSearchResult` | Cross-type envelope DTO returned from TMDB. |
| `MediaType` | Enum. v1 has only `MediaType.movie`. |
| `MediaStatus` | Enum. v1 has `onWatchlist` and `inCollection`. |
| `HubCard` | Big card on the Catalogue hub. Two in v1. |
| `AddSheet` / `EditSheet` | Modal bottom sheet for adding or editing one movie. |
| `themeMode` | `ThemeMode.dark` / `light` / `system`. v1 pins `dark`. |
| `ColorScheme.fromSeed` | Material 3 helper that derives a full palette from one seed color. |
| `Semantics` widget | Wraps a UI element with a TalkBack-readable label. |
| `CancelToken` (dio) | Pass to a Dio request to cancel it mid-flight. |
| `NativeDatabase.memory()` (drift) | In-memory SQLite for tests. No emulator needed. |

## Cross-references

- Architecture and invariants: `02-ARCHITECTURE.md`
- Stack decisions: `03-STACK-DECISIONS.md`
- Design tokens: `05-DESIGN-SYSTEM.md`
- Tutor role: `07-TUTOR-PROTOCOL.md`