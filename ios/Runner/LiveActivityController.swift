import ActivityKit
import Foundation
#if canImport(AlarmKit)
import AlarmKit
import SwiftUI
#endif

@available(iOS 16.2, *)
final class LiveActivityController {
  static let shared = LiveActivityController()

  private var activity: Activity<TenKHoursLiveActivityAttributes>?
  // Retained across updates so the auto-ticking timer stays bounded to the
  // goal even when an update (pause, adaptive text) doesn't re-supply it.
  private var targetEndAt: Date?
  // Last synthetic start, kept so a finished-end can build a valid final
  // ContentState (the timer isn't shown once isFinished, but the range must
  // still be well-formed).
  private var lastEffectiveStartedAt: Date?

  func start(
    pursuitName: String,
    pursuitColorARGB: Int,
    effectiveStartedAt: Date,
    displayText: String? = nil,
    targetEndAt: Date? = nil
  ) {
    NSLog("[LiveActivity] start called for \(pursuitName)")
    guard ActivityAuthorizationInfo().areActivitiesEnabled else {
      NSLog("[LiveActivity] areActivitiesEnabled=false — bailing")
      return
    }
    // Single-activity invariant: end any previous activity first.
    // Also catches orphans owned by the OS but not tracked in-process
    // (e.g. after app reinstall while a previous activity was live).
    let orphans = Activity<TenKHoursLiveActivityAttributes>.activities
    for orphan in orphans {
      Task { await orphan.end(nil, dismissalPolicy: .immediate) }
    }
    activity = nil
    self.targetEndAt = targetEndAt
    self.lastEffectiveStartedAt = effectiveStartedAt
    let attrs = TenKHoursLiveActivityAttributes(
      pursuitName: pursuitName,
      pursuitColorARGB: pursuitColorARGB
    )
    let state = TenKHoursLiveActivityAttributes.ContentState(
      effectiveStartedAt: effectiveStartedAt,
      isPaused: false,
      pausedAtFreezeSeconds: 0,
      displayText: displayText,
      targetEndAt: targetEndAt
    )
    // Mark the activity stale at the goal so the system dims it once the timer
    // freezes there, signalling completion without a push update.
    let content = ActivityContent(state: state, staleDate: targetEndAt)
    do {
      activity = try Activity.request(
        attributes: attrs,
        content: content,
        pushType: nil
      )
      NSLog("[LiveActivity] started, id=\(activity?.id ?? "nil")")
    } catch {
      NSLog("[LiveActivity] start failed: \(error)")
    }
  }

  func update(
    effectiveStartedAt: Date,
    isPaused: Bool,
    pausedAtFreezeSeconds: Int,
    displayText: String? = nil
  ) async {
    guard let activity = activity else { return }
    self.lastEffectiveStartedAt = effectiveStartedAt
    let state = TenKHoursLiveActivityAttributes.ContentState(
      effectiveStartedAt: effectiveStartedAt,
      isPaused: isPaused,
      pausedAtFreezeSeconds: pausedAtFreezeSeconds,
      displayText: displayText,
      targetEndAt: targetEndAt
    )
    let content = ActivityContent(state: state, staleDate: targetEndAt)
    await activity.update(content)
  }

  // [finished] true when the pursuit's goal was reached: the activity ends with
  // a "Finished" final content and .default dismissal, so the Dynamic Island
  // clears but the lock-screen card lingers showing completion. A manual stop
  // ([finished] false) removes it immediately.
  func end(finished: Bool = false) async {
    guard let activity = activity else { return }
    if finished {
      let state = TenKHoursLiveActivityAttributes.ContentState(
        effectiveStartedAt: lastEffectiveStartedAt ?? targetEndAt ?? Date(),
        isPaused: false,
        pausedAtFreezeSeconds: 0,
        displayText: nil,
        targetEndAt: targetEndAt,
        isFinished: true
      )
      let content = ActivityContent(state: state, staleDate: nil)
      await activity.end(content, dismissalPolicy: .default)
    } else {
      await activity.end(nil, dismissalPolicy: .immediate)
    }
    self.activity = nil
    self.targetEndAt = nil
    self.lastEffectiveStartedAt = nil
  }
}

#if canImport(AlarmKit)
// One-shot goal alarm backed by AlarmKit (iOS 26+). Schedules a system alarm
// that fires at the pursuit's goal time even while the app is suspended — the
// "live" at-goal moment we can't get from a Live Activity without push.
//
// Alert-only presentation (no countdown), so it does not compete with the
// custom Live Activity above; the system renders the alert when it fires.
@available(iOS 26.0, *)
final class AlarmController {
  static let shared = AlarmController()

  // Empty metadata — we need no custom per-alarm data, but AlarmKit's generics
  // require a concrete AlarmMetadata type.
  nonisolated struct GoalMetadata: AlarmMetadata {}

  private let manager = AlarmManager.shared
  private var alarmID: UUID?

  func schedule(fireAt: Date, pursuitName: String, colorARGB: Int) async {
    // Don't schedule in the past; AlarmKit would reject it.
    guard fireAt > Date() else { return }
    guard await ensureAuthorized() else { return }

    // Replace any existing goal alarm first.
    await cancel()

    let alert = AlarmPresentation.Alert(
      title: LocalizedStringResource(stringLiteral: "\(pursuitName) — goal reached"),
      stopButton: AlarmButton(
        text: "Done",
        textColor: .white,
        systemImageName: "checkmark"
      )
    )
    let attributes = AlarmAttributes<GoalMetadata>(
      presentation: AlarmPresentation(alert: alert),
      metadata: GoalMetadata(),
      tintColor: Self.color(fromARGB: colorARGB)
    )
    let id = UUID()
    let configuration = AlarmManager.AlarmConfiguration(
      schedule: .fixed(fireAt),
      attributes: attributes
    )
    do {
      _ = try await manager.schedule(id: id, configuration: configuration)
      alarmID = id
      NSLog("[GoalAlarm] scheduled \(id) at \(fireAt)")
    } catch {
      NSLog("[GoalAlarm] schedule failed: \(error)")
    }
  }

  func cancel() async {
    guard let id = alarmID else { return }
    do {
      try manager.cancel(id: id)
    } catch {
      NSLog("[GoalAlarm] cancel failed: \(error)")
    }
    alarmID = nil
  }

  private func ensureAuthorized() async -> Bool {
    switch manager.authorizationState {
    case .authorized:
      return true
    case .notDetermined:
      do {
        return try await manager.requestAuthorization() == .authorized
      } catch {
        NSLog("[GoalAlarm] authorization failed: \(error)")
        return false
      }
    case .denied:
      return false
    @unknown default:
      return false
    }
  }

  private static func color(fromARGB argb: Int) -> Color {
    let r = Double((argb >> 16) & 0xFF) / 255.0
    let g = Double((argb >> 8) & 0xFF) / 255.0
    let b = Double(argb & 0xFF) / 255.0
    return Color(.sRGB, red: r, green: g, blue: b, opacity: 1.0)
  }
}
#endif
