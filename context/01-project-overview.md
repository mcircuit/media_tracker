# 01 — Project Overview

## TL;DR

Media Tracker is a Flutter app that catalogues media the user
has consumed or wants to consume. v1 is **Movies only**, on
**Android only**, **local-first** (no account, no cloud, no
backend). The user adds a movie by searching TMDB or by typing
the title manually; the app remembers it forever on the device.

The goal for v1 is to ship a usable movie catalogue that the
user themselves wants to open daily. The goal behind v1 is for
the user to learn Flutter, Drift, and Riverpod by building
something real.

## One-sentence positioning

Track, organize, and remember every piece of media the user has
consumed or wants to consume in one unified library — Movies
in v1; TV Shows, Anime, Video Games, Books, and Comics in v2.

## Primary user and core need

**v1:** the developer themselves. A self-described media omnivore
who currently bounces between Letterboxd, MyAnimeList, Goodreads,
Backloggd, and podcast apps. Core need: one place that holds
every kind of media and grows with them.

**v2:** the user's close circles — family, friends — who want
to see recommendations and send them back.

## Goals (numbered)

1. **Ship a usable catalogue** the user actually wants to open
   on phone — one tap to add a movie they just watched, one tap
   to edit, no ceremony.
2. **Learn Flutter, Drift, and Riverpod by building something
   real**, end-to-end, including the integration pain (background
   isolates, type-safe enums at the boundary, `MediaSearchClient`
   seam) that a tutorial glosses over.
3. **Lay a clean foundation** that v2 features (auth, sharing,
   mega-DB, import pipelines) plug into without rewrites of v1
   code paths.

## Features (categorized)

