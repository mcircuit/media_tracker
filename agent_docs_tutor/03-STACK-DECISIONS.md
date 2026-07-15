# 03 — Stack Decisions (D1–D28)

This file is the decision log for the project. Each card has the
decision, a one-line summary, the rationale, and (where relevant) the
v2 follow-up. The tutor quizzes you on these cards when you ask "why
this stack choice?"

Original source: `PROJECT_PLAN.md` §16. The 28 decisions are locked —
you don't re-decide them; you understand them.

---

## Product / scope decisions

### D1 — Product positioning

**Summary:** Unified tracker, local-first growth, social-as-core
(deferred to v2).

**Rationale:** Start with a single-user local library. v1 is the local
library. v2 adds social features (circles, recommendations, swipe-based
matching) on a Supabase backend. The split lets v1 ship without
infra decisions.

### D2 — v1 sharing

**Summary:** Deferred to v2.

**Rationale:** Sharing requires a backend, identity, and link
generation. None of that exists in v1. Adding it later is cheaper than
removing it from v1.

### D3 — v1 bottom nav

**Summary:** Single-page for v1; nav ships with v2.

**Rationale:** v1 has exactly one main surface (the Catalogue hub). A
bottom nav with one tab is visual noise. v2's expanded scope (multi-type
catalogue, explore, community) is what justifies navigation chrome.

### D4 — Add-movie flow scope

**Summary:** TMDB search + results grid + AddSheet; saved-search-session
REMOVED.

**Rationale:** Saving the in-progress search session across app launches
is a v2+ convenience. v1's search is fire-and-forget: type, see results,
add or back out.

### D20 — Status enum v1

**Summary:** 2 states only; the other 3 added in v2 with the edit sheet
that surfaces them.

**Rationale:** v1's catalogue is "watched" vs "want to watch." v2 widens
to "watching," "dropped," and "rewatched." Keeping v1 to 2 keeps the
AddSheet simple (single toggle) and the Hub mapping unambiguous.

### D8 — Hub mapping

**Summary:** Strict 2-card layout: Collection / To Consume.

**Rationale:** Mirrors D20. The two HubCards map 1:1 to the two v1
statuses. Adding a third card to v1 would be UI for a state the user
can't reach.

---

## Data model decisions

### D5 — Data model

**Summary:** Hybrid — `media_items` + `*_details`; Movies-only in v1.

**Rationale:** Shared fields (id, status, rating, created_at) live on
`media_items`. Type-specific fields (TMDB id, runtime, genre for movies;
author, ISBN for books) live on `*_details`. One row in `media_items`
joins to at most one `*_details` row per type.

### D6 — `media_items.type` storage

**Summary:** Plain `TEXT` (zero schema change when widening type set).

**Rationale:** If the column were an SQLite ENUM, adding `book` would
require a migration. Storing as `TEXT` and constraining at the Dart
layer (`EnumNameConverter<MediaType>`) keeps the migration cost at zero
while keeping the runtime invariant enforced.

### D7 — Status enum

**Summary:** 2 states in v1: `onWatchlist`, `inCollection`.

**Rationale:** See D20. The enum is sealed at the Dart level; the column
stores the enum name as text.

### D11 — `copyWith` source

**Summary:** Drift-generated in Phase 3a.

**Rationale:** Drift's codegen produces a `MediaItemData` (or equivalent)
with a generated `copyWith` method. Hand-writing one is duplication; the
generated one is always in sync with the table schema.

### D25 — `source` + `imported_at` columns

**Summary:** In v1, forward-compatible with v2 import; see `01-PRODUCT.md`
§"v2 forward-look".

**Rationale:** v2 will import from Letterboxd CSV, iMDB, MAL, etc. The
`source` column (`'manual'` default) and `imported_at` (NULL for
manual, timestamp for imports) carry provenance from day one. Adding
them in v2 would require backfilling existing rows; v1's greenfield
schema starts with them.

### D28 — `MediaType` enum v1

**Summary:** Only `MediaType.movie` is valid in v1;
`EnumNameConverter<MediaType>` wired at column level.

**Rationale:** See D6. The Dart enum has all v2 cases; the converter
refuses to write anything other than `MediaType.movie` in v1. When v2
arrives, the converter is loosened — no schema change.

---

## TMDB / HTTP decisions

### D9 — TMDB client

**Summary:** `Dio` behind `MediaSearchClient`; regenerated-client-ready
for v2.

**Rationale:** Today we hand-write the Dio calls. v2 introduces
OpenAPI-driven client generation for both TMDB and the Supabase mega-DB
endpoints. The `MediaSearchClient` interface is the seam where the
underlying client gets swapped without UI changes.

### D21 — Add-movie idempotency

**Summary:** `findByTmdbId` pre-check + `AlreadyInCollection` exception →
snackbar.

**Rationale:** The catalogue is the source of truth. Re-adding a movie
the user has already logged is almost always a UX bug (they forgot they
had it). The repository checks `findByTmdbId` first; if a row exists,
it throws; the provider maps the exception to a localized snackbar.

### D27 — `resolveTitle` signature

