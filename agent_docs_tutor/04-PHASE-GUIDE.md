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

## Phase entries

Each phase below has its title and Done Definition populated from
`PROJECT_PLAN.md` §13 (Build Order) and §14 (Done Definitions). The
Done Definitions are verbatim from §14 except for Phase 2 (no U#;
derived from §13's "Produces" column). When you start a phase, the
tutor references this file plus §13/§14 in `PROJECT_PLAN.md` for the
authoritative content.

### Phase 0 — Tooling ✅ Done

**From PROJECT_PLAN.md §13:** `flutter doctor` clean; emulator
`emulator-5554` online; default counter app launched.

**Done Definition (U1) from §14:**
- `flutter doctor` clean
- emulator-5554 online
- default counter app launched

### Phase 1 — Widget fundamentals + static catalogue hub ✅ Done

**From PROJECT_PLAN.md §13:** Hardcoded Movies, MovieCard, HubCard,
hub page (Collection → Collection / Bucketlist).

**Done Definition (U2) from §14:**
- `lib/features/catalogue/data/movie.dart` — value object
- `lib/features/catalogue/data/sample_movies.dart` — 5 `const Movie(...)`
  entries + `collectedMovies` / `bucketListMovies` getters
- `lib/features/catalogue/widgets/movie_card.dart`
- `lib/features/catalogue/widgets/hub_card.dart`
- `lib/features/catalogue/my_collection_page.dart`
- `lib/features/catalogue/bucket_list_page.dart`
- `lib/features/catalogue/catalogue_page.dart` + `main.dart` rewrite

**Verify:** launch → Catalogue hub shows → tap Collection card → 3
movies visible → back → tap Bucket List card → 2 movies visible.

**Note on label amendment:** mid-phase, the second HubCard label was
renamed from `'To Consume'` to `'Bucket List'`, the underlying getter
`toConsumeMovies` was renamed to `bucketListMovies`, and the page file
was renamed from `to_consume_page.dart` to `bucket_list_page.dart`.
The Done Definition above mirrors §14 with the filename rename; the
shipped code uses `'Bucket List'`. The `MediaStatus.onWatchlist` enum
value is unchanged.

**Minor terminology mismatch:** §13 says `Bucketlist` (single word);
the shipped code uses `Bucket List` (two words) and the file is
`bucket_list_page.dart` (snake_case, Dart convention). §13 is the
high-level overview; code and file names follow Dart conventions.
If you want strict alignment, update `PROJECT_PLAN.md` §13 and §14 —
your call, not Phase 1 cleanup.

**Per-step summary** (full prerequisite-check + review blocks were
skipped per the user's "skip prereq quizzes for all of Phase 1"
decision logged in the Session 1 note):

- 1.1 — `lib/app/theme.dart` + `lib/main.dart` rewrite: dark
  `Material 3` via `ColorScheme.fromSeed(seedColor: Color(0xFFA8C5FF))`.
- 1.2 — `data/movie.dart` + `data/movie_status.dart`: `Movie` value
  object (id/title/year/genre/rating?/status), `MediaStatus` enum.
- 1.3 — `data/sample_movies.dart`: 5 const entries + `collectedMovies`
  + `bucketListMovies` getters.
- 1.4 — `widgets/movie_card.dart`: `Card` + `ListTile` with
  `title`/`subtitle`/`trailing` (status pill).
- 1.5a — `widgets/hub_card.dart`: `Card` + `Stack` +
  `Positioned.fill(leading)` + centered `Text(label)`.
- 1.5c — `my_collection_page.dart`: `Scaffold` + `AppBar` +
  `ListView.builder`.
- 1.5d — `bucket_list_page.dart`: mirror of 1.5c with
  `bucketListMovies`.
- 1.5b — `catalogue_page.dart`: `Scaffold` + `Padding(all 24)` +
  `Column` of two `Expanded(HubCard)` + image assets wired.
- 1.5e — `main.dart` final pass: `home: const CataloguePage()`,
  title `'Media Tracker'`.

**Invariants verified during review:** I-2 (status is the two-value
enum), I-7 (no `setState` in any widget; all `StatelessWidget`),
I-12 (Material imports from `package:flutter/material.dart` only),
I-8/I-9 relaxed v1-wide.

**Drift from `05-DESIGN-SYSTEM.md` §9 "Hub page" pattern:**
`floatingActionButton` absent and `appBar: AppBar(title: Text('Your
Catalogue'))` present on `CataloguePage` — both deviations from the
locked spec, user-accepted, not blockers.

### Phase 2 — App shell ⏳ Pending

**From PROJECT_PLAN.md §13:** App stays single-page (1 tab) for v1;
`go_router` setup for future routing needs; `MediaSearchClient`
interface defined.

**Done Definition from §14:** *(no U# — Phase 2's deliverables are
fold-infrastructure for later phases. Derived from §13's "Produces"
column. The `MediaSearchClient` interface is locked here; the Dio
implementation, DTOs, and search repo live in Phase 3b's U4.)*

**Verify:** `go_router` is configured with a single `/` route for the
Catalogue hub. `MediaSearchClient` is an abstract class with the
locked `search({required String query, required MediaType mediaType})`
signature. No `dio` import under `lib/features/`.

### Phase 3a — Drift data model ⏳ Pending

**From PROJECT_PLAN.md §13:** `AppDatabase` with `schemaVersion = 1`;
`media_items` + `movie_details`; 2-state enum (`onWatchlist`,
`inCollection`) as TEXT; `EnumNameConverter<MediaType>` and
`EnumNameConverter<MediaStatus>` wired at column level (see §4.4);
DAOs; Drift repository tests added here.

**Done Definition (U3) from §14:**
- `lib/data/database.dart` — `AppDatabase extends GeneratedDatabase`,
  `schemaVersion = 1`
- `lib/data/tables/media_items.dart` — `EnumNameConverter<MediaType>`
  and `EnumNameConverter<MediaStatus>` wired at the column level
  (see §4.4)
- `lib/data/tables/movie_details.dart` — joined by `media_item_id`;
  unique partial index on `tmdb_id`
- `MigrationStrategy.onCreate` builds both tables + indexes
- `MigrationStrategy.onUpgrade` includes additive migration steps
  (placeholder for v2 — no steps needed in v1)
- `lib/data/daos/movie_dao.dart` — typed queries, including
  `findByTmdbId(int)` for idempotency (§7.1)
- 4-5 repository tests: insert, query, delete, migration v1→v2,
  `findByTmdbId` returns existing row

### Phase 3b — TMDB search interface ⏳ Pending

**From PROJECT_PLAN.md §13:** `MediaSearchClient` abstract interface
(locked signature); `DioMediaSearchClient` impl with API-key
interceptor; TMDB DTOs; `SearchRepository`; idempotency on add with
`AlreadyInCollection` exception (see §7.1); offline fallback
(manual-entry form); API key in `lib/secrets.dart`.

**Done Definition (U4) from §14:**
- `lib/core/http/media_search_client.dart` — abstract interface with
  locked signature: `Future<List<MediaSearchResult>> search({required String query, required MediaType mediaType})`
- `lib/core/http/dio_media_search_client.dart` — Dio-backed v1 impl
  with API-key interceptor; routes `/search/movie` and `/search/tv`
  based on `mediaType`
- `lib/core/http/tmdb/dtos.dart` — TMDB response DTOs
- `lib/data/repositories/errors.dart` — `AlreadyInCollection` exception
  type
- `lib/data/repositories/search_repository.dart` — wraps
  `MediaSearchClient`; translates `AlreadyInCollection` into
  user-facing snackbar
- API key source: `lib/secrets.dart` (gitignored) or env var
- Offline fallback: manual-entry form when `MediaSearchClient` returns
  `MediaSearchUnavailable`
- `MediaSearchClient` is the integration point for v2's `resolveTitle`
  import primitive (free-text title → `tmdb_id` lookup). v1 interface
  signature is forward-compatible; no v1 refactor needed.

### Phase 4 — Riverpod over drift ⏳ Pending

**From PROJECT_PLAN.md §13:** `databaseProvider`,
`moviesListProvider`, `searchProvider`; CRUD via providers; provider
tests added here.

**Done Definition (U5) from §14:**
- `lib/providers/database_provider.dart`
- `lib/providers/movies_list_provider.dart`
- `lib/providers/search_provider.dart`
- 2-3 provider tests via `ProviderContainer.test`

### Phase 5 — Full CRUD UI (Movies only) ⏳ Pending

**From PROJECT_PLAN.md §13:** Add / Edit / Delete on Movies; TMDB
search page; results grid; AddSheet; widget tests. **No TV Shows
mirror in v1.**

**Done Definition (U6) from §14:**
- SearchPage → SearchResultsPage → AddSheet flow
- Edit sheet (tap MovieCard → EditSheet)
- Delete confirmation
- Pull-to-refresh scaffold
- Offline behavior verified manually
- 3-4 widget tests

### Phase 6 — Polish ⏳ Pending

**From PROJECT_PLAN.md §13:** Material 3 theme + custom seed +
typography ramp; empty states; offline UX; accessibility; error
states; optional integration test.

**Done Definition (U8) from §14:**
- Material 3 theme finalized
- Single seed color locked; dark theme shipped in v1, light palette
  derived from the same seed via `ColorScheme.fromSeed(seedColor: …,
  brightness: Brightness.light)` but not shipped
- Typography ramp: Source Serif 4 (display/headline) + Inter
  (title/body/label) via `google_fonts`
- Material Symbols Rounded font bundled as asset;
  `IconData(fontFamily: 'MaterialSymbolsRounded', fontPackage: …)`
  used everywhere
- Spacing scale locked (8px baseline, 12px card padding, 16px gaps,
  12dp card radius)
- Dark theme verified
- Empty-state widgets
- Accessibility pass (semantics labels, focus order)

### Phase 7 — Wrap-up ⏳ Pending

**From PROJECT_PLAN.md §13:** `ROADMAP.md` documents v2 features;
Supabase plan; multi-user migration plan; one retrospective on locked
decisions vs. hunches.

**Done Definition (U9) from §14:**
- `ROADMAP.md` documents v2 features + Supabase plan + migration plan
- One retrospective on locked decisions vs. original hunches

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