# 08 — Decisions Log (D1–D33)

## TL;DR

This file is the **decisions inventory** the tutor agent cites
when a quiz, code review, or design question asks "why did we
pick X?". Each card has a one-line summary and the rationale
locked at the time the decision was made.

Reference convention: when `03-code-standards.md` or
`02-architecture.md` cites a D-card (e.g., "D17"), this file
contains the full rationale.

Cross-reference targets live elsewhere; the cards themselves
are self-contained and don't depend on reading the rest of the
doc set. The agent uses these cards during P4 reviews and P5
project quizzes.

D22 is intentionally a gap (see D22 card below). 32 cards
present.

---

## Product & scope

### D1 — Product positioning
Unified tracker + local-first growth + social-as-core (community
features are the long-term value, deferred to v2).

**Rationale:** v1 is the local catalogue; v2 widens to a
Supabase-backed social media-tracker with community circles.

### D2 — v1 sharing deferred
Sharing requires a backend + identity + link generation. None
of that exists in v1. Adding it later is cheaper than removing
it from v1.

### D3 — v1 bottom nav (2 tabs in v1)
**Locked at: Home + Catalogue in v1** (per D-L3). Community
and Explore are v2. Nav bar ships in v1; 2 tabs only.

### D4 — Add-movie flow scope (5-state flow)
TMDB search + 3-col results grid + State C AddSheet (inline,
not `ModalBottomSheet`) + State D similar-titles multi-select
+ State E confirm with Collection/Bucketlist toggle +
per-item remove. Saved search sessions are deferred to v2.

---

## Data

### D5 — Hybrid data model
**`media_items` (base) + `*_details` (one per media type).**
Movies is the only v1 type. Shared fields (id, title, year, type,
status, rating, timestamps) on `media_items`; type-specific
fields on `*_details`. Queries across types hit `media_items`;
type-specific queries join to the detail table.

### D6 — Plain TEXT for `media_items.type`
No `CHECK` constraint, no SQL `ENUM`. Widening the type set
('movie' → 'tv_show', 'anime', etc.) is a **zero schema change**.
`EnumNameConverter<MediaType>` enforces the rule at the
Dart boundary.

### D7 — Status enum: 2 states (locked)
`MediaStatus.onBucketlist`, `MediaStatus.inCollection`. UI
label is `"Bucketlist"` (D-L13; canonicalization in D33).
`MediaStatus.onCollabLists` deferred to v2. Adding the 3
v2-only states (`currentlyConsuming`, `dropped`, `upcoming`)
in v1 would store values the UI can't surface — invisible QA
debt.

### D8 — Hub mapping (strict 2-card)
Collection HubCard = `MediaStatus.inCollection`. Bucketlist
HubCard = `MediaStatus.onBucketlist`. UI labels per wireframes
in `images/`.

---

## Tech stack

### D9 — TMDB client behind `MediaSearchClient`
`Dio` for v1; behind the `MediaSearchClient` interface:
`search({required String query, required MediaType mediaType})
→ Future<List<MediaSearchResult>>`. v2 widens the type set
to 6 (Movies + TV Shows + Anime + Video Games + Books + Comics
per the wireframe) and may swap to a regenerated client
(e.g., `openapi_generator`). The seam touches only the impl;
no UI changes.

### D10 — Material 3 + single seed + typography/spacing
Both light and dark themes shipped in v1 (D-L2). Both
derived from the same seed via
`ColorScheme.fromSeed(seedColor: …, brightness: Brightness.{light,dark})`.
Vivaldi-style customization stays v2+.

### D11 — `copyWith` source
Drift-generated in Phase 3a (`copyWith` on `MediaItemData`
etc.). Freezed wrapper is a future refactor option if sealed
unions become needed.

### D12 — v2 auth = Supabase
Postgres + Auth + RLS + Realtime + Storage. Open-source;
Postgres-portable; cheap at scale; RLS purpose-built for
community permissions. Migration to custom Python+Postgres
feasible (~2 weeks).

---

## Process

