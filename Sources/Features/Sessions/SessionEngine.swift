import Foundation
import SwiftData
import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

// Per-pursuit timer orchestration: the native equivalent of the Flutter
// `_TimerScreenState`. Owns the 1-second ticker, drives the Live Activity and
// goal alarm, and runs the fire-once goal-completion / background-overshoot
// clamp from every hook (ticker, stop, pause, app resume).
//
// Reactive reads (pursuit, sessions, active row) come from @Query in the views;
// the engine reads fresh from the context for its orchestration math.
@Observable
@MainActor
final class SessionEngine {
  let pursuitId: Int

  /// Ticked every second while running; views read it to recompute elapsed.
  var now: Date = Date()
  /// Set when the goal is reached so the view presents the completion sheet.
  var pendingCompletionPursuitId: Int?

  @ObservationIgnored private let context: ModelContext
  @ObservationIgnored private let service: SessionService
  @ObservationIgnored private let store: PursuitStore
  @ObservationIgnored private let live = LiveActivityController.shared

  // Which surface owns the Dynamic Island for the current session.
  // `.alarmKit` = AlarmKit-owned countdown LA (near goals, iOS 26+, flips to
  // "Finished" live even suspended). `.custom` = our count-up LA (far goals /
  // iOS 18–25). Decided at start/resume; held for the session.
  private enum LiveMode { case none, custom, alarmKit }
  @ObservationIgnored private var liveMode: LiveMode = .none

  @ObservationIgnored private var ticker: Timer?
  @ObservationIgnored private var celebrationFired = false
  @ObservationIgnored private var liveActivityBootstrapped = false
  @ObservationIgnored private var lastWholeHoursElapsed = -1
  @ObservationIgnored private var lastAdaptivePushed: String?
  @ObservationIgnored private var lastAdaptivePushAt: Date?

  init(pursuitId: Int, context: ModelContext) {
    self.pursuitId = pursuitId
    self.context = context
    self.service = SessionService(repo: SwiftDataSessionRepository(context: context))
    self.store = PursuitStore(context: context)
  }

  // MARK: reads

  private var activeSession: ActiveSession? { try? service.repo.getActive() }
  private var pursuit: Pursuit? { store.byId(pursuitId) }
  private var activeForThisPursuit: ActiveSession? {
    guard let a = activeSession, a.pursuitId == pursuitId else { return nil }
    return a
  }

  private func totalCounted() -> TimeInterval {
    SessionStats.totalCounted(pursuitId: pursuitId, context: context)
  }

  // MARK: ticker

  func onAppear() {
    now = Date()
    syncTicker()
    Task { await bootstrapLiveActivityIfNeeded() }
    if let p = pursuit, p.completedAt != nil { celebrationFired = true }
    checkCompletion()
  }

  func onDisappear() { stopTicker() }

  func onScenePhaseActive() {
    now = Date()
    checkCompletion()
  }

  private func syncTicker() {
    let needs = activeForThisPursuit.map { !$0.isPaused } ?? false
    if needs { startTicker() } else { stopTicker() }
  }

