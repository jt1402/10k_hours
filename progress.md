# 10k Hours — Development Progress

Cross-platform Flutter app (iOS + Android) that frames mastery as a 10,000-hour
countdown ring per pursuit. Local-first; no backend, accounts, or analytics.

- **Repo**: https://github.com/jt1402/10k_hours
- **Started**: 2026-05-26
- **Owner**: Jay (PM, @jt1402)
- **Built by**: Claude Opus 4.7 in the role of senior mobile engineer

---

## Status

**Slices 1–3 shipped (2026-05-26)** — multi-pursuit timer with streaks and a GitHub-style heatmap.

| Metric                  | Value                                       |
| ----------------------- | ------------------------------------------- |
| Commits on `main`       | 16                                          |
| Tests passing           | 44 (unit + golden + integration)            |
| `flutter analyze`       | clean                                       |
| `dart format` check     | clean                                       |
| iOS simulator           | runs end-to-end (timer + switcher + heatmap) |
| Android                 | deferred (SDK not yet installed)            |
| CI                      | GitHub Actions on macos-latest, green on every push |

---

## Stack

| Layer                  | Choice                                                          |
| ---------------------- | --------------------------------------------------------------- |
| Flutter                | 3.44.0 stable, Dart 3.12                                        |
| Lints                  | `very_good_analysis ^10` with strict casts/inference/raw-types  |
| State management       | Riverpod 3.x with `@riverpod` codegen                           |
| Routing                | `go_router 17.x`                                                |
| Persistence            | Drift 2.31 (SQLite), in-memory factory for tests                |
| Models                 | Freezed 3.x + `json_annotation`                                 |
| Notifications          | `flutter_local_notifications` (wired in pubspec, used Slice 3+) |
| Theming                | Material 3 + `dynamic_color` (Android 12+), bundled Inter font  |
| Time                   | Custom `Clock` abstraction (`SystemClock` / `FakeClock`)        |

### Folder layout

```
lib/
├── bootstrap.dart            # shared launch logic, ProviderScope wiring
├── main_dev.dart             # entry: Flavor.dev
├── main_prod.dart            # entry: Flavor.prod
├── app.dart                  # MaterialApp.router + DynamicColorBuilder
├── core/
│   ├── constants.dart        # kDefaultTargetHours, kSessionMinCountedDuration
│   ├── db/
│   │   ├── app_database.dart
│   │   ├── database_provider.dart
│   │   └── tables/{pursuits,sessions,active_session}.dart
│   ├── env/flavor.dart
│   ├── router/app_router.dart
│   ├── theme/{colors,typography,theme}.dart
│   └── time/clock.dart
└── features/
    ├── pursuits/{data,domain,presentation}
    └── sessions/{data,domain,presentation/ring}
```

---

## Slice 1 — Vertical: create pursuit, run session, persist, ring updates on relaunch

### Commit timeline

| # | Hash       | Subject                                                                          |
| - | ---------- | -------------------------------------------------------------------------------- |
| 1 | `105bbb4`  | chore: initial flutter scaffold from flutter create                              |
| 2 | `9a94fc5`  | chore: configure pubspec, analysis_options, and multi-entry bootstrap            |
| 3 | `1f2a05d`  | feat(theme): bundle Inter font and wire Material 3 light/dark theme              |
| 4 | `1d3dbeb`  | feat(db): drift schema v1 — pursuits, sessions, active_session singleton         |
| 5 | `bc93228`  | feat(domain): pursuit/session models, repository abstractions, session service   |
| 6 | `454566b`  | test(sessions): 19 tests for ActiveSession math and SessionService orchestration |
| 7 | `99a3192`  | feat(data): drift repository impls + in-memory tests (31 total passing)          |
| 8 | `81fa98d`  | feat(wiring): riverpod providers and go_router with home/create/timer routes    |
| 9 | `e58be05`  | feat(pursuits): create-pursuit form with optional custom target hours            |
| 10| `6d33057`  | feat(ring): custom-painted countdown ring with 0/47/100 goldens                  |
| 11| `258ce3f`  | feat(timer): live ring, controls, haptics, hour-boundary feedback, cold-start resume |
| 12| `c072922`  | test+ci: container-level lifecycle test, github actions workflow, format         |

### Decisions made during Slice 1

- **Target hours: per-pursuit, default 10,000.** Schema column `target_hours`, all
  copy reads from the pursuit. Keeps the 10k emotional hook as default while
  supporting other canonical targets (e.g. ~5,000 hours for medical subspecialty).
