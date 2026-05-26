# 10k Hours — Development Progress

Cross-platform Flutter app (iOS + Android) that frames mastery as a 10,000-hour
countdown ring per pursuit. Local-first; no backend, accounts, or analytics.

- **Repo**: https://github.com/jt1402/10k_hours
- **Started**: 2026-05-26
- **Owner**: Jay (PM, @jt1402)
- **Built by**: Claude Opus 4.7 in the role of senior mobile engineer

---

## Status

**Slice 1 shipped (2026-05-26)** — end-to-end working on iOS Simulator.

| Metric                  | Value                                       |
| ----------------------- | ------------------------------------------- |
| Commits on `main`       | 12                                          |
| Tests passing           | 36 (unit + golden + integration)            |
| `flutter analyze`       | clean                                       |
| `dart format` check     | clean                                       |
| iOS simulator           | runs end-to-end (create → run → pause → stop → restart resume) |
| Android                 | deferred (SDK not yet installed)            |
| CI                      | GitHub Actions on macos-latest              |

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

## What's next

Possible Slice 2 directions, in priority order from the BUILD_PROMPT:

1. **Streaks & consistency** — daily/weekly streak counter, "you've shown up
   N days in a row" beneath the ring. Adds a small DAO query and a strip in the
   timer screen.
2. **Slice 1.5 polish** before Slice 2 — color picker for pursuits, multi-pursuit
   horizontal pager (data is already multi-pursuit), proper iOS/Android flavor
   configs (different bundle IDs, app names, icons), Android SDK setup.
3. **Pace projection** — "at your 7-day pace you finish on `<date>`," compared
   against optional `goal_date`. Adds a column (migration v2) and a math module.
4. **Heatmap** — GitHub-style contribution calendar of daily hours.
5. **Session quality tagging** — optional 1–5 mood/focus rating after each stop,
   driving "your best sessions tend to be `<morning / 25–50min / …>`".
6. **Smart reminders** — local notifications scheduled at the user's
   historically most-productive hour. Quiet hours respected. Needs real-device
   verification.
7. **Insights screen** — weekly rollup, % change vs. prior week, longest
   session, projected-completion shift.
8. **Export** — CSV/JSON of all sessions; "the user owns their data."
9. **iCloud / Google Drive backup** — opt-in, later.
