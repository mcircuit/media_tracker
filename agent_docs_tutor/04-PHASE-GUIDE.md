# 04 — Phase Guide

## TL;DR

This file is **the user's working document**. Each phase of the build gets
a section here. The user pastes the phase + Done Definition from
`PROJECT_PLAN.md` (user-only — the tutor never reads it). The tutor
helps the user populate the per-step blocks: prerequisite checks, the
user's work, and tutor review.

`PROJECT_PLAN.md` owns the *what* and *when* (phase numbering, Build
Order, Done Definitions). This file owns the *how* — the per-step
structure that makes each step inspectable.

## How a phase entry is populated

For each phase:

1. The user pastes a one-line description from `PROJECT_PLAN.md` §13.
2. The user pastes the Done Definition from `PROJECT_PLAN.md` §14.
3. The user and tutor together break the phase into 3–8 sub-steps.
4. Each sub-step gets the per-step template below.
5. As work progresses, the user marks sub-steps completed in
   `08-PROGRESS.md`.

The user can revise a phase entry mid-phase. The tutor flags revisions
that drift outside the original Done Definition.

## Per-step template (copy this for every sub-step)

```markdown
### Phase <N>, Step <X.Y> — <one-line goal>

**Tutor prerequisite check (must pass before you code):**
- <concept question 1> — answer hint: <one-sentence expected answer>
- <concept question 2> — answer hint: <one-sentence expected answer>
- (optional) <concept question 3>

**You do:**
- <file path to open or create>
- <concrete change: class, widget, function, column>
- <command to run after the change>

**Tutor review:**
- Invariants to verify: <list from 02-ARCHITECTURE.md, e.g., "I-5, I-6">
- Design tokens to verify: <list from 05-DESIGN-SYSTEM.md, e.g., "color/surface, space/md">
- Expected failure modes: <what might go wrong; how the tutor catches it>
```

The **Tutor prerequisite check** is the new pedagogical block. It runs
*before* you write code. The tutor asks 1–3 questions; you answer; you
proceed only when you can answer. If you can't, the tutor pulls a
30-second mini-explanation from `06-CONCEPTS-AND-GLOSSARY.md` and
re-asks. (See `07-TUTOR-PROTOCOL.md` §What the tutor does for the full
flow.)

The **Tutor review** block runs *after* you run the commands and report
back. The tutor reads your pasted code and the command output, then
checks each invariant and token. The tutor does not write the code; it
surfaces issues and asks you to fix them.

## Example phase entry

This is **an example to illustrate the format**. It is not a real phase
from your `PROJECT_PLAN.md`. Replace or extend when you start a real
phase.

```markdown
## Phase 7 (EXAMPLE — replace) — Render the Catalogue hub page

**From PROJECT_PLAN.md §13:** "[paste phase description here]"
**Done Definition from §14:** "[paste row here]"

### Phase 7, Step 7.1 — Set up `MaterialApp` and `Scaffold`

**Tutor prerequisite check:**
- "What does `MaterialApp` do at the top of the widget tree?" — answer:
  it injects the theme, locale, navigator, and other descendants into
  the tree.
- "What does `Scaffold` provide?" — answer: the basic visual layout
  (AppBar, body, FAB, drawer, etc.).

**You do:**
- open `lib/main.dart`
- wrap `runApp` with `MaterialApp(theme: ..., home: ...)`
- pass `Scaffold` as `home`
- run `flutter run`

**Tutor review:**
- Invariants to verify: I-12 (Material import from `package:flutter/material.dart`)
- Design tokens to verify: `color/background` on Scaffold's backgroundColor
- Expected failure modes: missing theme → app falls back to purple
  debug theme; tutor catches.

### Phase 7, Step 7.2 — Render the first HubCard

**Tutor prerequisite check:**
- "What does a `Card` widget produce visually?" — answer: an elevation,
  rounded corners, optional child.
- "Why does `Card` need a `Material` ancestor?" — answer: it paints
  into one; without it, the build throws.

**You do:**
- open `lib/features/catalogue/catalogue_page.dart`
- add a `Card` with `color: Theme.of(context).colorScheme.surface`
- run `flutter run`, screenshot

**Tutor review:**
- Invariants to verify: I-6 (no drift import), I-7 (no setState for
  shared state)
- Design tokens to verify: `radius/md` for Card, `space/md` for inner
  padding
- Expected failure modes: hardcoded color instead of
  `Theme.of(context).colorScheme.surface` → tutor catches.
```

---

## Open phase slots

These are placeholders. The user (or the tutor, with the user pasting
the phase info) populates each as work progresses.

### Phase 1 — [paste description]

**From PROJECT_PLAN.md §13:** *(paste here)*
**Done Definition from §14:** *(paste here)*

### Phase 2 — [paste description]

**From PROJECT_PLAN.md §13:** *(paste here)*
**Done Definition from §14:** *(paste here)*

### Phase 3a — [paste description]

**From PROJECT_PLAN.md §13:** *(paste here)*
**Done Definition from §14:** *(paste here)*

