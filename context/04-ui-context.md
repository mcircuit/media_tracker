# 04 — UI Context

## TL;DR

This file is the **design-token reference** the tutor agent
cites during code review (P4) and design quizzes (P2/P5). It is
the source-of-truth for every visual decision in v1's UI:
color tokens, typography, spacing, border radius, motion, and
iconography. **Every color decision is a named token** — the
agent never types a hex value inline.

Layout patterns describe the **actual structure** of the v1 app:
eight distinct patterns covering Landing Page, Home, the
Catalogue hub, Collection / Bucketlist list pages, the
five-state Search Page, the Modal Sheet (EditSheet + Media
Filter), the BottomNavigationBar, and the Hamburger Menu
overlay.

The visual language is anchored on the seeded `ColorScheme`
(per `02-architecture.md` §App Shell) — the doc lists every
token name the v1 widgets touch, with light-and-dark hex
values that approximate the seed output. The tutor verifies
exact hex against `flutter run` output if a question hinges
on a precise value; the names stay canonical regardless.

---

## 1. Visual language

### 1.1 Color tokens (v1-active, ~13)

The full M3 palette exposes ~25 semantic color roles. v1
widgets touch 13 of them. The remaining 12 are unused in v1
and gain v2-only consumers. (The full palette is documented
in Material 3's spec; v2 phases that introduce new surfaces will
add new tokens to this section.)

| Token | M3 Role | Light hex (≈) | Dark hex (≈) | Used for |
|---|---|---|---|---|
| `color/background` | `colorScheme.background` | `#F5F7FB` | `#0E1014` | Scaffold background |
| `color/surface` | `colorScheme.surface` | `#FFFFFF` | `#171A21` | Cards, sheets, AppBar |
| `color/surface-variant` | `colorScheme.surfaceContainerHighest` | `#E2E4EA` | `#22262F` | Chips, dividers |
| `color/on-surface` | `colorScheme.onSurface` | `#1A1A1F` | `#E3E2E6` | Primary text |
| `color/on-surface-variant` | `colorScheme.onSurfaceVariant` | `#45464E` | `#C5C6D0` | Secondary text, captions |
| `color/primary` | `colorScheme.primary` | `#3D5AA8` | `#A8C5FF` | "Bucketlist" badge, filled buttons, links |
| `color/on-primary` | `colorScheme.onPrimary` | `#FFFFFF` | `#0A2A6B` | Text on primary surfaces |
| `color/primary-container` | `colorScheme.primaryContainer` | `#DCE1FF` | `#284777` | FAB tonal fill, rating pills |
| `color/on-primary-container` | `colorScheme.onPrimaryContainer` | `#001847` | `#D6E2FF` | Text on primary container |
| `color/secondary` | `colorScheme.secondary` | `#B43A1C` | `#FFB78F` | "Collection" badge, rating stars (amber) |
| `color/error` | `colorScheme.error` | `#BA1A1A` | `#FFB4AB` | Validation errors |
| `color/error-container` | `colorScheme.errorContainer` | `#FFDAD6` | `#93000A` | `AlertDialog` body fill |
| `color/on-error-container` | `colorScheme.onErrorContainer` | `#410002` | `#FFDAD6` | Text on error container |
| `color/outline` | `colorScheme.outline` | `#767680` | `#90909A` | Borders, dividers |
| `color/scrim` | `colorScheme.scrim` | `#000000` | `#000000` | Modal backdrop |

**Hex values are approximate.** The seed color
(deep blue / indigo, ~`Color(0xFF3959A8)`) generates these via
`ColorScheme.fromSeed(seedColor: ..., brightness: ...)`. The
exact hex the runtime produces may differ by a few units;
re-pinned at Phase 6 polish. **The tokens stay canonical** —
the agent references `Theme.of(context).colorScheme.<token>`
in code, never hardcoded hex.

**Rule:** every widget reads color via `Theme.of(context).colorScheme.<token>`.
The hex table above is for the tutor's quiz and design-review reference only.

