# 02 — Architecture

## TL;DR

Media Tracker is a layered Flutter app:

```
main → app → core/http → data → providers → features → shared
```

Each layer has one job and one direction of dependency. UI talks to data
through Riverpod providers; data talks to disk through Drift; HTTP talks
to TMDB through a single interface. **No layer imports the layer above it.**
The 14 invariants below codify the rules that keep this layered.

## The layers, in plain English

### `lib/main.dart` (entry point)

Owns: `runApp`, `ProviderScope`, app boot.
Does not own: business logic, persistence, HTTP.

One job: hand control to `app/`. About 10 lines.

### `lib/app/`

Owns: theme, router, app-level config.
Does not own: per-feature logic, HTTP calls, data access.

What lives here: `theme.dart` (the Material 3 `ThemeData`), `router.dart`
(Phase 2+, `go_router`), `secrets.dart` (gitignored; loads the TMDB API
key at boot).

### `lib/core/`

Owns: cross-cutting utilities.
Does not own: persistence, UI.

Cross-cutting means "used by more than one layer, but isn't a layer
itself." Example: `core/http/` is the only HTTP interface; nothing else
in the app imports `dio` directly.

### `lib/core/http/`

Owns: `MediaSearchClient` interface + Dio implementation + TMDB DTOs.
Does not own: drift types, Riverpod, widgets.

The single funnel for all TMDB calls. If you find yourself wanting to
import `dio` from `features/`, that's invariant I-5 territory — push it
through `MediaSearchClient` instead.

### `lib/data/`

Owns: drift `AppDatabase`, tables, DAOs, repositories, error types.
Does not own: UI, HTTP, Riverpod (repositories return plain values;
providers lift them).

Repositories are domain-facing methods like `MovieRepository.add(...)`.
They throw typed exceptions, not `Result<Error>` types.

### `lib/data/repositories/`

Owns: domain methods, idempotency checks.
Does not own: UI states, side-effects beyond the DB write.

Example: `MovieRepository.add` checks `findByTmdbId` first; if the row
exists, it throws `AlreadyInCollection`. The provider catches this and
surfaces it as a snackbar. The repository doesn't know what a snackbar is.

### `lib/features/`

Owns: per-feature UI (catalogue, add_movie, future explore, future
community).
Does not own: persistence, HTTP, drift types.

`features/` reads only through Riverpod providers. Never imports `drift`
or `dio`. This is invariant I-5 and I-6.

### `lib/providers/`

Owns: top-level Riverpod providers that bridge data and UI.
Does not own: widgets, drift DAOs, raw HTTP.

The glue layer. If a widget needs data, it asks a provider; if a provider
needs data, it asks a repository; if a repository needs data, it asks a
DAO or an HTTP client.

### `lib/shared/`

Owns: reusable widgets, helpers, extensions.
Does not own: anything feature-specific.

A `MovieCard` widget lives in `features/catalogue/`, not `shared/`,
because it's specific to that feature. A `Chip` widget with our spacing
tokens might live in `shared/` because it's reused.

### `test/`

Mirrors `lib/` 1:1:

```
test/data/             mirrors lib/data/
test/providers/        mirrors lib/providers/
test/features/<feat>/ mirrors lib/features/<feat>/
test/integration/      end-to-end (Phase 6, optional)
```

Drift tests run on the host against `NativeDatabase.memory()` — no
emulator needed. Riverpod provider tests use `ProviderContainer.test`.
Widget tests use `flutter_test` and pump widgets inside a `ProviderScope`.

## Boundary rules (and the invariants that enforce them)

| Rule | Enforced by |
|---|---|
| `data/` knows nothing about UI. | Code review (you + tutor). |
| `features/` knows nothing about HTTP — UI talks only to repositories via providers. | Invariant I-5 (no `dio` import in `lib/features/`). |
| `features/` knows nothing about drift — UI reads via providers. | Invariant I-6 (no `drift` import in `lib/features/`). |
| `core/http/` knows nothing about drift or features. | Code review. |
| `providers/` is the glue; nothing else crosses layers. | Code review. |

The four `import_lint` rules that previously enforced I-5, I-6, I-12 have
been **removed** from `analysis_options.yaml` for v1 (see
`07-TUTOR-PROTOCOL.md` §Learning-mode exceptions). The tutor enforces
them in chat per the Norms Ladder; you'll re-add the lint rules when you
re-add them to the analyzer config.

## The 14 invariants

Listed below roughly in the order you'll encounter them. Cross-reference:
the original production-style table lives in `agent_docs/architecture.md`
§"Invariants" if you want the more formal writeup.

### I-8 — No comments in code (RELAXED in v1)

The original rule: no `//` outside `lib/main.dart` and `*.g.dart`.

