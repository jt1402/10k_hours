# 10k Hours (native Swift) — Development Progress

A native **SwiftUI + SwiftData** iOS app that frames mastery as a countdown
toward a per-pursuit goal (default 10,000 hours), with a live countdown ring,
streaks, a GitHub-style heatmap, an iOS Live Activity (Dynamic Island + lock
screen), and an AlarmKit goal alarm. Local-first; no backend, accounts, or
analytics.

- **Project folder**: `/Users/jay/10k_hours_swift`
- **Owner**: Jay (PM, @jt1402)
- **Built by**: Claude Opus 4.7 in the role of senior iOS engineer
- **Pivot date**: 2026-05-27

---

## ⚠️ This is a rewrite — we started in Dart/Flutter, then moved to native Swift

The app was **first built in Flutter/Dart** (still at `/Users/jay/10k_hours`,
repo https://github.com/jt1402/10k_hours). It shipped four slices: multi-pursuit
timer, streaks, heatmap, and an iOS Live Activity, plus a goal-completion clamp
and an AlarmKit goal alarm. See that repo's `PROGRESS.md` for the full Flutter
history — **it is the functional spec we are porting from.**

**Why we pivoted to native Swift (2026-05-27):** the app's identity is the
iOS-specific surfaces — Live Activities, the Dynamic Island, and AlarmKit. In
Flutter those all had to be written in Swift anyway and bridged over a
`MethodChannel`, so Flutter added a serialization/boundary tax exactly where the
hard work was, while giving nothing back (no Android target is planned). Native
SwiftUI removes the bridge entirely, the Live Activity widget + AlarmKit code
port over almost verbatim, and the app is "more serious"/idiomatic for iOS. The
Flutter app is **frozen** ("leave it like this").

**The Flutter build is not wasted** — it is the reference implementation and the
source of the hard-won iOS knowledge captured in the "iOS lessons learned"
section below. Re-read that before touching Live Activities or AlarmKit.

---

## Status

**All phases done; device-verified (2026-05-27).** Domain + persistence, theme,
all six screens, Live Activity, and the AlarmKit goal alarm are implemented and
**verified end-to-end on a physical iPhone (iPhone(jt), iOS 26.4.2)**. App +
widget build clean and all 33 unit tests pass. Bundle ids are now `io.tenkhours`
(the `io.wincl.*` prefix was removed).

The Live Activity uses **AlarmKit dual-mode** (chosen over the custom-LA freeze):
when the goal is within `AppConstants.alarmKitCountdownMaxSeconds` (12h) on iOS
26+, an **AlarmKit-owned countdown Live Activity** drives the Dynamic Island, so
the OS flips it to the alert/"Finished" state live at the goal **even while the
app is suspended, no push** — confirmed firing on device. Far goals / iOS 18–25
fall back to the custom count-up Live Activity (`LiveActivityController`).

Still open (polish, not blocking): Geist font + app icon (see Open decisions);
optionally suppress the in-app completion sheet while the AlarmKit alert is
showing (foreground goal shows both today); two-way `alarmUpdates` sync if the
island's own pause/stop buttons should mirror into the session.

*History — Phase 1 (domain + persistence):* pure logic + SwiftData `@Model`s +
`ModelContainer` + 33 ported tests. *Phase 0 (scaffold):* app + widget compiled.

| Metric                | Value                                                       |
| --------------------- | ----------------------------------------------------------- |
| Xcode / Swift         | 26.2 / Swift 6.2.3                                           |
| iOS deployment target | 18.0 (AlarmKit + live Dynamic-Island flip gated to 26+)     |
| Project generator     | XcodeGen 2.45.4 (`project.yml` is the source of truth)      |
| Targets               | `TenKHours` (app), `TenKHoursWidgetExtension` (Live Activity) |
| Signing team          | `4NC3JC88D4` (automatic)                                     |
| Bundle ids            | app `io.tenkhours`, widget `io.tenkhours.Widget`, tests `io.tenkhours.Tests` |
| Build                 | simulator Debug builds green                                |
| On-device run         | running on iPhone(jt) (iOS 26.4.2) via Xcode signing        |
| Tests                 | 33 Swift Testing tests (elapsed / clamp / service / streaks) — green |

---

## Stack

| Layer            | Choice                                                          |
| ---------------- | --------------------------------------------------------------- |
| UI               | SwiftUI (iOS 18+)                                               |
| State            | Observation (`@Observable`) + SwiftUI environment — no 3rd-party |
| Persistence      | **SwiftData** (`@Model` / `ModelContainer`); aggregates in-memory |
| Live Activity    | ActivityKit + WidgetKit extension (ported from Flutter Swift)   |
| Goal alarm       | AlarmKit (`@available(iOS 26)`-gated)                           |
| Project gen      | XcodeGen (`project.yml`)                                        |
| Fonts            | Geist (bundle into app target — TODO)                           |
| Time             | wall-clock timestamp math (no tick counters) — see lessons      |

### Folder layout (current)

```
10k_hours_swift/
├── project.yml                     # XcodeGen source of truth (edit, then `xcodegen generate`)
├── TenKHours.xcodeproj             # GENERATED — do not hand-edit
├── Support/                        # GENERATED plists (App-Info, Widget-Info)
├── Shared/                         # compiled into BOTH app + widget targets
│   └── TenKHoursActivityAttributes.swift
├── Sources/                        # app target
│   ├── App/                        # TenKHoursApp (@main, .modelContainer), RootView (NavigationStack + Route)
│   ├── Core/
│   │   ├── Constants.swift         # target/min-counted/accent constants
│   │   ├── Format.swift            # duration/target string formatters
│   │   ├── Theme/Theme.swift       # Color(argb:), AppFont (Geist-ready), AccentPalette
│   │   ├── Time/Clock.swift        # Clock protocol + System/Fake
│   │   └── Persistence/            # @Model Pursuit/SessionRow/ActiveSessionRow,
│   │                               #   PersistenceController, SwiftDataSessionRepository, Stores (PursuitStore/SessionStats)
│   ├── Models/                     # PURE domain: ActiveSession, Session, Streaks,
│   │                               #   StreakService, SessionService, SessionRepository
│   ├── Features/
│   │   ├── Pursuits/               # EmptyStateView, CreatePursuitView, PursuitSwitcherSheet, PursuitCompletionSheet
│   │   └── Sessions/               # SessionEngine (@Observable orchestrator), TimerScreen, RingView, HeatmapScreen
│   └── Services/                   # LiveActivityController (ActivityKit), AlarmController (AlarmKit, iOS 26+)
├── Widget/                         # widget extension target (Live Activity views + helpers)
└── Tests/                          # Swift Testing unit tests + FakeSessionRepository
```

Planned structure as features land (mirrors the Flutter feature split):

```
Sources/
├── App/                 # entry, root navigation
├── Core/
│   ├── Theme/           # colors, typography (Geist), accent palette
│   └── Persistence/     # ModelContainer setup, SwiftData schema
├── Models/              # @Model Pursuit, Session, ActiveSession + pure logic
├── Features/
│   ├── Pursuits/        # list/empty state, create, switcher, completion sheet
│   └── Sessions/        # timer screen, ring, stats, heatmap
└── Services/
    ├── LiveActivityController.swift   # direct ActivityKit calls (no channel)
    └── AlarmController.swift          # AlarmKit goal alarm
```

### How to build / generate

```bash
cd /Users/jay/10k_hours_swift
xcodegen generate                      # after editing project.yml or adding files in new folders
xcodebuild -project TenKHours.xcodeproj -scheme TenKHours \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build

# Unit tests (app-hosted, so the host app must launch in the sim):
xcrun simctl boot "iPhone 17 Pro"            # boot FIRST — a cold sim flakes the
xcrun simctl bootstatus "iPhone 17 Pro" -b   #   test runner with "preflight checks / Busy"
xcodebuild -project TenKHours.xcodeproj -scheme TenKHours \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' test
# device run (release, runs standalone): flutter-style debug builds NOT applicable here;
# use Xcode or `xcodebuild ... -destination 'platform=iOS,id=<device-udid>'`
```

`xcodegen generate` re-reads the filesystem; **new files inside already-listed
source folders (`Sources/`, `Widget/`, `Shared/`) are picked up automatically** —
no `project.pbxproj` surgery (this was a recurring pain in the Flutter app's
Xcode target).

---

## What's already done (Phase 0)

- `project.yml` defining the app + WidgetKit extension, iOS 18, team, bundle ids,
  Info.plist contents (`NSSupportsLiveActivities`, `NSAlarmKitUsageDescription`,
  portrait-only, launch screen).
- `Shared/TenKHoursActivityAttributes.swift` — the Live Activity state, ported:
  `effectiveStartedAt`, `isPaused`, `pausedAtFreezeSeconds`, `displayText`,
  `targetEndAt`, `isFinished`.
- `Widget/` — the full Live Activity widget ported from the Flutter Swift,
  including the **freeze-at-goal** (`timerUpperBound`) and **"Finished"** state
  (`context.isStale || isFinished`) logic, lock screen + all Dynamic Island
  presentations, and the `formatSeconds`/`colorFromARGB` helpers.
- `Sources/App/` — `@main` app + placeholder `RootView`.
- Verified: `** BUILD SUCCEEDED **` (app + widget) on the simulator.

## What's already done (Phase 1 — domain + persistence)

- **Pure domain (`Sources/Models/`, SwiftData-independent, fully unit-tested):**
  `ActiveSession` (`elapsed(at:)` wall-clock math + `completionEndAt` background
  clamp), `Session`, `Streaks` + `StreakService` (local-date bucketing via an
  injectable `Calendar`), `SessionService` (start/pause/resume/stop, returns
  `StopResult` with the ≥60s counted flag) over a minimal `SessionRepository`
  protocol, `SessionError`. `Clock` protocol (`SystemClock`/`FakeClock`) +
  `AppConstants` in `Sources/Core/`.
- **SwiftData (`Sources/Core/Persistence/`):** `@Model` `Pursuit`, `SessionRow`
  (`durationMs`), `ActiveSessionRow` (singleton); `Persistence.makeContainer`
  (with `inMemory` for tests/previews) wired into the app via `.modelContainer`;
  `SwiftDataSessionRepository` mapping rows ↔ pure values (ms ↔ seconds).
- **Tests (`Tests/`, Swift Testing):** 33 tests ported 1:1 from the Flutter
  suite — `ActiveSessionTests` (elapsed + completionEndAt incl. the 4m35s
  overshoot→1min clamp), `SessionServiceTests`, `StreakServiceTests` (incl. a
  deterministic +9 KST bucketing case) + `FakeSessionRepository`. All green.
- Added a `TenKHoursTests` unit-test target + a `TenKHours` scheme with a test
  action to `project.yml` (run `xcodebuild … -scheme TenKHours test`).
- **Note:** durations are `TimeInterval` (seconds) in the pure layer for clean
  `Date` interop, persisted as whole `ms`. `SWIFT_VERSION: "6.0"` is the Swift 6
  *language mode* (the toolchain is 6.2.3) — not a discrepancy.

## What's already done (Phases 2–5 — UI + iOS surfaces)

- **Theme:** `Color(argb:)` / `.argb32()`, `AppFont` (system fonts now, one-place
  swap to Geist later), `AccentPalette` (7 colors; teal default). The create
  screen offers an accent picker — the data model always carried a per-pursuit
  accent; the Flutter build just hard-coded teal.
- **Screens (SwiftUI, no UIKit):** empty state; create (segmented target:
  10,000h / short HH:MM:SS wheels / custom hours, + accent); **timer** with a
  `Canvas`-drawn countdown ring, COVERED/REMAINING stat row, accent-tinted
  streak strip, live session readout, status line, name-pill→switcher,
  calendar→heatmap; completion sheet ("You did it." + 5-stat grid,
  non-dismissible); switcher (accent dot, target, current check, swipe-delete
  with confirm, blocks switching mid-session); **heatmap** (`Canvas` 53×7,
  intensity by daily minutes, `SpatialTapGesture` day detail, legend + footer).
  Navigation is a `NavigationStack` + `Route` enum in `RootView`.
- **`SessionEngine`** (`@Observable @MainActor`) is the native `_TimerScreenState`:
  owns the 1-second ticker (`now`), runs start/pause/resume/stop, the fire-once
  goal-completion with **background-overshoot clamp**, hour-boundary haptics, the
  adaptive Live-Activity text push (≥1h, ≥30s apart), and bootstraps the Live
  Activity on cold-start. Reactive reads are `@Query`; orchestration math reads
  the context fresh.
- **Live Activity** (`LiveActivityController`) and **goal alarm**
  (`AlarmController`) ported from the Flutter native Swift, called directly (no
  method channel), wired to the same lifecycle hooks (schedule on start/resume,
  cancel on pause/stop/completion, `end(finished:)` on goal).
- **Swift 6 concurrency gotcha:** under strict concurrency, binding a
  `@MainActor`-isolated `Activity`/`AlarmManager.shared` into a `let` and then
  `await`-ing a nonisolated method on it is flagged as "sending … risks data
  races." Fix: read `Activity.activities.first` / `AlarmManager.shared` **inline**
  at the call site (a nonisolated, disconnected value) instead of via a stored
  property or `@MainActor` computed property.
- **Verified on simulator:** launches to the empty state; a seeded pursuit
  renders the timer screen with exact ring/stat/streak math. Live Activity +
  AlarmKit need a physical device (Phase 6).

---

## Feature spec to port (from the Flutter app)

This is the behavior the native app must reproduce. Source files referenced are
in `/Users/jay/10k_hours`.

### Domain

- **Pursuit**: `id, name, accentColor (ARGB Int), targetMinutes (Int), createdAt,
  completedAt?`. Default target 10,000 h (stored as minutes). `completedAt` set
  once the cumulative counted time first reaches the target (gates the one-time
  celebration + the "Completed" timer UI).
- **Session** (completed record): `pursuitId, startedAt, endedAt, durationMs`.
- **ActiveSession** (singleton, the running/paused timer): `pursuitId, startedAt,
  pausedTotal, pauseStartedAt?`. Elapsed is **always** wall-clock:
  `elapsed(now) = now - startedAt - pausedTotal - (now - pauseStartedAt if paused)`,
  clamped ≥ 0. Survives backgrounding/kill/DST/reboot with no special handling.
- **Counted-duration rule**: sessions `< 60s` (`kSessionMinCountedDuration`) are
  persisted but **excluded from stats/streaks/totals** at read time.
- **SessionService**: `start / pause / resume / stop`. `stop` accepts an optional
  `endAt` so completion can record the session ending exactly at the goal
  crossing (the clamp — see lessons). Returns whether it counted (≥60s).
- **StreakService**: pure function `(countedSessions, nowLocal) → (currentDays,
  longestDays)`. Per-pursuit. Current streak stays alive if the last counted
  session was today *or* yesterday. Local-date bucketing. Multiple sessions same
  day = one day.
- **Goal completion / clamp**: when cumulative covered (counted completed
  sessions + active elapsed) crosses `targetMinutes`, end the session recorded at
  the **crossing instant** (`startedAt + pausedTotal + (target - priorCounted)`),
  mark the pursuit `completedAt`, fire the celebration. Re-checked from the
  ticker, stop, pause, and app-resume so a background crossing isn't missed or
  over-counted. (Native equivalent of `ActiveSession.completionEndAt`.)

### Screens

1. **Home / pursuit list** — empty state with "Create your first pursuit" CTA;
   otherwise routes into the current pursuit's timer.
2. **Create pursuit** — name (required), accent color, optional custom target
   (the Flutter build supports minute-precision targets).
3. **Timer** — giant countdown ring (custom-drawn), tap = start / pause / resume,
   long-press = stop; "COVERED / REMAINING" stat row; streak strip; top bar with
   a tappable pursuit-name pill (opens switcher) + calendar icon (heatmap). When
   the pursuit is completed: ring shows ✓ "Completed", controls disabled,
   "Results" button opens the completion sheet, status "Goal reached".
4. **Completion sheet** — "You did it." + stats grid (total time, sessions, days,
   longest streak, avg session).
5. **Pursuit switcher** — bottom sheet listing pursuits (accent dot, name,
   target, check on current), "+ New pursuit". Blocks switching mid-session.
6. **Heatmap** — 53-week × 7-day GitHub-style grid bucketed by local date,
   accent-tinted intensity, legend, footer stats (total hours, days active,
   longest run), tap a cell for that day's total. Daily totals bucketed by local
   calendar date.

### Theme

- Geist font (bundle it), accent-color system per pursuit, tuned light/dark.
  (Flutter used Material 3; native uses system styling + the accent.)

---

## iOS lessons learned (carry these over — hard-won in the Flutter build)

These are platform truths, not Flutter quirks. They cost real iteration.

- **Timer = timestamp math, never a tick counter.** Persist `startedAt` +
  `pausedTotal`; compute elapsed from `now`. Correct across background/kill/DST.
- **Background overshoot clamp.** A suspended app runs no code, so goal
  completion is only *detected* on resume — by then the session has overshot the
  target. Record the session as ending at the computed **crossing instant**
  (`startedAt + pausedTotal + remaining`, where `remaining = target -
  priorCounted`) so covered time lands exactly on the goal, not the overshoot.
  This is unit-test-critical; port those tests.
- **Live Activity `Text(timerInterval:)` ticks locally with no updates** — give
  it an "effective start" so seconds tick with zero pushed updates / no APNs.
- **Bound the timer to the target to freeze it.** `Text(timerInterval: start...
  targetEndAt)` freezes at the goal automatically (documented Apple behavior).
  Unbounded (`...+1yr`) overshoots. ⚠️ Watch indentation when bulk-editing — a
  single missed call site = the lock screen kept climbing while the island froze.
- **`staleDate` / `context.isStale` does NOT reliably flip the Live Activity to
  a "Finished" view while backgrounded — confirmed dead on both simulator AND
  real device.** A suspended app cannot change its Live Activity at a precise
  time without **push (APNs)**. We do not use push. So:
  - The custom Live Activity **freezes** at the goal; the "Finished" text only
    shows reliably on the **lingering lock-screen card after the app is
    reopened** (end the activity with `isFinished:true` content + `.default`
    dismissal → Dynamic Island clears, lock card lingers).
  - To make the **Dynamic Island itself flip to "Finished" live** without push,
    the only path is to let **AlarmKit own the Live Activity** (its countdown
    presentation; the OS transitions `countdown → alert` at fire time). We chose
    *not* to do that in Flutter (kept the custom LA + a separate AlarmKit alert).
    Revisit if the live island flip becomes a priority natively.
- **AlarmKit (iOS 26+) is the no-push way to alert "live" at the goal.**
  `AlarmManager.shared` + `requestAuthorization()` + `AlarmConfiguration(schedule:
  .fixed(date), attributes:)`; needs `NSAlarmKitUsageDescription`. Fires a
  full-screen system alarm (sound + Done button) even while suspended.
  **Confirmed working on device in the Flutter build.** It's a *separate* alarm,
  not the island flipping. Schedule on start/resume, **cancel on
  pause/stop/completion**, reschedule when the target shifts.
- **Flutter-specific gotcha that won't recur natively:** debug Flutter builds
  can't run standalone on a physical iPhone (need the `flutter run` host) — they
  "quit" when launched from the home screen. Native release/dev builds don't have
  this. (Noted only so the history makes sense.)

### Live Activity / AlarmKit — learned building this (native), all device-confirmed

- **AlarmKit *can* flip the Dynamic Island to "Finished" live while suspended —
  let it OWN the Live Activity.** Schedule `AlarmManager.AlarmConfiguration.timer(
  duration:…)` with `AlarmPresentation(alert:countdown:paused:)`; the widget adds
  `ActivityConfiguration(for: AlarmAttributes<GoalMetadata>.self)` reading
  `AlarmPresentationState.mode` (`.countdown(fireDate)` / `.paused` / `.alerting`).
  `stopIntent: nil` avoids App Intents. Only sensible when the goal is near (it's
  a countdown) → dual-mode: AlarmKit when remaining ≤ 12h, custom count-up LA
  otherwise. Cost: the island becomes AlarmKit's templated look, iOS 26+ only.
- **Don't race your own alarm.** Our wall-clock `checkCompletion` fired a beat
  before the alarm's `fireDate` and called `cancel()` → `mobiletimerd: "Cancelling
  alarm … No events due to fire"` → the alert never fired (just a buzz). In
  AlarmKit mode, **never cancel the alarm on completion** — let it fire.
- **A second concurrent Live Activity collapses the island to a minimal icon**
  (no compact countdown, no expand). The culprit here was a **zombie Live Activity
  from the old Flutter `io.wincl.tenKHours` app** that persisted after the app was
  deleted — we can't end another app's activity; **reboot the device** (or dismiss
  the card) to clear it. Renaming our bundle id to `io.tenkhours` also dissociates
  us from that lineage.
- **The owning app's Live Activity shows only the *minimal* presentation while
  that app is foreground.** Compact (icon + countdown) and expand-on-long-press
  only appear once you leave the app. Don't debug island layout from inside the app.
- **Device system logs:** `simctl` can't read a physical device; install
  `libimobiledevice` (`brew install libimobiledevice`) and
  `idevicesyslog -u <udid> -m <match>…` — this is how the above were diagnosed.
  Start the stream *before* reproducing (it misses anything before it connects).
- **Debugger changes background behavior.** A debugger-attached app stays
  `running-active` while backgrounded (vs. `running-suspended` in production),
  so the 1s ticker keeps firing — which is why the foreground-vs-background
  alarm logic keys off `UIApplication.applicationState == .active`, NOT "did the
  ticker fire." Always verify background/lock behavior with a **non-debug launch**
  (Stop in Xcode, tap the app icon).

### KNOWN LIMITATION — swipe-up dismiss of the AlarmKit alert (iOS bug, not ours)

If the user dismisses the fired AlarmKit alert by **swiping it UP** (sideways /
the Done button are fine), the **next session's countdown Dynamic Island won't
present** (the alarm still fires; the in-app timer is unaffected). Confirmed on
device (iPhone 16 Pro Max, iOS 26.4.2), non-debug. Root cause is **entirely in
SpringBoard's SystemAperture presentation state** — at the next run we see
`alarms before cleanup: 0` AND `leftover AlarmKit activities: 0`, i.e. nothing in
`AlarmManager.alarms` and nothing in `Activity<AlarmAttributes<…>>.activities`,
so there is **no app-level lever** to clear it (we tried: cancel-all-alarms +
`endLeftoverActivities()` via ActivityKit — both no-ops because N=0). It likely
self-clears over time / on reboot. **Treat as a known iOS limitation** (radar/FB
to Apple); revisit if a future iOS exposes the orphan or a reset API.

---

## Build order (next)

Each phase ends with a clean build (and tests where logic is involved).

1. ~~**Domain + persistence**~~ — ✅ done (2026-05-27).
2. ~~**Theme**~~ — ✅ done. `Color(argb:)`, `AppFont` (system now, Geist-ready),
   `AccentPalette`. (Geist files still TODO — see Open decisions.)
3. ~~**Screens**~~ — ✅ done. Empty state, create (default/short/custom target +
   accent picker), timer (Canvas ring), completion sheet, switcher, heatmap
   (Canvas, 53×7, tappable). Routed via `NavigationStack` + `Route`.
4. ~~**Live Activity wiring**~~ — ✅ done + device-verified. Dual-mode: AlarmKit
   owns the island for near goals (flips to "Finished" live, suspended, no push);
   custom `LiveActivityController` for far goals / iOS 18–25. Driven by `SessionEngine`.
5. ~~**AlarmKit**~~ — ✅ done + device-verified. `AlarmController` (`@available(iOS 26)`)
   owns a countdown alarm + Live Activity; fires the goal alert on device. (Do
   NOT cancel it on completion — see lessons.)
6. ~~**Device run**~~ — ✅ done. Verified on iPhone(jt) (iOS 26.4.2): island
   countdown → live alert/flip at the goal. **Polish remaining:** Geist font, app
   icon; optional foreground sheet-vs-alert de-dup; two-way `alarmUpdates` sync.
3. **Screens** — pursuit list/empty → create → timer (ring via SwiftUI `Canvas`/
   `Shape`) → completion sheet → switcher → heatmap (`Canvas`).
4. **Live Activity wiring** — `LiveActivityController` calling ActivityKit
   directly from the app (start/update/end with `targetEndAt` + `isFinished`).
   No method channel.
5. **AlarmKit** — `AlarmController` (gated iOS 26+), scheduled at the goal
   crossing; wire to the same session lifecycle hooks.
6. **Device run + polish** — run on iPhone(jt), verify Live Activity + alarm end
   to end.

### Open decisions / TODO

- Geist font files need to be added to the repo + Info.plist `UIAppFonts`.
- App icon / asset catalog not yet created (no `AppIcon` set).
- Decide whether to git-init `/Users/jay/10k_hours_swift` as its own repo.
- Whether to eventually adopt AlarmKit-owned Live Activity for the live island
  "Finished" flip (see lessons) — deferred; current plan keeps custom LA + alarm.
- SwiftData aggregate queries (counted-duration sums, daily heatmap totals) are
  computed in-memory; revisit if the dataset ever grows enough to matter.
