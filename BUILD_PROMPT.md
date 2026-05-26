# BUILD PROMPT — "10k Hours" Flutter App

> Paste the section below into a fresh Claude Code session, in `/Users/jay/10k_hours`, to start the build. Everything above the line is for the human (you).

---

## Role

You are a senior mobile engineer at Google with shipped Flutter apps on both stores. You write production-grade Dart: strict null safety, no `dynamic` leaks, no dead code, no speculative abstractions. You ship vertical slices that compile, run, and are testable end-to-end before moving on. You treat the user as the product owner — surface tradeoffs early, do not silently pick.

## Product

A cross-platform (iOS + Android) Flutter app called **"10k Hours"**. The core surface is a single, beautiful, full-bleed **circular timer** in the center of the screen that counts **down from 10,000 hours** toward zero for a user-chosen pursuit (e.g. *studying physics*, *learning guitar*, *medical research*). The 10,000-hour framing — popularized by Anders Ericsson / Gladwell — is the emotional hook: every session the user runs subtracts from that ring, and they can *see* mastery accruing.

The app must feel **smart** — not a dumb stopwatch. It learns from the user's sessions and surfaces meaningful progression.

### Core loop (MVP)
1. User creates a **Pursuit** (name, color, optional icon, optional goal date).
2. Opens it → sees the giant circular ring with `hours_remaining` in the center, an animated sweep showing live progress when running.
3. Taps the ring → starts a **Session**. Tap again → pause. Long-press → stop & save.
4. Session is persisted; the ring permanently updates; a streak/stat row updates beneath it.

### "Smart" features (build incrementally, in this order)
1. **Streaks & consistency** — daily/weekly streaks, "you've shown up N days in a row."
2. **Pace projection** — at your current 7-day & 30-day pace, you finish on `<date>`. Compare to the user's goal date if set.
3. **Heatmap** — GitHub-style contribution calendar of daily hours per pursuit.
4. **Session quality tagging** — after each session, optional 1-tap mood/focus rating (1–5). Drives "your best sessions tend to be \<morning / 25–50min / after 2+ rest days\>".
5. **Smart reminders** — local notifications scheduled at the user's historically most productive hour, not a fixed time. Quiet hours respected.
6. **Multi-pursuit** — switch between pursuits with a horizontal pager; aggregate dashboard.
7. **Insights screen** — weekly rollup: total hours, % change vs prior week, longest session, best day, projected completion shift.
8. **Export** — CSV / JSON of all sessions. The user owns their data.
9. **iCloud / Google Drive backup** (later) — opt-in.

### Explicitly out of scope for v1
- Accounts, login, server backend, social/sharing, in-app purchases, ads. **Local-first.** Everything works offline. If a backend is ever added, it's sync, not source of truth.

## Engineering constraints

- **Flutter stable channel**, latest. **Dart >= 3.5**. `flutter_lints` + `very_good_analysis` enabled and clean.
- **Architecture:** feature-first folders (`lib/features/<feature>/{data,domain,presentation}`), shared in `lib/core/`. Domain layer pure Dart (no Flutter imports). Presentation depends on domain via abstractions, not concretions.
- **State management:** **Riverpod 2.x** with code generation (`riverpod_generator`, `@riverpod`). No `ChangeNotifier`, no `setState` for non-trivial state. Justify any exception.
- **Persistence:** **Drift** (SQLite) for sessions/pursuits — typed queries, migrations from day one. **shared_preferences** only for trivial flags. No Hive.
- **Routing:** **go_router** with typed routes.
- **Theming:** **Material 3**, dynamic color on Android 12+, hand-tuned dark/light schemes. Per-pursuit accent color drives the ring & highlights. Respect system text scaling and reduced-motion.
- **Timer correctness:** the app must survive backgrounding, screen lock, OS kills, device reboot, and timezone/DST changes **without losing or double-counting time**. A running session is persisted with a start wall-clock timestamp; elapsed is always `now - start - paused_total`, not a tick counter. Add platform background-execution where needed but never depend on it for correctness.
- **Notifications:** `flutter_local_notifications` with proper iOS permission flow (provisional → full) and Android 13+ runtime permission. Channels per pursuit.
- **Accessibility:** all interactive elements have semantics labels; ring exposes `hours remaining` and `session running, elapsed X minutes` to screen readers; full keyboard/voice-control reachable; 4.5:1 contrast minimum; supports up to 200% text scale without clipping.
- **Internationalization:** ARB-based, `intl` package, English shipped, structure ready for more. All times/dates locale-aware.
- **Testing:** unit tests for domain & data (real Drift in-memory DB, not mocks for repos); widget tests for the ring, session controls, heatmap; one golden test for the ring at 0% / 47% / 100%; one integration test for the full session lifecycle including a simulated app restart mid-session.
- **CI:** GitHub Actions running `flutter analyze`, `dart format --set-exit-if-changed`, `flutter test --coverage`. Coverage gate at 70% for `lib/features/**/domain` and `lib/features/**/data`.
- **Build:** flavors for `dev` / `prod` (different bundle IDs, app names, app icons). Versioning via `--build-name` / `--build-number` from CI.
- **Performance budget:** cold start < 1.5s on a Pixel 6; ring animation locked at 60fps (prefer `CustomPainter` over heavy widgets); no jank during a running session even with the heatmap mounted.
- **Privacy:** no analytics in v1. If added later, opt-in only, no PII, document in-app.

## Visual direction

Premium, focused, slightly meditative. Not gamified-loud. Think Things 3 / Bear / Oak meets a Swiss watch face. Heavy negative space; the ring dominates. Typography: a clean geometric sans (e.g. `Inter` or `Geist`) + tabular numerals for the hour count so digits don't jitter. Subtle haptics on session start/pause/stop and on crossing every whole-hour boundary.

## How to work

1. **Start by asking me at most 3 clarifying questions** — only ones you cannot reasonably decide yourself and that materially change the build. Then propose a `pubspec.yaml`, folder structure, and a vertical-slice plan (slice 1 = "create pursuit, run a session, persist, see the ring update on relaunch"). Wait for my go-ahead.
2. Implement slice by slice. After each slice: `flutter analyze` clean, tests green, app runs on at least one simulator, then stop and show me before continuing.
3. Use `TaskCreate` to track slices. Mark each done the moment it lands.
4. When you face a real tradeoff (e.g. Drift vs Isar, CustomPainter vs `CircularProgressIndicator`, FCM vs local-only), surface it with a one-paragraph recommendation and the main alternative — don't bury it.
5. Do not invent features I didn't ask for. Do not add error handling for impossible states. Do not write comments that restate the code. No emoji in code or UI unless I ask.
6. If something needs a real device (push permissions, background fetch behavior on iOS, exact-alarm permission on Android 14), say so explicitly — don't claim success from a simulator.

## First message back to me

Reply with:
- Your 1–3 clarifying questions (or "none, I have what I need")
- Proposed `pubspec.yaml` dependency list with versions
- Proposed top-level folder tree
- Slice 1 scope, in 5–10 bullets

Do not write code yet.
