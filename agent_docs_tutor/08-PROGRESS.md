# 08 — Progress

This file is your day-to-day status. The tutor reads it at session
start (to know where you are) and you update it at session close
(completed work, blockers, session notes).

This file is the single source of truth for "where am I right now." If
you're not sure what phase you're on, look here.

## Current Phase

- Phase 2

## Current Goal

- Phase 2 implementation closed (commit + PR pending). Next: end-of-phase recap quiz, then Phase 3a.

## Completed

- Phase 1 deliverables (7 source files + supporting infra):
  - `lib/app/theme.dart` — `buildAppTheme()` dark `Material 3`.
  - `lib/features/catalogue/data/movie.dart` — `Movie` value object.
  - `lib/features/catalogue/data/movie_status.dart` — `MediaStatus` enum.
  - `lib/features/catalogue/data/sample_movies.dart` — 5 const entries + `collectedMovies` / `bucketListMovies` getters.
  - `lib/features/catalogue/widgets/movie_card.dart` — `Card` + `ListTile` + status pill.
  - `lib/features/catalogue/widgets/hub_card.dart` — `Card` + `Stack` + `Positioned.fill(leading)` + centered label.
  - `lib/features/catalogue/my_collection_page.dart` — list page.
  - `lib/features/catalogue/bucket_list_page.dart` — list page (renamed from `to_consume_page.dart`).
  - `lib/features/catalogue/catalogue_page.dart` — hub layout.
  - `lib/main.dart` — rewritten: `runApp` + `MaterialApp(theme: buildAppTheme(), home: const CataloguePage())`.
  - `pubspec.yaml` — asset entries for `collection_Button.jpeg` + `bucketlist_Button.jpg`.
  - `test/widget_test.dart` — deleted (counter-app default test no longer relevant).

- Phase 2 deliverables (5 new source files + 1 modified + supporting infra):
  - `lib/core/http/media_type.dart` — `MediaType` enum (single value `movie` in v1 per D28; widens in v2).
  - `lib/core/http/media_search_result.dart` — placeholder DTO (`tmdbId`, `title`, `year`, `posterUrl`).
  - `lib/core/http/errors.dart` — `MediaSearchUnavailable` exception (impl lands in Phase 3b).
  - `lib/core/http/media_search_client.dart` — abstract interface per I-11.
  - `lib/app/router.dart` — `buildAppRouter()` factory returning a single-route GoRouter.
  - `lib/main.dart` — `MaterialApp.router(routerConfig: buildAppRouter())` wiring.
  - `pubspec.yaml` + `pubspec.lock` — `go_router 17.3.0` + transitive `logging 1.3.0`.
  - `PROJECT_PLAN.md` §16 D29 — `go_router` row per I-4.
  - `lib/data/movie.dart` + `lib/data/movie_status.dart` — moved from `lib/features/catalogue/data/` (pre-emptive data-layer relocation; honors I-5/I-6 boundary before Phase 3a).
  - `test/features/catalogue/catalogue_page_test.dart` — widget test for the catalogue page.

## In Progress

- End-of-phase recap quiz (6 questions on invariants + D-cards touched in Phase 2).

## Next Up

- Phase 3a — Drift data model (per `04-PHASE-GUIDE.md` §13 row 3a; populate from `PROJECT_PLAN.md` §13 + §14 U3 when Phase 3a begins).

## Open Questions

- Text-on-image visibility: the centered label on `HubCard` is small (no explicit `style:`) and may visually drift toward the image's dominant subject; fix proposed (add `headlineSmall` style + optional translucent backdrop) but not yet applied. *Carried over from Phase 1.*
- `CataloguePage` drift: `floatingActionButton` absent, `appBar` present — both diverge from `05` §9 "Hub page" pattern. User-accepted; revisit in v1.1 polish. *Carried over from Phase 1.*
- `PROJECT_PLAN.md` §14 U2 row references `ToConsumePage` / `'To Consume'`; the shipped code uses `BucketListPage` / `'Bucket List'`. The plan row is stale relative to the shipped state. *Carried over from Phase 1.*
- `MaterialApp(routerConfig: ...)` doesn't compile on Flutter 3.44.5 (Phase 2): the main `MaterialApp(...)` constructor doesn't accept `routerConfig:` as a parameter — only initializes it to null. The dedicated `MaterialApp.router(...)` constructor is the only entry point. Workaround applied. This contradicts the locked Phase 2 plan ("`MaterialApp(routerConfig: buildAppRouter())`"); the architecture doc needs updating to note `MaterialApp.router` is the canonical path, not the main constructor's `routerConfig:` parameter.
- The `lib/data/` relocation landed in the Phase 2 commit but is technically pre-Phase-2 work (Phase 3a is when the data layer formally exists). Not blocking.

## Architecture Decisions

- None yet. (Decisions live in `PROJECT_PLAN.md` §16 / `03-STACK-DECISIONS.md`.)

## Session Notes

### Session 1 — 2026-07-16 — Phase 1 implementation closed