- **Sub-60s sessions: persisted but excluded from stats.** Single constant
  `kSessionMinCountedDuration = 60s` filtered at *read* time in
  `SessionRepository.watchForStats / totalCountedDurationFor`. Lets the threshold
  change retroactively if we ever tune it. Raw row is always kept for honest
  history. Stop UI shows a "Session too short to count" snackbar when triggered.
- **Flavors: multi-entry only for Slice 1.** `main_dev.dart` / `main_prod.dart` /
  `bootstrap.dart` partition the runtime. Native iOS/Android flavor configs
  (different bundle IDs, app names, app icons) deferred to a "Slice 1.5 — Flavors
  hardening" pass.
- **Single bundle ID for now**: `io.wincl.tenKHours`. Will split into dev/prod when
  Slice 1.5 lands.
- **Generated files committed to git** (`*.g.dart`, `*.freezed.dart`). Trade-off:
  noisier diffs vs. simpler CI (no codegen step). Chose simpler CI.
- **Timer correctness is timestamp math, not a tick counter.** Active session is
  persisted with `started_at` + `paused_total_ms`; elapsed is always
  `now - started_at - paused_total`. Survives backgrounding, kill, DST, reboot
  with no special handling.

### Gotchas / ecosystem state (May 2026)

These are real-world workarounds we hit and chose to live with; they are not
forever-true.

- **`riverpod_lint` + `custom_lint` are currently incompatible** with the
  reigning combo of `flutter_riverpod 3.3.1` + `drift_dev 2.31` + `freezed 3.x`
  because of `source_gen` and `freezed_annotation` version cross-constraints.
  Dropped both lint plugins for now. Re-add once the ecosystem reconciles.
- **`riverpod_generator: ^4.0.4-dev.1`** is the only line currently compatible
  with `flutter_riverpod 3.3.1` + `riverpod_annotation 4.x`. It's a dev
  pre-release but stable in practice. Pinned.
- **Drift's `INSERT OR REPLACE` + `CHECK (id = 1)` trips the CHECK** on second
  call even though the row's id stays 1. Worked around via explicit
  `transaction { delete().go(); insert(...); }` in `setActive`. Clearer for a
  singleton anyway.
- **Drift returns local `DateTime` even when given UTC.** Repos call `.toUtc()`
  on read to normalize the domain layer to UTC throughout.
- **Drift stores `DateTime` as Unix epoch seconds** — sub-second precision is
  lost on round-trip. Integration test uses a `<1s` tolerance.
- **Goldens vs. CI**: pixel-equality goldens differ across macOS versions and OS
  versions. CI step has `continue-on-error: true` for the golden job.
- **`sqlite3_flutter_libs 0.6.0+eol`** — the `+eol` suffix is concerning but the
  package still works. Watch for a Drift recommendation to migrate.
- **Riverpod 3.x changed `AsyncValue.valueOrNull` to `.value`** (now nullable).
- **`Override` type is no longer importable directly** for typed `overrides:`
  lists in `ProviderScope` / `ProviderContainer`. Let Dart infer.

### What's actually working

1. Empty state on first launch with a "Create your first pursuit" CTA.
2. Form: name (required), optional "Customize target hours" toggle defaulting to
   10,000.
3. Timer screen with a giant teal countdown ring (`CustomPainter`, tabular Inter
   numerals, hh:mm or "9,847" depending on remaining).
4. Tap ring = start (or pause/resume). Long-press = stop.
5. Live `HH:MM:SS` ticker below the ring during a session.
6. Snackbar on stop if duration <60s.
7. Haptics: light on start/pause/resume/stop; heavy on whole-hour boundary
   crossings (computed from total elapsed, not interval timer).
8. Cold-start resume: kill the app mid-session, relaunch, you land on the
   correct pursuit's timer with the correct elapsed.
9. Material 3 dynamic color on supported Androids (placeholder for Slice 2+),
   hand-tuned light/dark schemes on iOS.

### Test coverage (36 total)

- `test/features/sessions/domain/active_session_test.dart` — 7 tests
  (elapsedAt math, DST safety, pause math, negative clamping)
- `test/features/sessions/domain/session_service_test.dart` — 12 tests
  (start/pause/resume/stop, 60s edges, paused-stop freezes duration, error
  paths)
- `test/features/pursuits/data/pursuit_repository_impl_test.dart` — 4 tests
  (round-trip, custom target, missing id, watchAll emissions)