| Category | Features |
|---|---|
| **Core CRUD** | Add a movie · Edit status / rating / move between Collection and Bucketlist · Delete a movie (from EditSheet) |
| **Catalog browsing** | Catalogue hub (2 HubCards: Collection, Bucketlist) · Collection / Bucketlist list pages with Statistics block · Inline Search field (filters the user's database) · Genre-only Media Filter sheet |
| **Discovery** | TMDB search (full-page Search Page, 5 states A→E) · Manual-entry form (when TMDB is unreachable) · Similar-titles multi-select (Search Page State D) · Final confirm with Collection/Bucketlist toggle + remove (State E) |
| **Persistence** | Drift-backed local SQLite (`media_items` + `movie_details` tables) · `flutter_cache_manager` poster cache · Both light and dark themes shipped with `themeMode: ThemeMode.system` · Material Symbols Rounded font bundled as an asset (Apache License 2.0) · Source Serif 4 + Inter via `google_fonts` |
| **App shell (foundation)** | `go_router` with 11 routes · `MaterialApp.router` with both palettes · `AppScaffold` widget wrapping every page · Hamburger Menu overlay with 5 stub routes · 2-tab bottom nav (Home, Catalogue) · The 14 invariants enforced by code review (see `02-architecture.md`) |

## v1 surfaces (wireframe-aligned)

The v1 app has six primary surfaces:

| Surface | Route | Purpose |
|---|---|---|
| Landing Page | `/` | entry point; Movies tile only in v1 |
| Home Page | `/home` | Watchlist carousel; bottom-nav tab 1 |
| Catalogue Page | `/catalogue` | hub; Collection + Bucketlist HubCards; bottom-nav tab 2 |
| Collection Page | `/catalogue/collection` | Movies the user has consumed |
| Bucketlist Page | `/catalogue/bucketlist` | Movies the user wants to consume (filter by `MediaStatus.onBucketlist`) |
| Search Page | `/search?q=<query>&type=movie` | 5-state flow A→B→C→D→E for adding a movie |

Plus a Hamburger Menu overlay (5 items: Profile, Media Type,
Settings, Help, About). See `02-architecture.md` §"go_router
route table" for the full route list.

## First-session flow (v1, no sign-up)

1. Launch app → **Landing Page** opens immediately. Movies tile
   is the only tappable surface; below it, the text
   "Next Media Type: TV Shows — coming soon!" is displayed.
2. Tap the Movies tile → **Home Page** opens, showing the
   Watchlist horizontal carousel. The Collab and Upcoming
   carousels are deferred to v2.
3. The bottom nav has 2 tabs in v1: **Home** and **Catalogue**.
4. Tap the **Catalogue** tab → **Catalogue Page** opens, the hub
   with 2 large HubCards (Collection, Bucketlist).
5. Tap the **Collection** HubCard → **Collection Page** opens
   (Statistics block + Search field + Media Filter button +
   3-col grid + FAB).
6. Tap the **Bucketlist** HubCard → **Bucketlist Page** opens
   (mirror of Collection Page; data filtered to
   `MediaStatus.onBucketlist`).
7. Tap the **+** FAB on Home, Collection, or Bucketlist →
   **Search Page** opens as a full-page route at
   `/search?q=<query>&type=movie`. 'X' close button at top
   right; exit-confirm prompt at State C and State E.
8. Type a movie title → TMDB returns results in a 3-col grid
   below the search bar (Search Page **State B**).
9. Tap a result → the status toggle + rating screen for the
   selected title appears inline in the Search Page (**State C**).
   Two bottom buttons: **Done** (saves the single title and
   exits) or **Explore Similar Titles** (continues to State D).
10. If continuing, similar titles populate the screen (**State D**).
    Long-press to multi-select; tap **Add** at the bottom.
11. The selected titles appear in a confirmation screen with a
    Collection / Bucketlist toggle at the top and per-item
    remove (**State E**). Tap **Add to <Destination>** at the
    bottom to save all selections to the toggle's destination
    and exit. The label updates reactively as the user toggles.
12. Returning to the FAB's origin page → the new movie(s) appear
    on the matching HubCard or list.

Cross-reference: `05-phases.md` §"Phase 5 — Full CRUD UI" for
the implementation breakdown.

## Failure modes (what happens when things go wrong)

| Scenario | What the user sees |
|---|---|
| First launch (zero movies in catalogue) | Both HubCards show empty-state placeholders |
| TMDB unreachable (no network / 5xx / timeout) | Search Page degrades to a manual-entry form (Title, Year, Genre, Status, Rating). Save works through the same code path. |
| Adding the same TMDB movie twice | "Already in your Collection" or "Already on your Bucketlist" snackbar; no duplicate row |
| `TMDB_API_KEY` missing at boot | App fails fast at the `MediaSearchClient` constructor (assert). Documented as a deployment prerequisite. |
| Drift write fails (constraint violation) | `AlertDialog` with a generic message; row not created |

## Non-functional requirements

- **Crash-free:** 0 unhandled exceptions across 30 consecutive
  daily uses each containing ≥1 mutation.
- **Accessibility baseline:** TalkBack-compatible semantics
  labels on all interactive elements; minimum 48dp touch
  targets; WCAG 2.2 AA color contrast for body text.
- **Cold launch:** ≤2 seconds to the Landing Page on the test
  device (Android emulator, API 36).
- **Persistence durability:** catalogue data persists across
  full app termination and device reboot.

## Success criteria (measurable in v1)

1. **Cold launch reaches the Landing Page in ≤2 seconds.**
2. *(secondary)* Cold launch → user taps Movies → Catalogue
   Page rendered in ≤3 seconds end-to-end.
3. End-to-end add-movie flow (FAB → TMDB query → result tap →
   State C in the Search Page → Save) completes in a median of
   ≤30 seconds.
4. Catalogue data persists across full app termination.
5. Catalogue data persists across device reboot.
6. TMDB unreachable: Search Page degrades to manual-entry
   form; Save works.
7. Adding the same TMDB movie a second time does not create a
   duplicate row; user sees "Already in your Collection" or
   "Already on your Bucketlist" snackbar.
8. **OS dark-mode toggle switches to dark palette; OS
   light-mode toggle switches to light palette;** both
   derived from the same seed color via
   `ColorScheme.fromSeed(seedColor: …, brightness: Brightness.{light,dark})`.
9. Across 30 consecutive daily uses each containing ≥1
   mutation, the app produces 0 unhandled exceptions.

## In scope (v1)

- Movies catalogue only
- Android-only build
- Single device, single user; no account, no cloud sync
- Local-first persistence with offline search and add-movie
  fallback
- TMDB read-only search via API key in `lib/secrets.dart`
  (gitignored)
- 2-state status enum (`MediaStatus.onBucketlist`,
  `MediaStatus.inCollection`)
- Material 3 with both light and dark themes shipped in v1;
  system-handler (`themeMode: ThemeMode.system`) decides
- Multi-page app (Landing, Home, Catalogue hub, list pages,
  Search Page; 2-tab bottom nav)

## Out of scope (v1)

- All non-Movies media types (per wireframe: TV Shows, Anime,
  Video Games, Books, Comics come in v2)
- Auth, multi-user accounts, cloud sync, backend
- Sharing, community circles, recommendations, swipe-based
  matching
- PDF or web-link export
- Similar-media discovery (handled in Search Page State D only)
- Bottom-nav Community and Explore tabs (added in v2)
- iOS, web, desktop targets
- Custom user themes (Vivaldi-style)
- Push notifications
- Localization beyond English
- Theme switch toggle inside the app (system-handler only;
  no in-app override)

## v2 forward-look (one-paragraph, for context only)

v1 ships with no backend, no auth, no cross-device sync, no
mega-database. v2 introduces **Supabase** for auth + Postgres +
RLS + Realtime; widens the type set from Movies to TV Shows,
Anime, Video Games, Books, and Comics (per the wireframe); a
backend `media_universe` mega-database on Supabase Postgres
populated by an ETL pipeline from each provider (TMDB, RAWG,
Open Library, AniList, Comic Vine); and an import pipeline from
external platforms (Letterboxd CSV, iMDB ratings, MAL, Trakt,
Backloggd, Steam, Spotify, Goodreads). The `source` and
`imported_at` columns added in v1 carry provenance from day one.

For v2/v3 phase planning, see `05-phases.md` §"v2 phase slots"
and §"v3 phase slots". Phase numbering and Done Definitions
live in `05-phases.md`. Locked v2 decisions live in D-cards
D12, D23, D24, D25, D26, D27 (`08-decisions-log.md`).

## Glossary mini (project terms)

| Term | Meaning |
|---|---|
| `media_item` | The central entity tracked by the app. In v1, always a Movie. Stored in `media_items`. |
| `status` | The 2-state enum (`MediaStatus.onBucketlist`, `MediaStatus.inCollection`). UI labels: "Bucketlist" and "Collection". Canonical naming locked in the project's Decisions log (`08-decisions-log.md` D33). |
| `hub` | The Catalogue Page. Distinct from a list — the hub never shows individual items, only HubCards. |
| `HubCard` | One of the two large cards on the hub page. |
| `AddSheet` | **State C** of the Search Page. Status toggle + rating. Inline, not a `ModalBottomSheet`. |
| `EditSheet` | `ModalBottomSheet` from `MovieCard.onTap`. Same fields as AddSheet, prefilled. Delete action. |
| `TMDB` | The Movie Database. Read-only metadata source in v1. |
| `AppShell` | The persistent chrome around every page. `AppScaffold` widget in `lib/shared/`. |

## Cross-references

- Phase numbering, Done Definitions: `05-phases.md`
- System architecture & invariants: `02-architecture.md`
- D-cards (locked decisions): `03-code-standards.md`
- Design tokens (color, typography, spacing): `04-ui-context.md`
- Per-step work: `05-phases.md`
- Programming concepts (agent uses `webfetch` / `websearch` for current sources)
- Current status: `07-progress-tracker.md`
- Tutor's role & 5-step flow: `00-tutor-workflow-rules.md`
- Repo-root charter: `/AGENTS.md`