**Summary:** Deferred to v2; `MediaSearchClient` is forward-compatible.

**Rationale:** v1's search is exact TMDB-result matching. v2 will need
"fuzzy" / "did you mean" logic to handle user typos. The signature is
designed so v2 can extend with optional parameters without breaking v1
callers.

---

## Theme / UI decisions

### D10 — Theme

**Summary:** Material 3 + single seed color; light + dark both derived
from the same `seedColor` via `ColorScheme.fromSeed`.

**Rationale:** One seed color generates both palettes. v1 ships dark
mode only; light is derived but unused. v1.1+ adds light-mode UI without
design work — the palette already exists.

### D19 — Seed color

**Summary:** One seed for both brightness modes.

**Rationale:** See D10. The seed is defined once in `lib/app/theme.dart`;
`ColorScheme.fromSeed(seedColor: X, brightness: Brightness.dark)` and
`Brightness.light` produce both palettes.

### D15 — Material import strategy

**Summary:** `package:flutter/material.dart` while on Flutter 3.44.x;
migrate to `material_ui` / `cupertino_ui` on next major bump.

**Rationale:** Flutter team is splitting Material into a separate
package in a future major. Today we import from the bundled SDK; the
migration is one committed rename when it lands. See invariant I-12.

### D16 — Image caching

**Summary:** `flutter_cache_manager` direct, not `cached_network_image`
(rule #7).

**Rationale:** `cached_network_image` has not had a release in over a
year from a non-Flutter-team publisher. `flutter_cache_manager` is
actively maintained and from a verified publisher. Direct use avoids a
wrapper layer; we get full control over the cache file layout.

### D17 — Icons

**Summary:** Material Symbols Rounded bundled as asset (rule #7).

**Rationale:** Same publisher-trust reasoning as D16. We bundle the
font at `assets/fonts/MaterialSymbolsRounded.ttf` and reference icons
via `IconData(fontFamily: 'MaterialSymbolsRounded', fontPackage: 'media_tracker')`.

### D18 — Fonts

**Summary:** `google_fonts` for Source Serif 4 + Inter (verified
publisher `flutter.dev`).

**Rationale:** `google_fonts` is the Flutter team's package for runtime
font fetching. Source Serif 4 handles display/headline; Inter handles
title/body/label. See `05-DESIGN-SYSTEM.md` §3 for the role split.

---

## State management decisions

### D22 — Provider per type

**Summary:** Locked mapping table; one provider per type; no
multi-provider reconciliation.

**Rationale:** Each media type gets one Riverpod provider that
materializes the typed list from Drift. The catalogue hub reads two of
them (one per status) and never reconciles across types — there's only
one type in v1.

---

## Migration decisions

### D13 — Migration story

**Summary:** Additive migrations; `stepByStep` helper when useful.

**Rationale:** Drift's `MigrationStrategy.onUpgrade` runs branches per
schema version. Migrations should be additive (add column, add table)
when possible. Drop operations require explicit user confirmation and a
preservation step. See invariant I-1.

---

## Testing decisions

### D14 — Testing breadth

**Summary:** Drift repo / Riverpod provider / widget; ~150 lines total.

**Rationale:** This is a personal app, not a team codebase. We aim for
"the important paths are tested" — drift round-trips, provider state
transitions, and one widget test per HubCard. Not a coverage target; a
targeted minimum.

---

## v2-only decisions (for context only — not implemented in v1)

### D12 — v2 auth + backend

**Summary:** Supabase (Auth + Postgres + RLS + Realtime); see also D26.

**Rationale:** v2 introduces identity, multi-device sync, and a
mega-database. Supabase gives all three with one stack.

### D23 — Games provider

**Summary:** RAWG (not IGDB); IGDB rate-limits per-Client-ID, not
per-user.

**Rationale:** When v2 adds Games, RAWG is the chosen provider because
its rate-limit model fits per-user attribution. IGDB's per-Client-ID
limit would force a shared quota across all v2 users.

### D24 — Games attribution

**Summary:** RAWG requires active hyperlink on every page using RAWG
data.

**Rationale:** RAWG's TOS. The Games detail view will render an
attribution footer.

### D26 — Backend mega-database

**Summary:** `media_universe` on Supabase Postgres; ETL-fed; strict
separation from local `media_items`.

**Rationale:** v2's `media_universe` is the system's knowledge (every
movie, book, game that exists). The local `media_items` is the user's
library (what they have logged). The two never share a row identity:
`media_universe.media_id` is referenced by `media_items.universe_id`,
not merged.

---

## Cross-references

- Architecture and invariants: `02-ARCHITECTURE.md`
- Product framing and v2 forward-look: `01-PRODUCT.md`
- Phase-by-phase build: `04-PHASE-GUIDE.md`
- UI tokens: `05-DESIGN-SYSTEM.md`
- Concepts reference: `06-CONCEPTS-AND-GLOSSARY.md`
- Tutor role: `07-TUTOR-PROTOCOL.md`
- Production-style decision index (kept for reference):
  `agent_docs/architecture.md` §Decision Index