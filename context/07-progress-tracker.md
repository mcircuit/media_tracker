# 07 — Progress Tracker

> **Tutor-maintained file** (per `00-tutor-workflow-rules.md`).
> The Tutor writes this file; the user reviews and confirms.
> Per `00-tutor-workflow-rules.md` §Session cadence, the Tutor
> appends a Session Notes block at session close summarizing
> the session's work, blockers, and open questions. Other status
> sections (Current Phase, Current Goal, Completed, In Progress,
> Next Up, Open Questions) are also Tutor-maintained from the
> same session context.
>
> The Norms Ladder and Doc-gardening trigger live in
> `00-tutor-workflow-rules.md`; this file is status-only.

---

## Current Phase

**Phase 3a — Drift data model.** This is the active work.

Per `05-phases.md` §Phase 3a, Phase 3a produces the
`AppDatabase` with `schemaVersion = 1`, the `media_items` +
`movie_details` tables with `EnumNameConverter` wired at the
column level, the `MovieDao` (incl. `findByTmdbId` for
idempotency), and 4-5 repository tests.

## Current Goal

Finish Phase 3a end-to-end so Drift is wired before Phase 3b
introduces TMDB. Specifically:

- Phase 3a.1 — pubspec.yaml deps + dev deps
- Phase 3a.2 — Tables: `media_items` + `movie_details`
- Phase 3a.3 — `AppDatabase` class + `MigrationStrategy`
- Phase 3a.4 — `MovieDao` with `findByTmdbId`
- Phase 3a.5 — Drift repository tests (insert, query, delete,
  migration v1→v2, `findByTmdbId` returns existing row)

Verify: `flutter test test/data/movie_dao_test.dart` passes;
`dart run build_runner build --delete-conflicting-outputs`
regenerates `database.g.dart` cleanly.

## Completed

- **Phase 0** — Tooling: `flutter doctor` clean, emulator-5554
  online, default counter app launched.
- **Phase 1** — Static catalogue hub. **Banner:** shipped with
  the canonical-naming amendment pending per D33. The shipped
  code uses `MediaStatus.onWatchlist` / `"Bucket List"` /
  `to_consume_page.dart`; canonical rename cascade per
  D-L13 → `onBucketlist` / `"Bucketlist"` /
  `bucketlist_page.dart` is captured in
  `08-decisions-log.md` D33. Sub-step templates in
  `05-phases.md` are archival reference; user does NOT redo
  Phase 1 by hand.
- **Phase 2** — App shell: 11 routes via `go_router`;
  `MaterialApp.router` wiring; `MediaSearchClient` abstract
  interface defined; 2-tab bottom nav in v1.

## In Progress

- **Phase 3a.1** — Adding `drift`, `sqlite3_flutter_libs`,
  `path_provider` runtime deps; `drift_dev`, `build_runner` dev
  deps. Writing `build.yaml` with `drift_dev` builder options
  pointing at `lib/data/database.dart`.
- **Phase 3a.2** — Drafting `media_items.dart` and
  `movie_details.dart` table classes per the schema in
  `02-architecture.md` §4.1.
- **Phase 3a.3** — Drafting `database.dart` with
  `@DriftDatabase(tables: [MediaItems, MovieDetails])`,
  `schemaVersion = 1`, `MigrationStrategy.onCreate`,
  `MigrationStrategy.onUpgrade` empty for v1.
- **Phase 3a.4** — Drafting `MovieDao` with `findById`,
  `findByTmdbId`, `watchByStatus`, `insertMovie`, etc.
- **Phase 3a.5** — Drafting `test/data/movie_dao_test.dart` with
  4-5 tests using `NativeDatabase.memory()`.

## Next Up

- **Phase 3b** — TMDB search interface (`MediaSearchClient`
  impl, DTOs, `SearchRepository`, idempotency, offline
  fallback).
- **Phase 4** — Riverpod over drift (4 providers; codegen).
- **Phase 5** — Full CRUD UI (Search Page 5-state flow; EditSheet;
  Media Filter; Hamburger Menu stubs; MediaTypePage;
  ManualEntryForm; 13 sub-steps; widget tests).
- **Phase 6** — Polish (verify light + dark; typography; empty
  states; offline UX; accessibility; error states; optional
  integration test).
- **Phase 7** — Wrap-up (retrospective on locked decisions;
  v2 handoff brief).

## Open Questions

These surface from `PROJECT_PLAN.md` §19 and may grow during
the build. The tutor cites them when the user asks "what's
still unresolved?".

- **"MOB databases"** — the original roadmap image mentions
  "Import from MyAnimeList, IMDB, MOB databases." `MOB` is
  not defined. Resolution deferred to v2 import pipeline
  planning. The v1 doc set does not depend on this.
- (User adds additional open questions here as they arise;
  the Tutor formats and writes them in.)

## Session Notes  (Tutor-written with user confirmation)

The Tutor appends a block at the bottom of this section at
session close. Format: the Tutor drafts from the session
transcript; the user reviews and confirms; then the Tutor
commits. Other sections of this file (Current Phase, etc.)
are Tutor-maintained from the same session context.

### (template — Tutor fills in per session)

```markdown
### Session N — YYYY-MM-DD — <one-line summary>  (Tutor-drafted)

- <what shipped this session>  ← from session transcript
- <what's still pending>
- <any blockers or surprises>
- <cross-reference to D-cards cited, if any>
```

### Session log (chronological)

The Tutor appends a one-line entry per session:

```
Session 1: <date> — <summary>  (Tutor-drafted)
Session 2: <date> — <summary>
...
```

### Workflow (Tutor does this at session close)

1. Tutor reviews the session transcript.
2. Tutor drafts a Session N block (template above).
3. Tutor surfaces the draft to the user: "Here's the session
   note I propose to commit. Anything to add or correct?"
4. User confirms or amends.
5. Tutor commits the block to this file.

---

## Cross-references

- Phase numbering, Done Definitions, per-step 5-sub-block
  templates: `05-phases.md`
- D-cards (locked decisions D1–D33): `08-decisions-log.md`
- Architecture, layers, App Shell, invariants: `02-architecture.md`
- Conventions, framework patterns, styling rules:
  `03-code-standards.md`
- Design tokens, layout patterns, icon usage: `04-ui-context.md`
- Project framing, success criteria, glossary:
  `01-project-overview.md`
- Tutor's role & 5-step flow, Norms Ladder, Doc-gardening
  trigger, git workflow: `00-tutor-workflow-rules.md`
- Programming concepts (agent uses `webfetch` /
  `websearch` for current sources)
- Repo-root charter: `/AGENTS.md`
