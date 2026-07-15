# 08 — Progress

This file is your day-to-day status. The tutor reads it at session
start (to know where you are) and you update it at session close
(completed work, blockers, session notes).

This file is the single source of truth for "where am I right now." If
you're not sure what phase you're on, look here.

## Current Phase

- Phase 1

## Current Goal

- Finishing the Catalogue screen with the Movie media type.

## Completed

- None yet.

## In Progress

- None yet.

## Next Up

- Phase 1 Step 2.

## Open Questions

- None yet.

## Architecture Decisions

- None yet. (Decisions live in `PROJECT_PLAN.md` §16 / `03-STACK-DECISIONS.md`.)

## Session Notes

### Session 0 — 2026-07-15 — Doc setup

- Replaced the production-style `agent_docs/` (kept as reference) with
  a tutor-oriented `agent_docs_tutor/` set built around the tutor role.
- Deleted `FOR_TUTOR_AGENTS.md`; replaced with `AGENTS.md` (auto-loaded
  via `opencode.jsonc`'s `instructions` field).
- Deleted `.github/workflows/ci.yml`, all of `tool/ci/*.sh`, and
  `lefthook.yml` — CI scripts become the user's writing task at the
  earliest meaningful point per invariant (see
  `07-TUTOR-PROTOCOL.md` §Norms Ladder).
- Relaxed pubspec SDK pinning per I-9 v1-wide exception.
- Dropped the four `import_lint` rules from `analysis_options.yaml` per
  the learning-mode exception (the tutor enforces them in chat; you'll
  re-add them as part of CI restoration in v2).

### Session 0b — 2026-07-15 — Scope expansion to v1+v2+v3

- Expanded tutor doc set scope to cover v1, v2, and v3 as one
  continuous program (per user's "Build the full roadmap as one tutor
  program" decision).
- Added v2 phase slots (v2a–v2f) and v3 phase slots (v3a–v3c) to
  `04-PHASE-GUIDE.md` as placeholders for the user to populate from
  `PROJECT_PLAN.md` §13 / §14.
- Added "v2 and beyond" pointer to `00-START-HERE.md`.
- Expanded the v2 forward-look paragraph in `01-PRODUCT.md` to point
  at the v2 phase slots and locked v2 D-cards.
- The roadmap image (`Media Tracking Roadmap.png`) is informational
  only; the user owns `PROJECT_PLAN.md` and it is the source of truth
  for phase numbering and Done Definitions. The tutor does not
  pre-populate v2/v3 phase content from the image.

### Session 0c — 2026-07-15 — PROJECT_PLAN.md alignment to tutor doc set

- Per user decision ("current doc set is more in line with how I want
  my app to be than the project plan file. modify the plan file"),
  aligned `PROJECT_PLAN.md` to the tutor doc set:
  - §2.1: fixed "5-state status enum" typo → "2-state status enum";
    "Light + dark themes" → "Dark theme ships in v1, light derived but
    not shipped (v1.1+)."
  - §6.2: clarified that bottom nav + drawer are v2 scope per the
    tutor doc set; v1 is single-page.
  - §8.1: "Light + dark: both supported" → "Dark ships in v1, light
    derived from the same seed but not shipped."
  - §10: added §10.1 cross-reference to the 14 invariants in
    `02-ARCHITECTURE.md` (specifically I-11 search signature, I-13 no
    `user_id`, I-14 TMDB key at boot). Canonical invariant list lives
    in the tutor doc.
  - §13: Phase 5 row changed from "Full CRUD UI + Iteration 2 (TV
    Shows mirror)" to "Full CRUD UI (Movies only). No TV Shows mirror
    in v1."
  - §13.1: replaced I1/I2/I3/v2 mapping with "v1 ships Movies only
    (I1). TV Shows (I2) and Anime (I3) are deferred to v2+."
  - §14: U7 "TV Shows mirror" replaced with stub
    "*(removed — TV Shows deferred to v2; see §18 v2a)*".
  - §U8: "Light + dark verified" → "Dark theme verified."
  - New §18: v2 and v3 Phases (6 v2 slots + 3 v3 slots, mirroring
    the tutor doc set's `04-PHASE-GUIDE.md`).
  - New §19: Open questions for v2/v3 (MOB databases, PC App +
    Website, Vivaldi theming, Dashboard page, swipe-based matching,
    custom user themes).
- `PROJECT_PLAN.md` and the tutor doc set are now 100% consistent on
  v1 scope (Movies only, dark theme, 2-state status) and v2/v3 phase
  structure.

### Session 0d — 2026-07-15 — Git/GitHub workflow added

- Per user decision, the project uses Git + GitHub for version
  control. Remote: GitHub. Commit cadence: per phase (or per
  sub-phase when a phase has two independent concerns). Branch
  per phase; PR against main; squash-merge; squash title follows
  `phase(N): <short-name>`. Tag `v1.0` at Phase 7 wrap-up; v2
  branches off that tag.
- Added `agent_docs_tutor/09-WORKFLOW.md` (~125 lines) with
  rationale, commit format, branch format, PR workflow, tag
  strategy, a Git concepts primer for beginners, and a common
  pitfalls list.
- Updated `agent_docs_tutor/00-START-HERE.md` to add 09-WORKFLOW.md
  to the file map, a brief "Version control" sub-section under
  "Session rhythm", a reading-order entry, and a cross-reference.
- The project is not yet a git repo. `git init` is the first
  command the user runs in a new shell, per the typical flow
  documented in 09-WORKFLOW.md.

### Session 1 — *pending*

## Norms Ladder (mirror of `07-TUTOR-PROTOCOL.md`)

| Invariant | Current state | Last touched | Notes |
|---|---|---|---|
| I-1 | Coached | — | first schema change pending |
| I-2 | Coached | — | relevant once `media_items` exists |
| I-3 | Coached | — | same as I-2 |
| I-4 | Coached | — | always relevant |
| I-5 | Coached | — | relevant once `features/` exists |
| I-6 | Coached | — | same as I-5 |
| I-7 | Coached | — | relevant once widgets have shared state |
| I-8 | Coached (relaxed) | — | v1-wide exception |
| I-9 | Coached (relaxed) | — | v1-wide exception |
| I-10 | Coached | — | deferred until first drift test |
| I-11 | Coached | — | deferred until Phase 3b |
| I-12 | Coached | — | always relevant |
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