### Phase 3b — [paste description]

**From PROJECT_PLAN.md §13:** *(paste here)*
**Done Definition from §14:** *(paste here)*

### Phase 4 — [paste description]

**From PROJECT_PLAN.md §13:** *(paste here)*
**Done Definition from §14:** *(paste here)*

### Phase 5 — [paste description]

**From PROJECT_PLAN.md §13:** *(paste here)*
**Done Definition from §14:** *(paste here)*

### Phase 6 — [paste description]

**From PROJECT_PLAN.md §13:** *(paste here)*
**Done Definition from §14:** *(paste here)*

### Phase 7 — [paste description]

**From PROJECT_PLAN.md §13:** *(paste here)*
**Done Definition from §14:** *(paste here)*

### Phase 8 — [paste description]

**From PROJECT_PLAN.md §13:** *(paste here)*
**Done Definition from §14:** *(paste here)*

---

## v2 phase slots

The user (or the tutor, with the user pasting) populates each slot as
work reaches that phase. Phase numbering comes from `PROJECT_PLAN.md`
§13; the slots below use placeholder names.

### Phase v2a — [paste description, e.g., "Widen type enum to TV + Animes"]

**From PROJECT_PLAN.md §13:** *(paste here)*
**Done Definition from §14:** *(paste here)*

### Phase v2b — [paste description, e.g., "Add Supabase backend + auth"]

**From PROJECT_PLAN.md §13:** *(paste here)*
**Done Definition from §14:** *(paste here)*

### Phase v2c — [paste description, e.g., "Add Explore page + recommendation algorithm"]

**From PROJECT_PLAN.md §13:** *(paste here)*
**Done Definition from §14:** *(paste here)*

### Phase v2d — [paste description, e.g., "Add Community + sharing"]

**From PROJECT_PLAN.md §13:** *(paste here)*
**Done Definition from §14:** *(paste here)*

### Phase v2e — [paste description, e.g., "Add import pipeline (MAL/IMDB/MOB)"]

**From PROJECT_PLAN.md §13:** *(paste here)*
**Done Definition from §14:** *(paste here)*

### Phase v2f — [paste description, e.g., "Add export (JSON/CSV) + data portability"]

**From PROJECT_PLAN.md §13:** *(paste here)*
**Done Definition from §14:** *(paste here)*

---

## v3 phase slots

### Phase v3a — [paste description, e.g., "Cross-platform: iOS"]

**From PROJECT_PLAN.md §13:** *(paste here)*
**Done Definition from §14:** *(paste here)*

### Phase v3b — [paste description, e.g., "Cross-platform: Web + Desktop"]

**From PROJECT_PLAN.md §13:** *(paste here)*
**Done Definition from §14:** *(paste here)*

### Phase v3c — [paste description, e.g., "Customizable UI (VivaVid-style theming)"]

**From PROJECT_PLAN.md §13:** *(paste here)*
**Done Definition from §14:** *(paste here)*

---

## v2/v3 phase content

Phase numbering for v2 and v3 comes from `PROJECT_PLAN.md` §13. The
tutor does not pre-populate v2/v3 phase content from the project's
roadmap image (`Media Tracking Roadmap.png`); the user fills each slot
as work reaches that phase.

Sources of truth for v2/v3:

- **Phase numbering and Done Definitions:** `PROJECT_PLAN.md` §13 / §14
  (user-only).
- **Locked v2 decisions:** `03-STACK-DECISIONS.md` §"v2-only decisions"
  (D12, D23, D24, D25, D26, D27).
- **v2 vision (one paragraph):** `01-PRODUCT.md` §"v2 forward-look."

When v2 work begins, the tutor adds v2-specific design tokens to
`05-DESIGN-SYSTEM.md` and v2-specific concepts (Supabase auth, RLS,
Realtime, etc.) to `06-CONCEPTS-AND-GLOSSARY.md`. The 14 invariants in
`02-ARCHITECTURE.md` are forward-compatible and need no changes.

---

## How the tutor uses this file

1. **At session start**, the tutor reads the current phase slot.
2. **The tutor may revise the per-step blocks** if the user's pasted
   Done Definition is unclear. The user approves the revision.
3. **During work**, the tutor cross-references invariants and design
   tokens against the actual invariants and tokens in `02-ARCHITECTURE.md`
   and `05-DESIGN-SYSTEM.md` — never against this file alone. This file
   is a pointer, not the source of truth for rules.

## Cross-references

- Invariants referenced by `Tutor review`: `02-ARCHITECTURE.md`
- Design tokens referenced by `Tutor review`: `05-DESIGN-SYSTEM.md`
- Concepts referenced by `Tutor prerequisite check`:
  `06-CONCEPTS-AND-GLOSSARY.md`
- Tutor role and how the prerequisite check works:
  `07-TUTOR-PROTOCOL.md`
- Phase numbering (user-only, never read by tutor): `PROJECT_PLAN.md`
  §13–§14