### D13 — Migration story
Additive migrations per phase via
`MigrationStrategy.onUpgrade`. Drift's `stepByStep` codegen
helper is the preferred path (`08-decisions-log.md` cross-ref
to `02-architecture.md` §Migrations for the worked example).
Existing user data preserved; each migration step has a sibling
test. (`I-1`.)

### D14 — Testing breadth (~150 lines v1 target)
Drift repo tests in Phase 3a; provider tests in Phase 4; widget
tests in Phase 5; optional integration test in Phase 6. The
test mirror rule (`02-architecture.md` §I-10) keeps `test/`
parallel to `lib/`.

---

## Cross-cutting decisions (locked during revision)

### D15 — Material import strategy
Use `package:flutter/material.dart` while on Flutter 3.44.x.
Migrate to `material_ui` / `cupertino_ui` first-party packages
when they release. Track flutter/flutter#184093.

### D16 — Image caching = `flutter_cache_manager` direct
Not `cached_network_image` (publisher `baseflow.com`; last
release was 23 months ago; rule-of-third-party-packages concern).
`flutter_cache_manager` provides the same disk-cache primitive
without a UI dependency. Direct use via
`Image.network(url, cacheManager: DefaultCacheManager())`.

### D17 — Material Symbols Rounded bundled as asset
License: **Apache License 2.0** (correcting prior
"Google-licensed" wording). The font is bundled at
`assets/fonts/MaterialSymbolsRounded.ttf`. The official
Flutter wrapper for Material Symbols is **not yet released**
as of plan-date; we consume the font directly via
`IconData(fontFamily: 'MaterialSymbolsRounded', fontPackage: 'media_tracker')`.

### D18 — Fonts = `google_fonts`
Source Serif 4 (display/headline) + Inter (title/body/label).
Reason: verified publisher `flutter.dev` — satisfies rule
"official packages only".

### D19 — Seed color (one, for both brightness modes)
`ColorScheme.fromSeed(seedColor: …, brightness: Brightness.{light,dark})`
derives both palettes. Two seeds = visual whiplash on theme
toggle. One seed is correct.

### D20 — Status enum v1 (restated)
Two states only: `MediaStatus.onBucketlist`,
`MediaStatus.inCollection`. UI label is "Bucketlist" (per
D-L13 / D33). The 3 v2-only states (`currentlyConsuming`,
`dropped`, `upcoming`) ship with the v2 detail/edit sheet that
surfaces them. Reason: storing values the UI can't surface
creates invisible QA debt; the trivial Drift migration cost is
not worth paying in v1.