**Status in v1:** RELAXED. Comments are allowed throughout
`lib/**/*.dart`. See `07-TUTOR-PROTOCOL.md` §Norms Ladder.

**Re-tightens at:** v2 start (when CI scripts return).

**Why it existed in the first place:** production code review cleanliness.
For v1, learning takes priority.

### I-9 — Dependency versions pinned exactly (RELAXED in v1)

The original rule: no `^`, no `>=`, no `~` in `dependencies:` in
`pubspec.yaml`.

**Status in v1:** RELAXED. `flutter pub add <pkg>` writes caret ranges;
that's fine. Re-pin at v2 cleanup.

**Why it existed:** reproducible builds in CI. For v1, you're the only
consumer; the risk is your own dev experience.

### I-12 — Material imports via `package:flutter/material.dart`

Import material from the Flutter first-party package, not from
`package:material_ui/` (a future planned separate package).

**Enforcement today:** chat norm. The original `import_lint` rule was
removed in v1; you'll re-add it when v2 cleanup runs.

**Why it matters:** the migration to `material_ui` / `cupertino_ui` will
happen in one dedicated commit. Until then, every `import 'package:flutter/material.dart';`
in your code is forward-compatible.

### I-4 — New packages need a `PROJECT_PLAN.md` §16 row

Adding any third-party package to `pubspec.yaml` requires a corresponding
row in `PROJECT_PLAN.md` §16 documenting publisher, last-release age, and
reason.

**Enforcement today:** chat norm. The tutor will refuse to proceed if you
add a package without flagging the §16 row first.

**Why it matters:** prevents random transitive dependencies, surfaces
publisher-trust issues (a rule this project takes seriously — see D16
and D17).

### I-5 — No `dio` import under `lib/features/`

All TMDB calls go through `MediaSearchClient`. `lib/features/**/*.dart`
may not import `package:dio/...`.

**Enforcement today:** chat norm (lint rule removed for v1).

**Why it matters:** the `MediaSearchClient` interface is the seam where
v2 will swap the Dio implementation for a Supabase-backed one. Bypassing
it makes the swap impossible without rewriting `features/`.

### I-6 — No `drift` import under `lib/features/`

UI reads through Riverpod providers. `lib/features/**/*.dart` may not
import `package:drift/...`.

**Enforcement today:** chat norm.

**Why it matters:** the data layer is replaceable (drift today, possibly
something else tomorrow). Features shouldn't know about drift types.

### I-2 — `media_items.status` has exactly two values

`onWatchlist` and `inCollection` only. Free-form strings never reach the
column.

**Enforcement today:** drift's `EnumNameConverter<MediaStatus>` at the
column level + chat review.

**Why it matters:** the v2 enum has 5 states; v1's 2 is a strict subset.
A free-form string slipped into the column would silently corrupt v2's
expansion.

### I-3 — `media_items.type` is `MediaType.movie` only

In v1, every row in `media_items` has `type = 'movie'`.

**Enforcement today:** `EnumNameConverter<MediaType>` + chat review.

**Why it matters:** same as I-2. The column is `TEXT` (per D6) so widening
later is a zero-schema-change operation, but the converter keeps the
Dart-side invariant.

### I-7 — No `setState` for shared state in `lib/features/`

Local widget state is allowed (e.g., a checkbox inside a modal sheet).
Anything that drives another widget elsewhere goes through Riverpod.

**Enforcement today:** chat norm. Custom analyzer rule planned but not
implemented.

**Why it matters:** `setState` only re-renders the calling widget's
subtree. If state lives in two places (a widget's `setState` AND a
provider), they desync. v1 has no shared state yet, so this won't bite
early.

### I-13 — No `user_id` column on `media_items` in v1

Auth, multi-tenant logic, and per-user rows are deferred to v2.

**Enforcement today:** chat norm (the original `check_no_user_id.sh` CI
script has been deleted for v1; you'll re-write it at the earliest
meaningful point — see `07-TUTOR-PROTOCOL.md` §Norms Ladder).

**Why it matters:** the single-tenant posture is enforced by the schema
itself, not just by code. Adding `user_id` to v1's schema is the kind of
decision that belongs in `PROJECT_PLAN.md` §16 with explicit rationale.

### I-1 — No silent data loss

Every drift schema migration preserves existing user data. Each branch
in `MigrationStrategy.onUpgrade` has a sibling test using drift's
`SchemaVerifier`: open the prior schema, insert a row, run the migration,
reopen the new schema, assert the row is preserved.

**Enforcement today:** chat norm + the discipline of writing the test
alongside the migration.

**Why it matters:** the user's catalogue is the product. Losing a row is
the worst possible failure mode. This is the highest-priority invariant
on the Norms Ladder; you'll write its CI script early.

