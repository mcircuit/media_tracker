# 08 — Progress

This file is your day-to-day status. The tutor reads it at session
start (to know where you are) and you update it at session close
(completed work, blockers, session notes).

This file is the single source of truth for "where am I right now." If
you're not sure what phase you're on, look here.

## Current Phase

- Phase 1

## Current Goal

- Phase 1 implementation closed (commit + PR pending). Next: end-of-phase recap quiz, then Phase 2.

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

## In Progress

- End-of-phase recap quiz (6 questions on invariants + D-cards touched in Phase 1).

## Next Up

- Phase 2 (per `04-PHASE-GUIDE.md` — slot still empty; populate from `PROJECT_PLAN.md` §13 when Phase 2 begins).

## Open Questions

- Text-on-image visibility: the centered label on `HubCard` is small (no explicit `style:`) and may visually drift toward the image's dominant subject; fix proposed (add `headlineSmall` style + optional translucent backdrop) but not yet applied.
- `CataloguePage` drift: `floatingActionButton` absent, `appBar` present — both diverge from `05` §9 "Hub page" pattern. User-accepted; revisit in v1.1 polish.
- `PROJECT_PLAN.md` §14 row references `ToConsumePage` / `'To Consume'`; the shipped code uses `BucketListPage` / `'Bucket List'`. The plan row is stale relative to the shipped state.

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

## Norms Ladder (mirror of `07-TUTOR-PROTOCOL.md`)

| Invariant | Current state | Last touched | Notes |
|---|---|---|---|
| I-1 | Coached | — | first schema change pending |
| I-2 | Habitual | 2026-07-16 | 5+ correct `MediaStatus` references in Phase 1, no string-typed status |
| I-3 | Coached | — | same as I-2; relevant once `media_items` exists |
| I-4 | Coached | — | always relevant |
| I-5 | Habitual | 2026-07-16 | zero `dio` imports in `features/` Phase 1 |
| I-6 | Habitual | 2026-07-16 | zero `drift` imports in `features/` Phase 1 |
| I-7 | Habitual | 2026-07-16 | all widgets `StatelessWidget` Phase 1, no `setState` |
| I-8 | Coached (relaxed) | — | v1-wide exception |
| I-9 | Coached (relaxed) | — | v1-wide exception |
| I-10 | Coached | — | deferred until first drift test |
| I-11 | Coached | — | deferred until Phase 3b |
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