### D21 — Add-movie idempotency
Repository runs `findByTmdbId` before `INSERT`; throws
`AlreadyInCollection` on hit. `SearchRepository` translates to
a `SnackBar` ("Already in your Collection" / "Already on your
Bucketlist"). The unique index on `movie_details.tmdb_id` is
the last-line defense. (`02-architecture.md` §I-11; `01-project-overview.md`
§Failure modes.)

### D22 — (intentionally skipped; gap left)
Historical numbering gap. Decision: ignore; do not
retrospectively fill. The numbering skipped from D21 to D23
during the planning pass; filling it now would require renaming
D23–D33 (10 cards), which has more downside than leaving the
gap. Future contributors: do not "fix" this by adding D22.

### D23 — Games provider = RAWG (v2 only)
Not IGDB. Reason: per [Twitch Developer Forum](https://discuss.dev.twitch.com/t/igdb-authentication-and-tokens-need-server-app/28394),
IGDB rate-limits at 4 req/s **per Client ID**, not per user.
Per-user Twitch OAuth doesn't give per-user rate-limit pools.
RAWG's 20k req/month quota is predictable and adequate for v2
scale; no OAuth dance, no proxy backend needed.

### D24 — Games attribution (RAWG ToS)
Every page displaying RAWG data or images must include an
active hyperlink back to RAWG (per [RAWG API ToS](https://rawg.io/apidocs)).
Implementation: per-card "View on RAWG" link on `MovieCard`-equivalent
for Games; or page-level footer. Locked when Games ships in v2.

### D25 — `source` + `imported_at` columns in v1
`media_items.source TEXT NOT NULL DEFAULT 'manual'`;
`media_items.imported_at DATETIME NULL`. Forward-compatible with
v2 import — no v2 schema migration needed. NULL `imported_at`
means manual; non-NULL means imported at that time. Columns
ship in v1's initial schema (`02-architecture.md` §4.1);
no v1 migration is required.

### D26 — `media_universe` on Supabase
Backend mega-database lives on Supabase Postgres, populated
by ETL pipeline from each provider. App queries via
PostgREST/Realtime; falls back to provider APIs on miss.
Strict separation from local `media_items`. Join key =
per-type external id columns. Supabase hosts both auth (D12
above) and the mega-DB.

### D27 — `resolveTitle` signature deferred to v2
`MediaSearchClient` (`I-11`) is the integration point; the
actual `resolveTitle(String) → ...` signature is locked at v2
import planning when the import pipeline shape is concrete.
v1 interface is forward-compatible.

### D28 — `MediaType` enum v1
Only `MediaType.movie` is valid in v1. `EnumNameConverter<MediaType>`
wired at the column level. Extension to `tv_show`, `anime`, etc.
in v2 via the converter; no schema change required for
`media_items.type` since it is plain TEXT (D6 above).

### D29 — Routing library = `go_router`
Verified publisher `flutter.dev`. Last release: 49 days ago,
v17.3.0. Reason: Flutter Favorite; feature-complete; declarative
routing. v1 ships 11 go_router routes per `02-architecture.md`
§go_router route table. v2 widens to nested child routes and
per-type deep links. Use `MaterialApp.router(...)` only — the
`MaterialApp(routerConfig: ...)` shortcut does NOT compile on
Flutter 3.44.x.

### D30 — `drift` package
`simonbinder.eu` (verified). Last release: 2 days ago, v2.34.3.
Reactive SQLite ORM for Flutter/Dart; v1 data layer
(`media_items` + `movie_details` tables). Flutter Favorite; MIT;
transitively pulls `sqlite3` 3.x. Phase 3a.

### D31 — `drift_dev`
`simonbinder.eu` (verified). Last release: 7 days ago, v2.34.5.
Dev-dependency for `drift`; codegen via `build_runner`. MIT.
Companion to D30; not in runtime deps. Phase 3a.

### D32 — `build_runner`
`tools.dart.dev` (verified; official Dart team). Last release:
2 days ago, v2.15.3. Build system for Dart code generation;
runs `drift_dev` codegen. BSD-3-Clause. Outputs `.g.dart` files
into `lib/`. Phase 3a.

### D33 — Status enum & UI label canonicalization (D-L13)
Renames to apply in v1-shipped code:

- `MediaStatus.onWatchlist` → `MediaStatus.onBucketlist`
- UI label `'Bucket List'` → `'Bucketlist'`
- File `bucket_list_page.dart` → `bucketlist_page.dart`

Source of truth: the wireframes in `images/`. Affected files:
`lib/features/catalogue/data/movie_status.dart` (the enum file),
`lib/features/catalogue/catalogue_page.dart` (the AppBar label),
`lib/features/catalogue/bucket_list_page.dart` →
`bucketlist_page.dart`. Renames cascade into this very decisions
log (D7, D20, D33) and into `01-project-overview.md` glossary
(status row). The rename is the reason `02-architecture.md` §I-2
is phrased with "onBucketlist" / "Bucketlist" — those are the
canonical v1 names per the wireframes.

---

## Cross-references

- Architecture, layers, invariants: `02-architecture.md`
- Conventions, framework patterns, file organization, styling
  rules: `03-code-standards.md`
- Design tokens (color, typography, spacing):
  `04-ui-context.md`
- Phase numbering, Done Definitions, per-step 5-sub-block
  templates: `05-phases.md`
- Programming concepts (per-step P1 blocks; the agent uses
  `webfetch` / `websearch` for current sources)
- Project framing, success criteria, glossary:
  `01-project-overview.md`
- Tutor's role & 5-step flow, Norms Ladder, git workflow:
  `00-tutor-workflow-rules.md`
- Session status: `07-progress-tracker.md`
- Repo-root charter: `/AGENTS.md`