### I-11 — `MediaSearchClient.search` signature is locked

The signature `Future<List<MediaSearchResult>> search({required String query, required MediaType mediaType})`
is locked. v2 may add optional parameters; v1 forbids extending the
required set.

**Enforcement today:** chat norm (the original
`check_search_signature.sh` is whitespace-sensitive and has been
deleted; you'll re-write it at Phase 3b when the method is first
defined).

**Why it matters:** the interface is the contract between v1's UI and
v2's swap-to-Supabase backend. If the signature changes, both sides
break.

### I-14 — `TMDB_API_KEY` must be set at boot

Loaded from `lib/secrets.dart` (gitignored, dev) or `--dart-define=...`
(env, CI). Missing key fails fast at the `MediaSearchClient`
constructor before any TMDB call runs.

**Enforcement today:** code-side assert in the constructor.

**Why it matters:** without the key, the search path silently fails.
Failing fast at boot surfaces the deployment prerequisite where you can
fix it.

### I-10 — Tests live next to the code they cover

`test/data/` mirrors `lib/data/`, `test/features/<feat>/` mirrors
`lib/features/<feat>/`. The directory tree should be obvious.

**Enforcement today:** chat norm (the original `check_test_mirror.sh`
is deferred until Phase 3a when the first Drift test lands).

**Why it matters:** test-mirror makes grep work both ways — "where do I
test X?" answers itself.

## Storage

| What | Where | Lifetime |
|---|---|---|
| Movies the user has added | SQLite via Drift, `media_items` + `movie_details` tables | until uninstall |
| The SQLite file itself | `<app-docs>/media_tracker.sqlite` via `path_provider` | until uninstall |
| TMDB poster cache | disk via `flutter_cache_manager` | until OS evicts |
| TMDB search responses | in-memory Riverpod provider scope | until provider disposed |
| TMDB API key | `lib/secrets.dart` (gitignored) or env var | process lifetime |
| Drift codegen output | `lib/data/database.g.dart` | regenerated on schema change |

**What is NOT in v1:** cloud sync, secure-storage token cache,
encrypted-at-rest SQLite, backup, multi-device.

## Auth and access model

v1 has no auth, no account, no login screen, no logout. The "user" is
whoever owns the device. There is one local SQLite database; no row is
owned by anyone; there is no `user_id` column. See I-13.

v2 introduces Supabase Auth and adds `user_id` with RLS. Until then,
every read and write is unconditional.

## Error and response contract

Errors are typed exceptions thrown from the data or HTTP layer, caught
by the calling Riverpod provider, and surfaced in the UI as `SnackBar`
(transient, e.g., already-in-collection) or `AlertDialog` (recoverable,
e.g., save failed).

| Exception | Origin | Caught at | User sees |
|---|---|---|---|
| `AlreadyInCollection` | `MovieRepository.add` when `findByTmdbId` returns a row | `SearchRepository.translate` → `AddSheet` | `"Already in your Collection"` or `"Already on your To Consume list"` |
| `MediaSearchUnavailable` | `DioMediaSearchClient.search` on network failure / timeout / 5xx | `SearchPage` | Search page degrades to manual-entry form (no error shown) |
| drift `InvalidDataException` / `ConstraintViolationException` | drift itself | provider-level `try/catch`; surfaces to `AlertDialog` | generic message; logged at SEVERE |
| `MissingApiKeyException` | `DioMediaSearchClient` constructor if key not set | boot — fails fast before any TMDB call | `assert`-level error in dev; documented as deployment prerequisite |

**Contract:** repositories throw, not return `Result<Error>` types. HTTP
errors never surface raw `dio` exception types to UI.

## Concurrency and async model

- Dart single-threaded event loop on the main isolate.
- Drift queries run on a background isolate owned by `drift`; UI never
  blocks.
- Riverpod providers default to main-isolate computation.
- HTTP calls are async; cancellation via `CancelToken` if a SearchPage
  backs out mid-request.
- The codebase never mutates shared state. Riverpod's `Notifier.state`
  setters are the only place writes happen; widgets read.

## Cross-references

- Product framing, scope, success criteria, glossary: `01-PRODUCT.md`
- Stack decisions D1–D28: `03-STACK-DECISIONS.md`
- Per-step phase guide: `04-PHASE-GUIDE.md`
- UI tokens and components: `05-DESIGN-SYSTEM.md`
- Concepts reference: `06-CONCEPTS-AND-GLOSSARY.md`
- Tutor role, Norms Ladder, prompt templates: `07-TUTOR-PROTOCOL.md`
- Production-style architecture (kept for reference):
  `agent_docs/architecture.md`