**Unused in v1** (listed so the agent doesn't reinvent them):
`color/secondary-container`, `color/on-secondary`,
`color/on-secondary-container`, `color/tertiary`,
`color/on-tertiary`, `color/tertiary-container`,
`color/on-tertiary-container`, `color/on-error`,
`color/shadow`, `color/outline-variant`. (v2 widens here.)

### 1.2 Typography

v1 uses **two font families** loaded via `google_fonts` (D18 in
`08-decisions-log.md`):

- **Source Serif 4** (Display + Headline roles) — editorial weight
  for movie titles.
- **Inter** (Title + Body + Label roles) — UI legibility.

Material 3 exposes 15 typography roles. The full table:

| Role | Font | Weight | Size (sp) | Line height (sp) | Letter spacing |
|---|---|---|---|---|---|
| `displayLarge` | Source Serif 4 | 400 | 57 | 64 | -0.25 |
| `displayMedium` | Source Serif 4 | 400 | 45 | 52 | 0 |
| `displaySmall` | Source Serif 4 | 400 | 36 | 44 | 0 |
| `headlineLarge` | Source Serif 4 | 600 | 32 | 40 | 0 |
| `headlineMedium` | Source Serif 4 | 600 | 28 | 36 | 0 |
| `headlineSmall` | Source Serif 4 | 600 | 24 | 32 | 0 |
| `titleLarge` | Inter | 500 | 22 | 28 | 0 |
| `titleMedium` | Inter | 500 | 16 | 24 | 0.15 |
| `titleSmall` | Inter | 500 | 14 | 20 | 0.1 |
| `bodyLarge` | Inter | 400 | 16 | 24 | 0.5 |
| `bodyMedium` | Inter | 400 | 14 | 20 | 0.25 |
| `bodySmall` | Inter | 400 | 12 | 16 | 0.4 |
| `labelLarge` | Inter | 500 | 14 | 20 | 0.1 |
| `labelMedium` | Inter | 500 | 12 | 16 | 0.5 |
| `labelSmall` | Inter | 500 | 11 | 16 | 0.5 |

**Role-to-use convention:**

- `display*` / `headline*` (Source Serif 4): page titles, hero
  numbers (e.g., hero movie title in expanded detail, large
  statistics), ListTile-style headlines on the Hub. **Used for
  movie titles and section heading text in v1.**
- `title*` (Inter): card titles, AppBar text, modal headers.
- `body*` (Inter): paragraph content, descriptions, list rows.
  For v1 list rows (`MovieCard.onTap`), use `bodyMedium`.
- `label*` (Inter): buttons, chips, captions, badges. Status
  badges in v1 use `labelMedium` plus a `color/secondary` or
  `color/primary` background per the Collection/Bucketlist
  status mapping.

### 1.3 Spacing scale

8 px grid baseline (5 tokens + 2 dp sub-grid escape):

| Token | Value (dp) | Use |
|---|---|---|
| `space/xxs` | 2 | Sub-grid icon-to-text gap inside chips and dense lists. **Never** for primary spacing. |
| `space/xs` | 4 | Tight stacks, icon padding. |
| `space/sm` | 8 | Inline padding within chips; default gap between sibling elements. |
| `space/md` | 16 | Card inner padding; gap between cards. |
| `space/lg` | 24 | Page margins; gap between major regions. |

**Code reference:**

```dart
const SizedBox(height: 16)        // space/md
const SizedBox(height: 8)         // space/sm
// etc.
```

### 1.4 Border radius scale

4 tokens, mapped to specific contexts:

| Context | Token | Value (dp) |
|---|---|---|
| `Chip`, `SnackBar`, small `FilledButton` | `radius/sm` | 8 |
| `Card` (MovieCard, HubCard), `ListTile`, `TextField` | `radius/md` | 12 |
| `AlertDialog`, `ModalBottomSheet` (EditSheet, Media Filter) | `radius/lg` | 20 |
| `FloatingActionButton`, `IconButton`, pill-shaped buttons | `radius/full` | 9999 |

### 1.5 Motion

3 durations, each tied to a usage:

| Token | Duration | Easing | Use |
|---|---|---|---|
| `motion/fast` | 150 ms | `Curves.easeInOutCubic` | Button press ripple, snackbar enter/exit |
| `motion/default` | 250 ms | `Curves.easeInOutCubic` | Page transitions, sheet open/close |
| `motion/slow` | 400 ms | `Curves.easeInOutCubicEmphasized` | Hero animations, large sheet dismissal |

**Motion-reduce:** honor `MediaQuery.disableAnimations`
(OS "reduce motion" toggle). Substitute `Duration.zero` for
`motion/default` and `motion/slow`. Keep `motion/fast` so
button ripples still feel responsive.

### 1.6 Accessibility tokens

| Token | Value | Rule |
|---|---|---|
| `a11y/contrast/body` | 4.5:1 | WCAG 2.2 AA on `bodyLarge`, `bodyMedium`, `bodySmall` |
| `a11y/contrast/large` | 3:1 | WCAG 2.2 AA on `display*`, `headline*`, `titleLarge` |
| `a11y/touch-target/min` | 48 dp | `IconButton`, `FilledButton`, `FloatingActionButton`, `Chip.checkbox` |
| `a11y/focus-ring/width` | 2 dp | Outline ring on focused interactive elements |
| `a11y/focus-ring/color` | `color/primary` | Visible focus indicator |
| `a11y/focus-ring/offset` | 2 dp | Distance from element edge |
| `a11y/semantics/required` | `true` | Every interactive element has a `Semantics(label: "...")` |

---

## 2. Component library conventions

### 2.1 v1 widgets in active use

Built-in Flutter Material 3 widgets. No third-party UI library.

| Widget | Background | Padding | Text style | Border radius | Other props |
|---|---|---|---|---|---|
| `MaterialApp.router` | n/a | n/a | n/a | n/a | `theme` + `darkTheme` + `themeMode: ThemeMode.system` + `routerConfig`; see `02-architecture.md` §App Shell |
| `Scaffold` (via `AppScaffold`) | `color/background` | n/a | n/a | n/a | `appBar` (title + hamburger) + `body` + optional FAB + optional `bottomNavigationBar` |
| `AppBar` | `color/surface` | title `EdgeInsets.symmetric(horizontal: space/md)` | title: `titleLarge` Inter | n/a (Material 3 default; agent does not customize) | `title: Text(<title>)`, `actions: [hamburger IconButton]` |
| `Card` (`MovieCard`, `HubCard`) | `color/surface` | `space/md` (16dp all sides) | title: `headlineSmall` Source Serif 4; subtitle: `bodyMedium` Inter | `radius/md` (12 dp) | `clipBehavior: Clip.antiAlias` for poster `Image.network` corners |
| `HubCard` | `color/surface` | `space/md` | label: `headlineMedium` Source Serif 4 | `radius/md` | full-bleed; tap target ≥48 dp; no FAB on Hub (per `02-architecture.md` §6.7) |
| `MovieCard` | `color/surface` | `space/md` | title: `headlineSmall` Source Serif 4; status pill: `labelMedium` Inter | `radius/md` | Status pill bg: `color/primary` (Bucketlist) or `color/secondary` (Collection) |
| `GridView.builder` (Collection / Bucketlist body — 3-col scrollable grid) | inherits `color/background` | cell margin: `space/sm` between cells | result-tile title: `titleMedium` Inter; year: `bodySmall` Inter | inherits from `GridTile` | 3-col grid; `childAspectRatio: 2 / 3` (poster-friendly); cell aspect ratio locked here |
| `SearchResultTile` (within `GridView.builder` on Search Page) | `color/surface` | `space/sm` | title: `titleMedium` Inter; year: `bodySmall` Inter | `radius/md` | poster via `Image.network(url, cacheManager: DefaultCacheManager())` (D16 in `08-decisions-log.md`) |
| `ModalBottomSheet` (EditSheet, Media Filter) | `color/surface` (sheet bg) + `color/scrim` at 50% opacity backdrop | `EdgeInsets.all(space/md)` interior | section headers: `titleSmall` Inter; row text: `bodyMedium` Inter | `radius/lg` (20 dp, sheet top corners only) | `isScrollControlled: true` for sheets with text fields; `enableDrag: true` for swipe-to-dismiss |
| `FilledButton` (Save in EditSheet; "Done" / "Explore Similar" / "Add" / "Add to <Destination>") | `color/primary` (enabled) / `color/on-surface-variant` at 24% opacity (disabled) | `EdgeInsets.symmetric(horizontal: space/md, vertical: space/sm)` | `labelLarge` Inter | `radius/full` | `FilledButton(onPressed: ..., child: Text(...))`; always set `onPressed: null` to disable (do not use the deprecated `enabled:` param) |
| `IconButton` (hamburger, 'X' close on Search Page, Media Filter icon) | transparent | `space/xs` hit-target padding ≥ `a11y/touch-target/min` | n/a (icon only) | n/a | Icon: Material Symbols Rounded; tooltip: `String` |
| `FloatingActionButton` (Home, Collection, Bucketlist) | `color/primary-container` | n/a | icon `MaterialSymbolsRounded.add` (24dp) | `radius/full` | `floatingActionButtonLocation: FloatingActionButtonLocation.endFloat`; `onPressed: () => context.push('/search')` |
| `TextField` (search bar; EditSheet fields; manual-entry form) | `color/surface-variant` (filled variant) | `space/md` content | `bodyLarge` Inter | `radius/md` | `OutlineInputBorder` with `color/outline` |
| `Chip` (Genre multi-select; status pills) | `color/surface-variant` | `space/xs` content | `labelMedium` Inter | `radius/sm` | `Chip(label: Text(...))`; `deleteIcon` for genres only |
| `SnackBar` (already-in-collection; transient alerts) | `color/surface-variant` | `space/md` content | `bodyMedium` Inter | `radius/sm` | `SnackBarBehavior.floating`; `duration: 2s`; action button optional |
| `AlertDialog` (delete confirm; save-failed; missing API key) | `color/surface` | `space/lg` interior | title: `titleMedium` Inter; body: `bodyMedium` Inter | `radius/lg` | `actions: [TextButton(...), TextButton(...)]` — always two text buttons, no `FilledButton` in dialogs |
| `CircularProgressIndicator` (TMDB search loading) | n/a (transparent) | n/a | n/a | n/a | color: `color/primary`; strokeWidth: 4 |
| `LinearProgressIndicator` (reserved for v2 import progress per `02-architecture.md` §Comp Library) | n/a | n/a | n/a | n/a | color: `color/primary`; **NOT used in v1** |
| `RefreshIndicator` (pull-to-refresh on collection/bucketlist pages) | n/a | n/a | n/a | n/a | color: `color/primary`; `onRefresh: () async => ref.invalidate(moviesListProvider)` |
| `Image.network` (posters in `MovieCard`, `SearchResultTile`, expanded detail) | n/a | n/a | n/a | `BorderRadius` matches the parent's radius (HubCard, Card, or SearchResultTile) | `cacheManager: DefaultCacheManager()` (D16); `errorWidget:` falls back to icon `(placeholder)` if TMDB poster URL returns 404 |
| `AnimatedTheme` (reserved for v1 system-handler theme switching) | n/a | n/a | n/a | n/a | **NOT used in v1** — `themeMode: ThemeMode.system` handles it without an explicit `AnimatedTheme` widget |

### 2.2 Widgets banned in v1 (and why)

The tutor **fails any PR** that uses these. Listed so the agent
never invents:

| Widget | Reason |
|---|---|
| `NavigationBar` | Two-tabs-only in v1 (D3); a full `NavigationBar` would render empty slots. |
| `NavigationDrawer` | Same reason; Hamburger Menu uses a regular `Drawer` (see §3.8). |
| `Tabs` (`TabBar`, `TabBarView`) | v1 has no tabbed content within a page. The bottom nav serves that role. |
| `ExpansionTile` | TBD in v2; v1 lists are flat. |
| `Slider` | Status is a 2-state toggle, not a continuous value. EditSheet uses a `FilledButton` pair or segmented control. |
| `Switch` | Same reason; status is a toggle, not a binary on/off. (v2 may add a Switch for "remember last status" preferences.) |
| `Checkbox` | Genre multi-select uses `Chip` with the appropriate selected state, not `Checkbox`. |
| `Radio` | Status defaults to Collection or Bucketlist; not user-selectable among multiple mutually-exclusive values. |
| `DatePicker` / `TimePicker` | v1 has no date/time selection surface. |
| `Menu` / `Tooltip` / `SearchBar` | Not in v1's chrome inventory. (Search Page is full-page; tooltips are unused.) |
| `SegmentedButton` | Status binary toggle uses `FilledButton` pair; segmented is v2+. |

Also banned: **emoji as UI affordance**, **Unicode glyphs as icons**,
**`Icons.add` (legacy Material Icons set)** — use Material Symbols
Rounded exclusively (see §4).

---

## 3. Layout patterns

Eight patterns describe the structural shape of every v1 page.
Each pattern names the chrome (`AppScaffold`-supplied parts) and
the body widgets. The Layout pattern covers **(a)** which widgets
live at the slot positions, **(b)** what the chrome does and
doesn't render, and **(c)** invariants the page must honor.

### 3.1 Landing Page (`/`)

**Purpose:** Single-tap entry point for v1. Movies-only in v1;
other media types locked behind "Coming soon" labels.

**Structure:**

```
Scaffold(
  appBar: AppBar(title: Text('One-for-All')),  ← AppScaffold-supplied
  body: Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Choose Your Realm of Media'),  // headlineMedium
        SizedBox(height: space/lg),
        _MediaTypeTile(label: 'Movies'),     // only Movies enabled
        SizedBox(height: space/lg),
        _MediaTypeTile(label: 'TV Shows'),   // disabled
        // ... 5 more disabled tiles for TV Shows, Anime,
        //     Video Games, Books, Comics
      ],
    ),
  ),
)
```

**Chrome:** AppBar (title `One-for-All`); no bottom nav; no FAB.

**Invariants:**
- Only the **Movies** tile is tappable; the other 5 are
  disabled and visually muted (`color/on-surface-variant`).
- Beneath the Movies tile, the line "Next Media Type: TV
  Shows — coming soon!" is displayed in `bodyMedium` Inter.
- The Landing Page's `/` route is the initial route of
  `MaterialApp.router`. `context.push('/')` is unreachable from
  any other page (no back stack to it).

### 3.2 Home Page (`/home`)

**Purpose:** Default in-app landing after the user taps Movies on
the Landing Page. Shows the Watchlist horizontal carousel.

**Structure:**

```
Scaffold(
  appBar: AppBar(title: Text('Home')),   ← AppScaffold-supplied
  body: ListView(
    children: [
      _WatchlistCarousel(),  // one horizontal carousel in v1
      // Collab and Upcoming carousels are v2 placeholders
    ],
  ),
  floatingActionButton: FAB-add,   ← AppScaffold-supplied
  bottomNavigationBar: BottomNavigationBar(...),   ← AppScaffold-supplied
)
```

**Chrome:** AppBar (title `Home`); bottom nav (active tab "Home");
FAB (`+`). The other 2 carousels (`Collab`, `Upcoming`) are
v2 placeholders and do not render in v1.

**Invariants:**
- Watchlist carousel only — `Collab` and `Upcoming` carousels
  are deferred to v2 (D-L8).
- Tapping a card navigates to the movie detail (v2-only
  feature); in v1, cards have no tap handler.

### 3.3 Catalogue Page (`/catalogue`) — the Hub

**Purpose:** Two-card hub. Tapping each HubCard navigates to a
filtered list page.

**Structure:**

```
Scaffold(
  appBar: AppBar(title: Text('Catalogue')),
  body: ListView(
    padding: EdgeInsets.all(space/lg),
    children: [
      _HubCard(label: 'Collection', onTap: ...),
      SizedBox(height: space/md),
      _HubCard(label: 'Bucketlist', onTap: ...),
    ],
  ),
  // NO floatingActionButton
  bottomNavigationBar: BottomNavigationBar(...),
)
```

**Chrome:** AppBar (title `Catalogue`); bottom nav (active tab
"Catalogue"). **No FAB** (per `02-architecture.md` §FAB).

**Invariants:**
- `path.startsWith('/catalogue')` (any child route) lights the
  Catalogue tab in the bottom nav.
- HubCards are full-bleed; tap target ≥ `a11y/touch-target/min`
  (48 dp).
- No FAB on this page.

### 3.4 List page (`/catalogue/collection`, `/catalogue/bucketlist`)

**Purpose:** Filtered list of media items rendered as a
scrollable 3-column grid; each row is a poster-shaped
`MovieCard`. Collection filters on `MediaStatus.inCollection`;
Bucketlist filters on `MediaStatus.onBucketlist`.

**Structure:**

```
Scaffold(
  appBar: AppBar(title: Text('Collection' /* or 'Bucketlist' */)),
  body: Column(
    children: [
      _StatisticsBlock(),                         // "X movies" only
      SizedBox(height: space/sm),
      Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: space/lg, vertical: space/sm),
        child: Row(
          children: [
            Expanded(child: _InlineSearchField()),
            SizedBox(width: space/sm),
            _MediaFilterButton(onPressed: ...),
          ],
        ),
      ),
      SizedBox(height: space/sm),
      Expanded(
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: space/sm,
            crossAxisSpacing: space/sm,
            childAspectRatio: 2 / 3,
          ),
          itemBuilder: (context, i) => MovieCard(movie: movies[i]),
        ),
      ),
    ],
  ),
  floatingActionButton: FAB-add,
  bottomNavigationBar: BottomNavigationBar(...),
)
```

**Chrome:** AppBar; bottom nav (Catalogue tab); FAB.

**Invariants:**
- Statistics block shows the **count only** ("X movies"). No
  average rating, no total runtime in v1.
- Inline search filters the user's database (not TMDB). The
  Search Page (`/search`) is the TMDB search surface; this
  search is local.
- Media Filter button opens the Genre-only `ModalBottomSheet`
  (per Q4). Single-select chips at first; v2 widens.
- `GridView.builder` is the only scrolling primitive on this
  page. It scrolls vertically out of the box; the user scrolls
  through the catalogue. There is no flat `ListView` fallback.
- `childAspectRatio: 2 / 3` — poster-friendly. Each cell is
  twice as tall as it is wide (classic movie poster shape).
- FAB `onPressed` → `context.push('/search')`.

### 3.5 Search Page (`/search?q=<query>&type=movie`) — 5 states

**Purpose:** Add a movie to the user's catalogue.

**States A–E (per `01-project-overview.md` §First-session flow):**

| State | Trigger | Body | Bottom row | Top right |
|---|---|---|---|---|
| **A** (Input) | Page open | Search text field (focused) | n/a | `IconButton(close)` |
| **B** (Results) | User types / hits enter | 3-col `GridView` of `MediaSearchResultTile`; fallback: `ManualEntryForm` on `MediaSearchUnavailable` | n/a | `IconButton(close)` |
| **C** (AddSheet inline) | Tap a result | Status toggle (Collection / Bucketlist) + Rating (0–10) | "Done" / "Explore Similar Titles" | `IconButton(close)` + exit-confirm if unsaved |
| **D** (Similar titles multi-select) | Tap "Explore Similar Titles" | 3-col `GridView` of similar titles; long-press to multi-select; checkmark overlay | "Add" | `IconButton(close)` |
| **E** (Confirm) | Tap "Add" | 3-col `GridView` (or list view toggle) of selected titles; per-item remove icon; Collection / Bucketlist toggle at top | "Add to \<Destination\>" (label updates reactively per Q2 E2) | `IconButton(close)` + exit-confirm if any item unsaved |

**Chrome:** Full-page route at `/search`. AppBar is present but
shows the AppShell's title `'Search'` rather than the search
query. **No bottom nav** during States A–E; the user is in a
modal-feeling flow.

**Invariants (state-machine):**
- State transitions are forward-only (with two escape hatches:
  the `IconButton(close)` exit-confirm, or the `Navigator.pop`
  when State E's "Add to \<Destination\>" commits).
- State C → D: only on "Explore Similar Titles" tap.
- State D → E: only on "Add" tap (with zero or more selections).
- State E → done: only on "Add to \<Destination\>" tap.
- "X" exit at any state; exit-confirm dialog at C and E
(per `01-project-overview.md` §First-session flow step 11).

State C is **inline** (a full-page state), not a
`ModalBottomSheet` — see `02-architecture.md` §App Shell for
rationale.

State B fallback (manual entry) — when TMDB is unreachable —
shows a manual-entry form with Title / Year / Genre / Status
(default = Bucketlist per Q7) / Rating fields.

### 3.6 Modal sheet (EditSheet, Media Filter)

**Purpose:** Two distinct `ModalBottomSheet` surfaces, both open
via `showModalBottomSheet(...)` and share the visual chrome
below.

**Chrome (both):**

```
Scaffold(  // implicit from AppScaffold parent; modal renders its own
  backgroundColor: color/scrim at 50% opacity,
  builder: (context) => SafeArea(
    child: Container(
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: radius/lg),
        ),
        color: color/surface,
      ),
      padding: EdgeInsets.all(space/md),
      child: <sheet body>,
    ),
  ),
)
```

**EditSheet (from `MovieCard.onTap`):**

- Pre-filled with the movie's current status + rating.
- Body: poster image (left) + status toggle (right) + rating
  slider; Save / Delete buttons in `actions`.
- "Delete" → confirm dialog (`AlertDialog`). User confirms →
  `movieDao.delete(id)` → `Navigator.pop()`.
- "Save" → `movieDao.upsert(...)` → `Navigator.pop()`.

**Media Filter sheet (from Collection / Bucketlist page):**

- Genre multi-select chips (`Chip` with `selected: bool`). v1
  single-apply per session; v2 widens to multi.
- "Clear" → resets to "all genres".
- "Apply" → filters the list, pops the sheet.

**Invariants (both):**
- `isScrollControlled: true` (sheet can be taller than half-screen
  for EditSheet's form fields).
- Sheet top corners only are rounded (`radius/lg`); bottom edge
  is square.
- `enableDrag: true` (swipe-down to dismiss is allowed).

### 3.7 BottomNavigationBar structure

**Purpose:** Two-tab top-level navigation. Active tab reflects
`path.startsWith(<prefix>)`.

**Structure (provided by `AppScaffold`):**

```
BottomNavigationBar(
  currentIndex: _activeIndexForPath(path),
  onTap: (i) => _onTapTab(i),
  selectedItemColor: color/primary,
  unselectedItemColor: color/on-surface-variant,
  type: BottomNavigationBarType.fixed,  // v1 ships 2 tabs; v2 widens to 4
  items: [
    BottomNavigationBarItem(
      icon: Icon(MaterialSymbolsRounded.home), label: 'Home'),
    BottomNavigationBarItem(
      icon: Icon(MaterialSymbolsRounded.library), label: 'Catalogue'),
  ],
)
```

**Active-tab logic:**

| Active tab | Condition |
|---|---|
| Home | `path == '/home'` |
| Catalogue | `path.startsWith('/catalogue')` |
| (none) | `/search`, `/profile`, `/media-type`, `/settings`, `/help`, `/about` |

When the active path is in the `(none)` group, `BottomNavigationBar`
is **not rendered** (see `02-architecture.md` §App Shell).

**Invariants:**
- Two-tab layout in v1 (D3). v2 widens to 4 tabs by setting
  `items.length = 4`; `AppScaffold` signature unchanged.
- All `IconButton`s in `BottomNavigationBar` are ≥ 48 dp
  (`a11y/touch-target/min`); the Material default already meets
  this; do not reduce `iconSize`.
- Active tab uses `color/primary`; inactive uses
  `color/on-surface-variant`. Never hardcode hex.

### 3.8 Hamburger Menu overlay

**Purpose:** Five secondary routes (Profile / Media Type /
Settings / Help / About). v1 ships each as a stub page.

**Trigger:** the hamburger `IconButton` in `AppBar.actions`
(open from any page that has the AppBar — i.e., all pages
except Landing and full-screen overlays).

**Structure:**

```
Scaffold(
  // The Hamburger Menu uses a regular Drawer, not NavigationDrawer
  // (NavigationDrawer is banned — see §2.2).
  drawer: Drawer(
    child: ListView(
      padding: EdgeInsets.zero,
      children: [
        DrawerHeader(child: Text('Media Tracker')),
        ListTile(
          leading: Icon(MaterialSymbolsRounded.person),
          title: Text('Profile'),
          onTap: () => context.push('/profile'),
        ),
        ListTile(
          leading: Icon(MaterialSymbolsRounded.movie),
          title: Text('Media Type'),
          onTap: () => context.push('/media-type'),
        ),
        ListTile(
          leading: Icon(MaterialSymbolsRounded.settings),
          title: Text('Settings'),
          onTap: () => context.push('/settings'),
        ),
        ListTile(
          leading: Icon(MaterialSymbolsRounded.help),
          title: Text('Help'),
          onTap: () => context.push('/help'),
        ),
        ListTile(
          leading: Icon(MaterialSymbolsRounded.info),
          title: Text('About'),
          onTap: () => context.push('/about'),
        ),
      ],
    ),
  ),
  // ... appBar / body / floatingActionButton as usual
)
```

**Hamburger Menu pages (`/profile`, `/media-type`, `/settings`,
`/help`, `/about`):**

Each is rendered as a simple `Scaffold` page with a
back-button AppBar (`leading: BackButton()`) and a centered
text widget. v1 ships each as a stub (per Q5). MediaTypePage
lists the 6 types from the wireframe (per Q6; Movies-only-
tappable; others greyed out with "Coming in v2" labels).

**Behavior:**
- Tapping a `ListTile` calls `context.push(<route>)` and
  dismisses the drawer.
- Swipe-from-left or tapping the hamburger `IconButton` opens
  the drawer (Material 3 default behavior of `Drawer`).
- The drawer uses `color/surface` as its background; the
  `DrawerHeader` uses `color/surface-variant`.

**Invariants:**
- The Hamburger Menu icon (`menu`) is fixed in the AppBar's
  trailing area; the page title is the only leading content.
  (See `02-architecture.md` §App Shell.)
- Profile, Media Type, Settings, Help, About are the **only**
  five routes the Hamburger Menu exposes. v2 widens.
- No nested navigation within Hamburger Menu pages — each is
  a leaf.

---

## 4. Icon usage

### 4.1 Material Symbols Rounded setup

Material Symbols Rounded is bundled as a font asset
(`assets/fonts/MaterialSymbolsRounded.ttf`, **Apache License 2.0**;
D17 in `08-decisions-log.md`). There is no official Flutter
wrapper for Material Symbols as of plan-date; we consume the
font directly.

**`pubspec.yaml`:**

```yaml
flutter:
  fonts:
    - family: MaterialSymbolsRounded
      fonts:
        - asset: assets/fonts/MaterialSymbolsRounded.ttf
```

**Reference convention:**

```dart
Icon(
  const IconData(0xe88a, fontFamily: 'MaterialSymbolsRounded'),
  // 0xe88a = codepoint for 'home'; lookup codes at fonts.google.com/icons
)
```

Or use `IconData.fontFamily` constructor:

```dart
const _kHamburgerIcon = IconData(
  0xe5d2,  // 'menu' codepoint in Material Symbols Rounded
  fontFamily: 'MaterialSymbolsRounded',
  fontPackage: 'media_tracker',
);
```

**Alternative (readability-priority):** when working with
Material Symbols, prefer the codepoint lookup helper pattern:

```dart
import 'package:media_tracker/shared/icons.dart';
// shared/icons.dart defines const IconData per logical name.
Icon(Icons.homeForAgent)  // wraps MaterialSymbolsRounded 'home' codepoint
```

This is the recommended pattern. v1 ships `lib/shared/icons.dart`
with the consolidated icon set (see §4.4).

### 4.2 Naming policy

- Material Symbols Library naming: `snake_case` after the
  canonical icon name (e.g., `home`, `add`, `search`,
  `filter_list`, `check_circle`, `close`, `menu`, `person`,
  `movie`, `settings`, `help`, `info`, `library`).
- v1's `lib/shared/icons.dart` aliases carry semantic prefixes
  so the icon name reads in code (e.g., `homeForAgent` rather
  than the raw codepoint).
- **No emoji as UI affordance.** **No Unicode glyphs as icons.**
  The `IconData` family parameter is always `MaterialSymbolsRounded`.
- Do not redefine Material's `Icons.add` etc. (legacy icon set);
  use the Material Symbols Rounded equivalent with explicit
  `fontFamily`.

### 4.3 Style policy (filled / outlined / rounded)

Material Symbols exposes a `FILL` axis on the variable font
(per Google Fonts spec). The font bundled with v1 supports three
styles:

| Style | Use | Example |
|---|---|---|
| **Rounded** (default) | All v1 icons unless otherwise noted | Home, search, settings |
| **Filled** | Active / selected state | Bookmark `Filled` when on Bucketlist |
| **Outlined** | Explicit "off / inactive / unset" state (rare in v1) | (Reserved for v2 darker-on-light contrast) |

**v1 simplification:** the font bundled via the official Google
Materials Symbols static font ships the **Rounded** variant
loaded by default. v1 uses Rounded for all icons; Filled is
reserved for selected states (e.g., a "Watchlist bookmark"
icon when the user has bookmarked a movie). Outlined is not
used in v1.

### 4.4 v1 surface icon inventory

The icon names below are the canonical Material Symbols Rounded
glyphs v1 uses. Their codepoints (hex values) are loaded from the
font asset; the `lib/shared/icons.dart` constant aliases carry
the same names.

| v1 Surface | Icon name | Purpose |
|---|---|---|
| `BottomNavigationBar` Home tab | `home` | Bottom nav tab 1 |
| `BottomNavigationBar` Catalogue tab | `library` | Bottom nav tab 2 (preferred over `category`; library reads more naturally for media) |
| AppBar trailing action | `menu` | Hamburger Menu trigger |
| Search Page State A (top right) | `close` | 'X' close button |
| FAB (Home, Collection, Bucketlist) | `add` | Add a movie |
| Search Page State B/D/E (`IconButton` on tiles) | `search` (when filtered), `add_circle` (when not yet in catalogue), `check_circle` (when already in catalogue) | Tile state |
| Search Page State C (status) | For status toggle, use **Filled** variant `bookmark` or `bookmark_added` | Bucketlist = bookmark_added (filled) · Collection = bookmark (outline) |
| Search Page State D (multi-select) | `check_box` (filled when selected) · `check_box_outline_blank` (when not) | Multi-select overlay |
| Search Page State E (remove) | `close` (small, top-right of each tile) | Per-item remove |
| Media Filter button | `filter_list` | Trigger Genre filter sheet |
| Collection / Bucketlist FAB | `add` | Same as Home FAB |
| EditSheet Delete | `delete_outline` | Delete action in EditSheet |
| Exit-confirm dialog | `help_outline` (info) / standard `AlertDialog` actions | No custom icon |
| Hamburger Menu tile icons | `person`, `movie`, `settings`, `help`, `info` | 5 items |
| Empty-state placeholder | `info_outline` or `inbox` (for empty list — Collection / Bucketlist) | Empty HubCards, empty list pages |
| Refresh pull (pull-to-refresh) | standard `RefreshIndicator` arrow | n/a (default) |
| Loading (TMDB search) | `CircularProgressIndicator` — no glyph icon | n/a |
| Error state | `error_outline` | Empty / failed states |

---

## Cross-references

- Architecture, layers, AppShell, theme wiring, invariants:
  `02-architecture.md`
- Conventions, framework patterns, file organization,
  styling rules (the *agent's review checklist*):
  `03-code-standards.md`
- D-cards (locked decisions): D10 (Material 3 + single seed),
  D17 (Material Symbols), D18 (fonts), D19 (seed color),
  D-L2 (light + dark shipped in v1)
  — `08-decisions-log.md`
- Phase numbering, Done Definitions, per-step 5-sub-block
  templates: `05-phases.md`
- Programming concepts (the agent uses `webfetch` /
  `websearch` for current sources)
- Project framing (v1 surfaces, first-session flow):
  `01-project-overview.md`
- Tutor's role & 5-step flow: `00-tutor-workflow-rules.md`
- Session status: `07-progress-tracker.md`
- Repo-root charter: `/AGENTS.md`