  private func startTicker() {
    now = Date()  // refresh immediately so the first render after (re)start isn't stale
    guard ticker == nil else { return }
    ticker = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
      Task { @MainActor in self?.tick() }
    }
  }

  private func stopTicker() {
    ticker?.invalidate()
    ticker = nil
  }

  private func tick() {
    now = Date()
    maybeHourBoundaryHaptic()
    Task { await maybePushAdaptiveDisplay() }
    checkCompletion()
  }

  // MARK: actions

  /// tap = start / pause / resume.
  func primaryTap() async {
    guard let pursuit else { NSLog("[Engine] primaryTap: no pursuit"); return }
    now = Date()  // fresh now so re-renders during the async work below aren't stale
    let active = activeForThisPursuit
    NSLog("[Engine] primaryTap pursuit=\(pursuit.id) active=\(active != nil) paused=\(active?.isPaused ?? false)")

    if active == nil {
      guard let started = try? service.start(pursuitId: pursuitId) else { return }
      Haptics.light()
      await startLiveActivity(pursuit: pursuit, effectiveStart: started.startedAt, elapsed: 0)
    } else if active!.isPaused {
      guard let resumed = try? service.resume() else { return }
      Haptics.light()
      if liveMode == .alarmKit {
        if #available(iOS 26.0, *) { AlarmController.shared.resumeCountdown() }
      } else {
        let elapsed = resumed.elapsed(at: Date())
        await startLiveActivity(pursuit: pursuit, effectiveStart: Date().addingTimeInterval(-elapsed), elapsed: elapsed)
      }
    } else {
      guard let paused = try? service.pause() else { return }
      Haptics.light()
      if liveMode == .alarmKit {
        if #available(iOS 26.0, *) { AlarmController.shared.pauseCountdown() }
      } else {
        let elapsed = paused.elapsed(at: Date())
        await live.update(
          effectiveStartedAt: paused.startedAt,
          isPaused: true,
          pausedAtFreezeSeconds: Int(elapsed),
          displayText: nil
        )
        await cancelAlarm()  // paused → goal time indefinite
      }
      lastAdaptivePushed = nil
      lastAdaptivePushAt = nil
      checkCompletion()
    }
    syncTicker()
  }

  // Start the right Live Activity for this session. AlarmKit owns the island
  // (countdown that flips to "Finished" live, even suspended) when the goal is
  // near and on iOS 26+; otherwise the custom count-up LA + a fixed-date far-goal
  // alarm. `elapsed` is the current session's elapsed seconds (0 on a fresh start).
  private func startLiveActivity(pursuit: Pursuit, effectiveStart: Date, elapsed: TimeInterval) async {
    let remaining = TimeInterval(pursuit.goalSeconds) - totalCounted() - elapsed
    NSLog("[Engine] startLiveActivity remaining=\(remaining) maxAK=\(AppConstants.alarmKitCountdownMaxSeconds)")
    if #available(iOS 26.0, *), remaining > 0, remaining <= AppConstants.alarmKitCountdownMaxSeconds {
      NSLog("[Engine] live mode = alarmKit")
      await live.endAll()  // ensure no stale custom activity competes for the island
      await AlarmController.shared.startCountdown(
        remaining: remaining,
        pursuitName: pursuit.name,
        colorARGB: pursuit.accentColor
      )
      liveMode = .alarmKit
      lastAdaptivePushed = nil
      lastAdaptivePushAt = nil
    } else {
      NSLog("[Engine] live mode = custom")
      let initialText = Self.adaptiveDisplay(elapsed)
      let targetEndAt = liveTargetEndAt(effectiveStart: effectiveStart, pursuit: pursuit)
      await live.start(
        pursuitName: pursuit.name,
        pursuitColorARGB: pursuit.accentColor,
        effectiveStartedAt: effectiveStart,
        displayText: initialText,
        targetEndAt: targetEndAt
      )
      syncGoalAlarm(pursuit: pursuit, targetEndAt: targetEndAt)
      liveMode = .custom
      lastAdaptivePushed = initialText
      lastAdaptivePushAt = initialText == nil ? nil : Date()
    }
  }

  private func endLiveActivity() async {
    if liveMode == .alarmKit {
      await cancelAlarm()
    } else {
      await live.end()
      await cancelAlarm()
    }
    liveMode = .none
  }

  /// long-press = stop. Returns whether the session counted (≥60s) for UI.
  @discardableResult
  func stop() async -> Bool {
    guard activeForThisPursuit != nil else { return true }
    let result = try? service.stop()
    Haptics.medium()
    await endLiveActivity()
    lastWholeHoursElapsed = -1
    lastAdaptivePushed = nil
    lastAdaptivePushAt = nil
    stopTicker()
    checkCompletion()
    return result?.countedTowardStats ?? true
  }

  // MARK: completion (fire-once, with background-overshoot clamp)

  func checkCompletion() {
    guard !celebrationFired, let pursuit, pursuit.completedAt == nil else { return }
    let total = totalCounted()
    let activeElapsed = activeForThisPursuit?.elapsed(at: Date()) ?? 0
    let cumulative = total + activeElapsed
    guard cumulative >= TimeInterval(pursuit.goalSeconds) else { return }
    celebrationFired = true
    Task { await fireCompletion(pursuit: pursuit) }
  }

  private func fireCompletion(pursuit: Pursuit) async {
    var completedAt = Date()
    if let active = activeForThisPursuit {
      // Backgrounded crossings are only detected on resume — well past the
      // target. Record the session ending at the exact crossing so the
      // overshoot isn't banked. (See PROGRESS "Background overshoot clamp".)
      let priorCounted = totalCounted()
      let target = TimeInterval(pursuit.goalSeconds)
      let endAt = active.completionEndAt(priorCounted: priorCounted, target: target, now: Date()) ?? Date()
      completedAt = endAt
      _ = try? service.stop(endAt: endAt)
      if liveMode == .custom {
        // Keep the activity alive but flipped to "Finished" so the island shows
        // completion (vs. vanishing). Ended in acknowledgeCompletion().
        await live.finish()
        await cancelAlarm()
      } else if UIApplication.shared.applicationState == .active {
        // AlarmKit mode: suppress the ring ONLY when the app is genuinely
        // foreground right now (the user sees the in-app completion sheet). We
        // check the live app state — NOT "did the ticker fire" — because under
        // the Xcode debugger (and the brief pre-suspension window) the ticker
        // keeps running while backgrounded, which would cancel the alarm right
        // after it rang. Backgrounded/locked → not .active → leave it ringing.
        await cancelAlarm()
      }
      liveMode = .none
      lastAdaptivePushed = nil
      lastAdaptivePushAt = nil
      stopTicker()
    }
    store.markCompleted(pursuitId, at: completedAt)
    Haptics.heavy()
    pendingCompletionPursuitId = pursuitId
  }

  /// Called when the user dismisses the completion sheet (taps Done): the goal
  /// has been acknowledged, so end the lingering "Finished" Live Activity.
  func acknowledgeCompletion() async {
    pendingCompletionPursuitId = nil
    await live.end(finished: true)
  }

  // MARK: Live Activity helpers

  // Wall-clock instant the cumulative target is reached given the LA's
  // synthetic effectiveStart. Bounds the auto-ticking timer so it freezes at
  // the goal. Nil when the target is already met (timer ticks unbounded).
  private func liveTargetEndAt(effectiveStart: Date, pursuit: Pursuit) -> Date? {
    let remaining = TimeInterval(pursuit.goalSeconds) - totalCounted()
    guard remaining > 0 else { return nil }
    return effectiveStart.addingTimeInterval(remaining)
  }

  private func bootstrapLiveActivityIfNeeded() async {
    guard let active = activeForThisPursuit else {
      liveActivityBootstrapped = false
      return
    }
    guard !liveActivityBootstrapped, let pursuit else { return }
    liveActivityBootstrapped = true
    let elapsed = active.elapsed(at: Date())
    let effectiveStart = Date().addingTimeInterval(-elapsed)
    if active.isPaused {
      // Re-establish the custom paused card on cold-start (AlarmKit-owned paused
      // cold-start isn't reconstructed; resuming re-decides the mode).
      let targetEndAt = liveTargetEndAt(effectiveStart: effectiveStart, pursuit: pursuit)
      await live.start(
        pursuitName: pursuit.name,
        pursuitColorARGB: pursuit.accentColor,
        effectiveStartedAt: effectiveStart,
        displayText: nil,
        targetEndAt: targetEndAt
      )
      await live.update(
        effectiveStartedAt: effectiveStart,
        isPaused: true,
        pausedAtFreezeSeconds: Int(elapsed),
        displayText: nil
      )
      await cancelAlarm()
      liveMode = .custom
    } else {
      await startLiveActivity(pursuit: pursuit, effectiveStart: effectiveStart, elapsed: elapsed)
    }
  }

  // Push an adaptive string to the LA when elapsed crosses 1h (auto-tick can't
  // render H:MM / Nh). Spaced ≥30s to stay within ActivityKit's update budget.
  private func maybePushAdaptiveDisplay() async {
    guard liveMode == .custom else { return }  // AlarmKit owns its own LA content
    guard let active = activeForThisPursuit, !active.isPaused else { return }
    let elapsed = active.elapsed(at: Date())
    guard let text = Self.adaptiveDisplay(elapsed) else {
      lastAdaptivePushed = nil
      lastAdaptivePushAt = nil
      return
    }
    if let at = lastAdaptivePushAt, Date().timeIntervalSince(at) < 30 { return }
    lastAdaptivePushed = text
    lastAdaptivePushAt = Date()
    await live.update(
      effectiveStartedAt: active.startedAt,
      isPaused: false,
      pausedAtFreezeSeconds: 0,
      displayText: text
    )
  }

  static func adaptiveDisplay(_ elapsed: TimeInterval) -> String? {
    let h = Int(elapsed) / 3600
    let m = (Int(elapsed) % 3600) / 60
    if h >= 100 { return "\(h)h" }
    if h >= 1 { return String(format: "%d:%02d", h, m) }
    return nil
  }

  private func maybeHourBoundaryHaptic() {
    let total = totalCounted() + (activeForThisPursuit?.elapsed(at: Date()) ?? 0)
    let hours = Int(total) / 3600
    if lastWholeHoursElapsed < 0 { lastWholeHoursElapsed = hours; return }
    if hours > lastWholeHoursElapsed {
      lastWholeHoursElapsed = hours
      Haptics.heavy()
    }
  }

  // MARK: alarm (iOS 26+)

  private func syncGoalAlarm(pursuit: Pursuit, targetEndAt: Date?) {
    if #available(iOS 26.0, *) {
      if let at = targetEndAt {
        Task { await AlarmController.shared.schedule(fireAt: at, pursuitName: pursuit.name, colorARGB: pursuit.accentColor) }
      } else {
        Task { await AlarmController.shared.cancel() }
      }
    }
  }

  private func cancelAlarm() async {
    if #available(iOS 26.0, *) {
      await AlarmController.shared.cancel()
    }
  }
}

@MainActor
enum Haptics {
  static func light() { impact(.light) }
  static func medium() { impact(.medium) }
  static func heavy() { impact(.heavy) }

  private static func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
    #if canImport(UIKit)
    UIImpactFeedbackGenerator(style: style).impactOccurred()
    #endif
  }
}
