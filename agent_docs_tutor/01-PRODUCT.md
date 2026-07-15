# 01 — What We Are Building

## TL;DR

Media Tracker is a Flutter app that catalogs movies you've watched and want
to watch. v1 is **Movies only**, on **Android only**, **local-first** (no
account, no cloud, no backend). You add a movie by searching TMDB or by
typing the title manually; the app remembers it forever on your device.

The goal for v1 is to ship a usable movie catalogue that you yourself want
to use daily. The goal *behind* v1 is for you (the developer) to learn
Flutter, Drift, and Riverpod by building something real.

## What the app does

Open the app. See two big cards: **Collection** (movies you've watched) and
**To Consume** (movies you want to watch). Tap a card to see its list. Tap
**+** to add a movie — search TMDB or type it manually. Tap a movie to edit
its rating, status, or delete it. That's the whole app.

No login. No onboarding. No settings screen in v1.

## Why a "local-first" catalogue

Existing media-tracking apps (Letterboxd, MyAnimeList, Goodreads,
Backloggd) are siloed by format and require an account to read your own
data. Media Tracker starts from a single local catalogue and grows
organically. v1 has no cloud sync, no multi-device, no export — by
design. v2 will add Supabase-backed sync; until then, the SQLite file on
your device *is* your library.

## Who this is for (target user)

You, the developer, in your actual day-to-day use. The first acceptance
test is: do you open this app on your phone three days a week and log
movies? If yes, the v1 goal is met. Aspirational metrics:

- **G1:** open the app on ≥3 distinct days per week, averaged across the
  first 30 days post-install.
- **G2:** ≥30 movies logged into the catalogue within 60 days of first
  install.
- **G3:** 0 unhandled crashes across 30 consecutive daily uses, each
  containing ≥1 mutation (add, edit, rate, status change, or delete).

G1 and G2 have no measurement infrastructure in v1 (no analytics); they
are direction-setting targets, not acceptance gates. G3 is the one
measurable success criterion.

## The end-to-end flow

1. Launch the app — the **Catalogue hub** opens. No sign-up.
2. Tap the **+** floating action button.
3. The **Search page** opens with a text field.
4. Type a movie title; results populate from TMDB as you type (or after
   you hit Search, depending on the implementation).
5. Tap one result. The **AddSheet** opens for that movie.
6. In the AddSheet, choose status (`Collection` or `To Consume`) and a
   0–5 rating. Tap Save.
7. The Catalogue hub updates: the new movie appears on the matching card.
8. Tap a card to see its full list; tap any movie to edit rating, change
   status, or delete.

Target: this entire flow completes in a median of ≤30 seconds for an
experienced user.

## Failure modes (what happens when things go wrong)

| Scenario | What the user sees |
|---|---|
| First launch (zero movies in catalogue) | Both cards show empty-state placeholders |
| TMDB unreachable (no network / 5xx / timeout) | Search page degrades to a manual-entry form (Title, Year, Genre, Status, Rating). Save works through the same code path. |
| Adding the same TMDB movie twice | "Already in your Collection" or "Already on your To Consume list" snackbar; no duplicate row |
| `TMDB_API_KEY` missing at boot | App fails fast at construction (assertion in the `MediaSearchClient` constructor). This is a deployment prerequisite, not a runtime path. |
| Drift write fails (constraint violation) | `AlertDialog` with a generic message; row not created |

## Non-functional requirements

- **Crash-free:** 0 unhandled exceptions across 30 consecutive daily uses
  each containing ≥1 mutation.
- **Accessibility baseline:** TalkBack-compatible semantics labels on all
  interactive elements; minimum 48dp touch targets; WCAG 2.2 AA color
  contrast for body text.
- **Cold launch:** ≤2 seconds to interactive on the test device
  (Android emulator, API 36).
- **Persistence durability:** catalogue data persists across full app
  termination and device reboot.

## Success criteria (measurable in v1)

1. Cold launch reaches the Catalogue hub in ≤2 seconds on the test device.
2. End-to-end add-movie flow (FAB → typed TMDB query → result tap →
   AddSheet → Save) completes in a median of ≤30 seconds.
3. Catalogue data persists across full app termination: force-stop the
   app, relaunch, every movie is still there.
4. Catalogue data persists across device reboot.
5. TMDB unreachable: Search page degrades to manual-entry form; Save
   works.
6. Adding the same TMDB movie a second time does not create a duplicate
   row; user sees "Already in your Collection" or "Already on your To
   Consume list."
7. (v1.1+) Toggling dark mode at the OS level switches to the light
   variant. *In v1, the app is dark-only and does not respond to OS
   theme changes.* Both light and dark palettes are derived from the
   same seed color so this is purely an OS-handler addition in v1.1.
8. Across 30 consecutive daily uses each containing ≥1 mutation, the app
   produces 0 unhandled exceptions.

## In scope (v1)

- Movies catalogue only
- Android-only build
- Single device, single user; no account, no cloud sync
- Local-first persistence with offline search and add-movie fallback
- TMDB read-only search via API key in `lib/secrets.dart` (gitignored)
- 2-state status enum: `onWatchlist`, `inCollection`
- Dark Material 3 theme derived from a single seed color (light palette
  also derived but unused in v1)
- Single-page app (no bottom nav, no drawer)

## Out of scope (v1)

- All non-Movies media types (TV, Anime, Books, Games, Podcasts,
  Comics, Documentaries, K-Drama, Cartoons, Music videos)
- Auth, multi-user accounts, cloud sync, backend
- Sharing, community circles, recommendations, swipe-based matching
- PDF or web-link export
- Similar-media discovery
- Saved search sessions or history
- Bottom nav, drawer, tabs, multi-page navigation
- iOS, web, desktop targets
- Custom user themes
- Push notifications
- Localization beyond English (single locale, hardcoded strings)
- Light mode UI (dark-only in v1)

## Assumptions

- **Platform:** Android only. No iOS, web, desktop builds.
- **Offline posture:** Offline-first. App works with no network; TMDB is
  the only network dependency and it has a manual-entry fallback.
- **Tenancy:** Single-tenant. One user per device; no auth.
- **Locale:** English only. Hardcoded strings; no `intl` ARB files.
- **Media mix:** Movies only in v1.
- **Storage:** Local SQLite, single device only.
- **TMDB key:** Provided out-of-band (env var at build, or
  `lib/secrets.dart` for dev, gitignored).
- **Test device:** Android emulator on API 36.

## v2 forward-look (one-paragraph, for context only)

v1 ships with no backend, no auth, no cross-device sync, and no
mega-database. v2 (out of scope for v1 work but planned) introduces
**Supabase** for auth + Postgres + RLS + Realtime; a backend
`media_universe` mega-database on Supabase Postgres, populated by an ETL
pipeline from each provider (TMDB, RAWG, Open Library, AniList, Apple
Podcasts, Comic Vine); and an import pipeline from external platforms
(Letterboxd CSV, iMDB ratings, MAL, Trakt, Backloggd, Steam, Spotify,
Goodreads). The `source` and `imported_at` columns added in v1 carry
provenance from day one.

For v2/v3 phase planning, see `04-PHASE-GUIDE.md` §"v2 phase slots"
and §"v3 phase slots." Phase numbering and Done Definitions for v2
and v3 come from `PROJECT_PLAN.md` §13 / §14 (user-only). The locked
v2 decisions are in `03-STACK-DECISIONS.md` §"v2-only decisions" (D12
through D27).

## Glossary (product terms)

See also the technical glossary in `06-CONCEPTS-AND-GLOSSARY.md`.

- **media_item** — the central entity tracked by the app. In v1,
  always a movie. Stored in `media_items`. The user-facing term is
  "movie" but the data model uses `media_item` because v2 will widen.
- **status** — locked lifecycle enum. v1 has 2 values: `onWatchlist`
  and `inCollection`. The user-facing labels are "To Consume" and
  "Collection."
- **hub** — the Catalogue landing page (`CataloguePage`) showing two
  HubCards. Distinct from a list — it never shows individual items,
  only cards pointing at filtered lists.
- **HubCard** — one of the two big cards on the hub page.
- **AddSheet** — modal bottom sheet for adding or editing one media item.
- **EditSheet** — same UI as AddSheet but prefilled with the existing
  movie's data.
- **TMDB** — The Movie Database, the external movie metadata provider
  accessed read-only in v1.

## Cross-references

- Architecture and the 14 invariants: `02-ARCHITECTURE.md`
- Stack decisions D1–D28: `03-STACK-DECISIONS.md`
- Phase-by-phase build: `04-PHASE-GUIDE.md`
- UI tokens: `05-DESIGN-SYSTEM.md`
- Concepts reference: `06-CONCEPTS-AND-GLOSSARY.md`
- Tutor role and Norms Ladder: `07-TUTOR-PROTOCOL.md`