- Built the static catalogue hub end-to-end across 5 sub-steps (1.1
  theme + main, 1.2 Movie + MediaStatus, 1.3 sample data, 1.4
  MovieCard, 1.5 HubCard + pages + main rewrite).
- Mid-phase amendment: HubCard grew a `Widget? leading` slot driven
  by an asset image on each HubCard invocation in `CataloguePage`;
  the `ToConsumePage` / `toConsumeMovies` / `'To Consume'` naming
  was renamed to `BucketListPage` / `bucketListMovies` / `'Bucket
  List'` per user direction. `MediaStatus.onWatchlist` enum
  unchanged.
- Prereq quizzes skipped for all of Phase 1 per user decision;
  post-code review only. Quiz-with-after-the-fact grading worked.
- Open drift: `CataloguePage` has no `floatingActionButton` (drift
  from `05` §9 hub pattern) and has an `appBar` (also drift).
  Both user-accepted; not blocking Phase 1.
- 6-question end-of-phase recap quiz scheduled at session close.

### Session 2 — 2026-07-22 — Phase 2 implementation closed

- Built the app shell across 4 sub-steps (2.1 deps + supporting
  types, 2.2 abstract interface, 2.3 GoRouter config, 2.4 main.dart
  wire).
- Pre-Phase-2 cleanup rolled into the Phase 2 commit: data layer
  moved from `lib/features/catalogue/data/` to `lib/data/`; widget
  test added for the catalogue page; AGENTS.md gained an
  explicit "Do Exactly what the user specifies" rule.
- Locked `MediaSearchClient.search` signature per I-11:
  `Future<List<MediaSearchResult>> search({required String query,
  required MediaType mediaType})`.
- Diagnosis moment: `MaterialApp(routerConfig: ...)` doesn't
  compile on Flutter 3.44.5 because the main `MaterialApp(...)`
  constructor doesn't accept `routerConfig:` as a parameter (only
  initializes it to null). Switched to `MaterialApp.router(...)`.
- Re-introduced prerequisite quizzes mid-Phase-2 per user request;
  pedagogy now uses pre-step quizzes + post-code review (Q1: why
  `MaterialApp(routerConfig:)` not `MaterialApp.router(...)`; Q2:
  GoRouter is-an `RouterConfig`; Q3: Navigator.push still works
  after wiring — user got Q1+Q2 right, Q3 inverted).
- Open drift carried forward from Phase 1: FAB absent, AppBar
  present on CataloguePage.
- 6-question end-of-phase recap quiz scheduled at session close.

## Norms Ladder (mirror of `07-TUTOR-PROTOCOL.md`)

| Invariant | Current state | Last touched | Notes |
|---|---|---|---|
| I-1 | Coached | — | first schema change pending |
| I-2 | Habitual | 2026-07-16 | 5+ correct `MediaStatus` references in Phase 1, no string-typed status |
| I-3 | Coached | — | same as I-2; relevant once `media_items` exists |
| I-4 | Habitual | 2026-07-22 | §16 D29 row added for `go_router` before `flutter pub add` (per I-4) |
| I-5 | Habitual | 2026-07-16 | zero `dio` imports in `features/` Phase 1 |
| I-6 | Habitual | 2026-07-16 | zero `drift` imports in `features/` Phase 1 |
| I-7 | Habitual | 2026-07-16 | all widgets `StatelessWidget` Phase 1, no `setState` |
| I-8 | Coached (relaxed) | — | v1-wide exception |
| I-9 | Coached (relaxed) | — | v1-wide exception |
| I-10 | Coached | — | deferred until first drift test |
| I-11 | Habitual | 2026-07-22 | `MediaSearchClient.search` signature matches the locked I-11 form character-for-character in Phase 2 |
| I-12 | Habitual | 2026-07-16 | every Material import via `package:flutter/material.dart` Phase 1 |
| I-13 | Coached | — | always relevant |
| I-14 | Coached | — | relevant at TMDB integration |

The tutor updates this table at session close.

## Doc-gardening trigger

Run before opening any PR that modifies a rule-bearing context file
(`02-ARCHITECTURE.md`, `05-DESIGN-SYSTEM.md`, `06-CONCEPTS-AND-GLOSSARY.md`,
`07-TUTOR-PROTOCOL.md`):

1. Re-read the section the PR touches.
2. New dependency landed → surface: "`PROJECT_PLAN.md` §16 needs a row
   for `<package>` per invariant I-4." The user writes the row.
3. New invariant emerged → propose: a §16 row, an architecture.md
   invariant row, a CI script (or `import_lint` rule), and an
   `analysis_options.yaml` rule. User approves; tutor implements after
   explicit go-ahead.
4. Done Definition satisfied → confirm with the user; user marks it
   complete in `PROJECT_PLAN.md`.

## Cross-references

- What's next: `04-PHASE-GUIDE.md` (phase slots)
- Tutor session protocol: `07-TUTOR-PROTOCOL.md`
- Tutor charter: `AGENTS.md` (auto-loaded)