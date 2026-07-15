# 00 — Start Here

## TL;DR

You are a beginner Flutter developer building **Media Tracker** — a local-first
app for cataloguing movies you've watched and want to watch. This folder is the
tutor's reference material. The tutor (an LLM reading `AGENTS.md`) uses these
docs to:

- Confirm you're on the right path before you write code.
- Cross-check your code against the project's invariants and design tokens.
- Quiz your understanding of *why* decisions were made.
- Suggest, not write — you write the code.

This file orients you (and the tutor) to the rest of the folder.

## Audience

**You:** a beginner Flutter developer learning by building. You paste code,
ask questions, run the commands the tutor suggests, and update
`08-PROGRESS.md` as you go.

**The tutor:** the LLM in tutor mode (see `AGENTS.md` for the charter). It
reviews, explains, quizzes, and cross-checks. It does NOT write code
unsolicited.

## How a session begins

At the top of every new chat, paste this preamble (the tutor reads
`AGENTS.md` automatically via `opencode.jsonc`'s `instructions` field, but
the preamble below reminds the tutor of the current task and the v1
exceptions):

```
Tutor mode for Media Tracker v1. Load in full: AGENTS.md (already auto-loaded),
then agent_docs_tutor/00-START-HERE.md and 07-TUTOR-PROTOCOL.md. Load others
on demand per their pointers. PROJECT_PLAN.md is user-only — paste the current
phase and Done Definition inline. v1-wide I-8 + I-9 exceptions are in effect.
No automated enforcement of any invariant lives in this repo. One question per
ambiguity; brutal honesty preferred. No unsolicited code.

Current phase: <N>. Done Definition: <paste>.
```

If you use a different LLM client that doesn't auto-load `AGENTS.md`, also
paste the body of `AGENTS.md` into the preamble.

## What lives in this folder

| File | Owns | When to load |
|---|---|---|
| `00-START-HERE.md` (this file) | orientation, file map, session preamble | every session |
| `01-PRODUCT.md` | what we're building, success criteria | when scope or "why this?" is unclear |
| `02-ARCHITECTURE.md` | layered architecture, the 14 invariants | when crossing layers or reviewing a rule |
| `03-STACK-DECISIONS.md` | D1–D28 as short cards with rationale | when the user asks "why this stack choice?" |
| `04-PHASE-GUIDE.md` | per-step structure: prerequisite checks, your work, tutor review | the user follows this per phase |
| `05-DESIGN-SYSTEM.md` | theme, colors, typography, spacing, components, accessibility | when rendering or restyling UI |
| `06-CONCEPTS-AND-GLOSSARY.md` | worked mini-lessons + post-hoc glossary | when a Flutter / Dart / drift / Riverpod concept is unclear |
| `07-TUTOR-PROTOCOL.md` | tutor role, prompt templates A–E, session cadence, Norms Ladder | every session (right after 00) |
| `08-PROGRESS.md` | your day-to-day status | read at session start; update at session close |
| `09-WORKFLOW.md` | Git + GitHub workflow: commit format, branch format, PR flow, tag strategy, Git primer | every phase boundary (when committing / pushing / tagging) |

Numbered prefixes force the sort order so the files load in reading order.

## What lives outside this folder

| Path | Owns | Read by tutor? |
|---|---|---|
| `PROJECT_PLAN.md` | phase numbering, Build Order, Done Definitions, Decisions Log D1–D28, Migrations | **NO** — user-only. You paste phase + Done Definition inline. |
| `agent_docs/` | production-style reference doc set (kept for comparison) | only if you explicitly ask the tutor to consult it |
| `lib/`, `test/`, `pubspec.yaml`, `analysis_options.yaml` | the actual code | the tutor reads but does not edit without permission |

`FOR_TUTOR_AGENTS.md` at the repo root has been deleted. Its role is now
played by `AGENTS.md` + this folder.

## Session rhythm

1. You paste the preamble above with current phase + Done Definition.
2. The tutor reads `00-START-HERE.md` and `07-TUTOR-PROTOCOL.md`, plus any
   other file the task touches.
3. The tutor confirms scope (in 1–2 sentences) and asks any clarifying
   questions.
4. You do the work (write code, run commands).
5. The tutor reviews using the per-step `Tutor review` block in
   `04-PHASE-GUIDE.md` and any invariants from `02-ARCHITECTURE.md` that
   apply.
6. You update `08-PROGRESS.md` at session close.

