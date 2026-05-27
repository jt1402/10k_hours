import ActivityKit
import Foundation

// Drives the Live Activity (Dynamic Island + lock screen) directly via
// ActivityKit — no method channel. Ported from the Flutter build's native
// LiveActivityController, retargeted at `TenKHoursActivityAttributes`.
//
// Live Activity is non-critical UX: every call guards/try-catches so it can
// never crash the app. The auto-ticking `Text(timerInterval:)` in the widget
// ticks locally with zero pushed updates; `targetEndAt` bounds it so it freezes
// at the goal instead of overshooting while backgrounded.
//
// The live `Activity` is looked up from `Activity.activities` rather than held
// across `await` (Swift 6 region isolation), so we only keep small value state.
@MainActor
final class LiveActivityController {
  static let shared = LiveActivityController()

  // Retained across updates so the bounded timer stays pinned to the goal even
  // when an update (pause, adaptive text) doesn't re-supply it.
  private var targetEndAt: Date?
  // Last synthetic start, kept so a finished-end can build a well-formed final
  // ContentState (the timer isn't shown once isFinished, but the range must
  // still be valid).
  private var lastEffectiveStartedAt: Date?

  func start(
    pursuitName: String,
    pursuitColorARGB: Int,
    effectiveStartedAt: Date,
    displayText: String? = nil,
    targetEndAt: Date? = nil
  ) async {
    let enabled = ActivityAuthorizationInfo().areActivitiesEnabled
    let orphanCount = Activity<TenKHoursActivityAttributes>.activities.count
    NSLog("[LA] start() name=\(pursuitName) enabled=\(enabled) orphans=\(orphanCount) target=\(String(describing: targetEndAt))")
    guard enabled else {
      NSLog("[LA] BAIL: areActivitiesEnabled == false")
      return
    }

    // Single-activity invariant: end any previous activity first (including
    // OS-owned orphans not tracked in-process, e.g. after reinstall) and AWAIT
    // the teardown — requesting a new activity while an old one is still live
    // makes ActivityKit drop the request, so the island intermittently fails to
    // appear (notably on a second/new pursuit).
    for orphan in Activity<TenKHoursActivityAttributes>.activities {
      await orphan.end(nil, dismissalPolicy: .immediate)
    }
    self.targetEndAt = targetEndAt
    self.lastEffectiveStartedAt = effectiveStartedAt

    let attrs = TenKHoursActivityAttributes(
      pursuitName: pursuitName,
      pursuitColorARGB: pursuitColorARGB
    )
    let state = TenKHoursActivityAttributes.ContentState(
      effectiveStartedAt: effectiveStartedAt,
      isPaused: false,
      pausedAtFreezeSeconds: 0,
      displayText: displayText,
      targetEndAt: targetEndAt
    )
    // Mark stale at the goal so the system dims it when the timer freezes there.
    let content = ActivityContent(state: state, staleDate: targetEndAt)
    do {
      let activity = try Activity.request(attributes: attrs, content: content, pushType: nil)
      NSLog("[LA] requested OK id=\(activity.id) activitiesNow=\(Activity<TenKHoursActivityAttributes>.activities.count)")
    } catch {
      NSLog("[LA] request THREW: \(error)")
    }
  }

  func update(
    effectiveStartedAt: Date,
    isPaused: Bool,
    pausedAtFreezeSeconds: Int,
    displayText: String? = nil
  ) async {
    guard let activity = Activity<TenKHoursActivityAttributes>.activities.first else { return }
    lastEffectiveStartedAt = effectiveStartedAt
    let state = TenKHoursActivityAttributes.ContentState(
      effectiveStartedAt: effectiveStartedAt,
      isPaused: isPaused,
      pausedAtFreezeSeconds: pausedAtFreezeSeconds,
      displayText: displayText,
      targetEndAt: targetEndAt
    )
    await activity.update(ActivityContent(state: state, staleDate: targetEndAt))
  }

  // Flip the *live* activity to its "Finished" state without ending it, so the
  // Dynamic Island stays and shows completion (an ended activity leaves only the
  // lock-screen card). Call `end()` later, once the user acknowledges. Works
  // whenever the app is foreground at the goal or on reopen — no push needed.
  func finish() async {
    guard let activity = Activity<TenKHoursActivityAttributes>.activities.first else { return }
    let state = TenKHoursActivityAttributes.ContentState(
      effectiveStartedAt: lastEffectiveStartedAt ?? targetEndAt ?? Date(),
      isPaused: false,
      pausedAtFreezeSeconds: 0,
      displayText: nil,
      targetEndAt: targetEndAt,
      isFinished: true
    )
    // staleDate nil so the system doesn't dim the (now intentionally) lingering card.
    await activity.update(ActivityContent(state: state, staleDate: nil))
  }

  // End *every* custom activity (not just the first). Used before handing the
  // island to AlarmKit, so a leftover custom activity can't make the system
  // collapse both to minimal pills.
  func endAll() async {
    let activities = Activity<TenKHoursActivityAttributes>.activities
    NSLog("[LA] endAll: ending \(activities.count) custom activities")
    for activity in activities {
      await activity.end(nil, dismissalPolicy: .immediate)
    }
    targetEndAt = nil
    lastEffectiveStartedAt = nil
  }

  // `finished` true when the pursuit's goal was reached: ends with a "Finished"
  // final content + `.default` dismissal, so the Dynamic Island clears but the
  // lock-screen card lingers. A manual stop (`finished: false`) removes it now.
  func end(finished: Bool = false) async {
    guard let activity = Activity<TenKHoursActivityAttributes>.activities.first else { return }
    if finished {
      let state = TenKHoursActivityAttributes.ContentState(
        effectiveStartedAt: lastEffectiveStartedAt ?? targetEndAt ?? Date(),
        isPaused: false,
        pausedAtFreezeSeconds: 0,
        displayText: nil,
        targetEndAt: targetEndAt,
        isFinished: true
      )
      await activity.end(ActivityContent(state: state, staleDate: nil), dismissalPolicy: .default)
    } else {
      await activity.end(nil, dismissalPolicy: .immediate)
    }
    self.targetEndAt = nil
    self.lastEffectiveStartedAt = nil
  }
}