- `test/features/sessions/data/session_repository_impl_test.dart` — 8 tests
  (singleton constraint, INSERT OR REPLACE swap, watchForStats threshold,
  totalCountedDurationFor)
- `test/golden/ring/ring_golden_test.dart` — 3 goldens (0% / 47% / 100%)
- `test/integration/session_lifecycle_test.dart` — 2 tests (full lifecycle
  across ProviderContainer dispose+recreate, sub-60s filter)

### Notes / known caveats

- **Integration test is container-level, not widget-level.** A `testWidgets`
  version hung on `tester.pump()` interacting with Drift stream watchers + the
  periodic ticker. Switched to disposing the `ProviderContainer` and recreating
  it against the same on-disk Drift file — same invariant ("survives a
  full-restart"), no UI driver fragility. UI flow is covered by manual iOS sim
  verification.
- **Android toolchain not installed.** Slice 1 is iOS-only. Android SDK +
  Android Studio go in when we expand platforms.
- **Repo is public.** Switch with `gh repo edit jt1402/10k_hours --visibility private`
  if desired before Slice 2 lands richer logic.

---

---

## Slice 2 — Streaks & consistency (per-pursuit)

### Commit timeline

| # | Hash       | Subject                                                                          |
| - | ---------- | -------------------------------------------------------------------------------- |
| 13| `c072922`  | (slice-1 closeout) test+ci: container-level lifecycle test, github actions       |
| 14| `52a5c5c`  | docs: progress.md tracking slice 1 ship + decisions + what's next                |
| 15| `28c6f88`  | feat(streaks): per-pursuit daily streak with longest-ever in timer screen        |

### Decisions made during Slice 2

- **Per-pursuit, not aggregate.** Each pursuit owns its own rhythm; showing up
  for guitar ≠ showing up for physics. Aggregate streak across many pursuits
  was rejected because a single busy day with one quick session masks neglect
  of everything else. If "aggregate" is wanted later, it's a small addition.
- **Current streak anchors on today *or* yesterday.** The streak stays "alive"
  if the last counted session was yesterday — gives the user the full day to
  keep going. If neither today nor yesterday has a session, current = 0 but
  `longestDays` is preserved as a personal best.
- **Local-date bucketing.** Sessions store `startedAt` UTC; the StreakService
  projects to the device's local calendar date using `nowLocal.timeZoneOffset`.
  Multiple sessions on the same day count as one day.
- **Reuses `watchForStats`.** Sub-60s sessions are already excluded, so they
  don't accidentally extend a streak. No new repo method.
- **No emoji in UI** (per spec): used `Icons.local_fire_department_rounded`
  as a vector flame in the accent color (gray when current = 0).

### What landed

- `lib/features/sessions/domain/streaks.dart` — freezed `Streaks { currentDays,
  longestDays }` with a `Streaks.empty` constant.
- `lib/features/sessions/domain/streak_service.dart` — pure-Dart, stateless
  `StreakService.compute({countedSessions, nowLocal}) → Streaks`.
- `pursuitStreaksProvider(int pursuitId)` — `Stream<Streaks>` layered on top of
  `sessionRepository.watchForStats(pursuitId)`. Re-yields on every session
  change.
- `_StreakStrip` widget in `timer_screen.dart`: small horizontal row under the
  ring, hidden until there's any history. Shows flame icon + "N day streak",
  appends "· longest M" only when M > current.

### Test coverage added (44 total, +8)

`test/features/sessions/domain/streak_service_test.dart`:

- empty history → 0/0
- single session today → 1/1
- today + yesterday → 2/2
- yesterday-anchored streak still alive (3-day run ending yesterday → 3/3)
- no session today or yesterday → 0/3
- gap inside history breaks the run (today+yesterday counted, older 3-day run
  is the longest → 2/3)
- multiple sessions on same day still count as one day
- Korean timezone (+9) — late local session correctly buckets to "today"

---

---

## Slice 3 — Multi-pursuit switcher + GitHub-style heatmap

### Commit timeline

| # | Hash       | Subject                                                                          |
| - | ---------- | -------------------------------------------------------------------------------- |
| 16| `2ca1166`  | feat(slice3): multi-pursuit switcher and github-style heatmap                    |

### What landed (3a — multi-pursuit switcher)

- **Top app bar on the timer screen** replaces the inline pursuit-name headline.
  Centered title is a tappable pill (`_TitleButton` with chevron) that opens the
  switcher sheet; trailing action is a calendar icon that routes to the heatmap.
- **`showPursuitSwitcher` modal bottom sheet** (`pursuit_switcher_sheet.dart`):
  lists every pursuit (accent dot, name, target-hour subtitle, check on current),
  "+ New pursuit" tile at the bottom. Picking a pursuit calls
  `context.replace('/pursuit/:newId')` so back-stack stays clean.
- **Active-session safety**: if a session is running, the sheet shows a tinted
  banner *"Stop the current session before switching."* and all non-current
  rows are visually disabled (`enabled: false` on ListTile). The data layer's
  `active_session` singleton already enforces only-one-timer, so this is purely
  UX clarity.

### What landed (3b — heatmap)

- **`SessionRepository.watchDailyTotals(pursuitId)`** new repo method. Drift
  impl uses a `customSelect` with
  `date(started_at, 'unixepoch', 'localtime')` to bucket by the device's
  local calendar date in SQL — fast and reactive (the stream re-fires on every
  sessions-table change). Fake impl mirrors the semantics for SessionService
  tests.
- **`HeatmapPainter`** (`CustomPainter`) — 53-week × 7-day grid, 12 px cells
  with 3 px gaps, Monday-aligned rows, 5 intensity buckets coloring with the
  pursuit's accent at α=0.25/0.5/0.75/1.0 over a muted backdrop. Empty/future
  cells are skipped.
- **`HeatmapScreen`** at `/pursuit/:id/heatmap` — horizontal scroll with the
  grid (reversed so the most recent week sits at the right edge), a legend
  ("Less ☐☐☐☐☐ More"), and a footer of three stats: total hours logged,
  days active, longest consecutive run. Tap any cell → modal bottom sheet
  showing the day's date and total.

### Decisions made during Slice 3

- **Switcher = bottom sheet, not a horizontal pager.** Pager + giant tap target
  for start/pause/stop creates an ambiguous gesture surface. Bottom sheet is
  unambiguous and matches modern iOS patterns (Photos library, Notion).
- **Blocked switching mid-session** rather than auto-stopping. Auto-stop would
  silently terminate work the user might still want to come back to. Explicit
  is safer.
- **Heatmap on a separate screen** (not inline under the ring). Keeps the
  timer surface focused. Calendar icon in the app bar is the entry point.
- **53 weeks**, Monday-aligned, with the current week on the right. Reusing
  GitHub's convention even though Material 3 generally prefers Sunday-aligned —
  Monday-aligned reads cleaner for a productivity app and matches the user's
  weekly rhythm.
- **Bucketing in SQL, not Dart.** `date(...,'unixepoch','localtime')` is a one-
  liner that runs server-side (relative to Drift's isolate) and emits already-
  bucketed rows. No need to walk 365 sessions in app code.
- **Day detail = minimal.** Slice 3 just shows date + total. Per-day session
  list is a Slice 4+ polish item.

### Known follow-ups

- **No dedicated `watchDailyTotals` Drift test.** The fake impl is exercised by
  the heatmap screen during manual verification and the streak math already
  covers per-day bucketing via a different path. Add an in-memory Drift test
  for the raw SQL query when polishing.
- **Day-detail bottom sheet** doesn't yet list the day's individual sessions —
  just date + total. Add when expanding the heatmap surface.

---

## What's next

Possible Slice 4 directions, in priority order from the BUILD_PROMPT:

1. **Pace projection** — "at your 7-day pace you finish on `<date>`," compared
   against optional `goal_date`. Adds a column (migration v2) and a math
   module that consumes `watchForStats`. Re-uses the local-date bucketing
   built for streaks.
2. **Heatmap** — GitHub-style contribution calendar of daily hours. Reuses the
   same daily-totals query the streak math already needs; a new screen plus a
   `CustomPainter` for the grid.
3. **Slice 1.5 polish** — color picker for pursuits, multi-pursuit horizontal
   pager (data is already multi-pursuit), proper iOS/Android flavor configs
   (different bundle IDs, app names, icons), Android SDK setup.
4. **Session quality tagging** — optional 1–5 mood/focus rating after each stop,
   driving "your best sessions tend to be `<morning / 25–50min / …>`".
5. **Smart reminders** — local notifications scheduled at the user's
   historically most-productive hour. Quiet hours respected. Needs real-device
   verification.
6. **Insights screen** — weekly rollup, % change vs. prior week, longest
   session, projected-completion shift.
7. **Export** — CSV/JSON of all sessions; "the user owns their data."
8. **iCloud / Google Drive backup** — opt-in, later.