If a session drifts outside the Done Definition, the tutor will surface it.
This is intentional — drift is the most common failure mode for solo
projects.

### Version control

You commit at the end of every phase (or sub-phase, when a phase has
two independent concerns). Format: `phase(N): <short-name>`. You
branch per phase: `<type>/<phase>-short-name`. PR against `main` on
GitHub; squash-merge; squash title follows the commit convention.
Tag `v1.0` at the end of Phase 7 (Wrap-up); v2 branches off that tag.

Full reference, including Git concepts for beginners and common
pitfalls: `09-WORKFLOW.md`.

## Reading order (when context window is tight)

1. `00-START-HERE.md` (this file)
2. `07-TUTOR-PROTOCOL.md` — the tutor's operating rules
3. `08-PROGRESS.md` — where you are right now
4. `01-PRODUCT.md` — what we're building
5. `02-ARCHITECTURE.md` + `03-STACK-DECISIONS.md` — how it's built and why
6. `04-PHASE-GUIDE.md` — what to build next
7. `05-DESIGN-SYSTEM.md` — what it should look like
8. `06-CONCEPTS-AND-GLOSSARY.md` — looked up on demand, not read top-to-bottom
9. `09-WORKFLOW.md` — load on phase boundaries, not every session

## Glossary mini

These terms appear everywhere in the docs. Pin them once.

- **media_item** — the central entity in the app (in v1, always a movie).
  Stored in the `media_items` SQLite table.
- **status** — `onWatchlist` (want to watch) or `inCollection` (have watched).
  Locked to 2 values in v1.
- **HubCard** — the two big cards on the Catalogue page: "Collection" and
  "To Consume." Each card shows a count and a label, not a list.
- **AddSheet** — the modal bottom sheet where you set status + rating when
  adding or editing a movie.
- **TMDB** — The Movie Database, the external metadata source. Read-only in
  v1; you never write to it.
- **drift** — the SQLite ORM used for persistence. Generates typesafe Dart
  from your table definitions.
- **Riverpod 3** — the state-management library. `ProviderScope`, `Notifier`,
  `AsyncNotifier` are the main APIs you'll learn.

Full glossary with worked examples: `06-CONCEPTS-AND-GLOSSARY.md`.

## v2 and beyond

This doc set covers **v1, v2, and v3** of Media Tracker as one
continuous program. v1 is the immediate focus (Movies, Android,
local-first). v2 widens the type set (TV, Anime, Books, Games, etc.),
adds a Supabase backend, sharing, and import pipelines. v3 adds
cross-platform targets (iOS, Web, Desktop) and customizable theming.

The Phase Guide in `04-PHASE-GUIDE.md` has slots for all three versions
(v1 phases 1–8, v2 phases v2a–v2f, v3 phases v3a–v3c). You fill the
v2/v3 slots as work reaches those phases. The roadmap image
(`Media Tracking Roadmap.png`) is **informational only** — it shows
the high-level vision but is not the spec. `PROJECT_PLAN.md` is the
source of truth for phase numbering and Done Definitions.

Sources for v2/v3:

- **v2 vision (one paragraph):** `01-PRODUCT.md` §"v2 forward-look"
- **v2-locked decisions:** `03-STACK-DECISIONS.md` §"v2-only decisions"
  (D12 Supabase, D23 RAWG, D24 attribution, D25 `source`+`imported_at`,
  D26 `media_universe`, D27 `resolveTitle`)
- **Phase slots:** `04-PHASE-GUIDE.md` §"v2 phase slots" and §"v3 phase slots"

When v2 work begins, the tutor adds v2-specific design tokens to
`05-DESIGN-SYSTEM.md` and v2-specific concepts (Supabase auth, RLS,
Realtime, ETL) to `06-CONCEPTS-AND-GLOSSARY.md`.

## Cross-references

- Project charter and tutor permissions: `AGENTS.md` (repo root, auto-loaded)
- What to build and why: `01-PRODUCT.md`
- How it's built and the 14 invariants: `02-ARCHITECTURE.md`
- Why these specific stack choices: `03-STACK-DECISIONS.md`
- Step-by-step phase work: `04-PHASE-GUIDE.md`
- UI tokens and components: `05-DESIGN-SYSTEM.md`
- Concepts reference (post-hoc): `06-CONCEPTS-AND-GLOSSARY.md`
- Tutor role, prompt templates, Norms Ladder: `07-TUTOR-PROTOCOL.md`
- Current state: `08-PROGRESS.md`
- Git + GitHub workflow: `09-WORKFLOW.md`