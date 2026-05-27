import Foundation

#if canImport(AlarmKit)
import ActivityKit
import AlarmKit
import SwiftUI

// AlarmKit goal alarm (iOS 26+). Two roles:
//
//  1. `startCountdown(...)` — the AlarmKit-OWNED Live Activity for near goals.
//     AlarmKit drives a countdown Live Activity (Dynamic Island + lock screen)
//     and the OS transitions countdown → alert at the goal automatically, so
//     the island flips to "Finished" live even while the app is suspended — the
//     only no-push way to do that. Mirrored to the session via pause/resume/stop.
//
//  2. `schedule(fireAt:...)` — a plain fixed-date *alert* alarm for FAR goals
//     (where a countdown Live Activity would be a nonsensical ~year-long timer).
//     The custom count-up Live Activity owns the island in that case.
//
// Session *finalization* (marking complete, banking the clamped session) is
// handled independently by the engine's wall-clock check on foreground, so this
// controller does not need to observe `alarmUpdates` for correctness. (Tapping
// the island's own pause/stop button is therefore not yet mirrored back into the
// session — a known v1 edge case; in-app actions drive the alarm correctly.)
// Non-critical: never crashes the app.
@available(iOS 26.0, *)
@MainActor
final class AlarmController {
  static let shared = AlarmController()

  private var alarmID: UUID?

  // MARK: AlarmKit-owned countdown Live Activity (near goals)

  func startCountdown(remaining: TimeInterval, pursuitName: String, colorARGB: Int) async {
    guard remaining > 0 else { return }
    guard await ensureAuthorized() else { NSLog("[GoalAlarm] startCountdown BAIL: not authorized"); return }
    NSLog("[GoalAlarm] alarms before cleanup: \((try? AlarmManager.shared.alarms)?.count ?? -1)")
    await cancel()
    await endLeftoverActivities()

    let countdown = AlarmPresentation.Countdown(
      title: LocalizedStringResource(stringLiteral: pursuitName),
      pauseButton: AlarmButton(text: "Pause", textColor: .white, systemImageName: "pause.fill")
    )
    let paused = AlarmPresentation.Paused(
      title: "Paused",
      resumeButton: AlarmButton(text: "Resume", textColor: .white, systemImageName: "play.fill")
    )
    let alert = AlarmPresentation.Alert(
      title: LocalizedStringResource(stringLiteral: "\(pursuitName) — goal reached"),
      stopButton: AlarmButton(text: "Done", textColor: .white, systemImageName: "checkmark")
    )
    let attributes = AlarmAttributes<GoalMetadata>(
      presentation: AlarmPresentation(alert: alert, countdown: countdown, paused: paused),
      metadata: GoalMetadata(pursuitName: pursuitName, pursuitColorARGB: colorARGB),
      tintColor: Color(argb: colorARGB)
    )
    let id = UUID()
    let configuration = AlarmManager.AlarmConfiguration.timer(
      duration: remaining,
      attributes: attributes,
      stopIntent: nil,
      secondaryIntent: nil,
      sound: .default
    )
    do {
      _ = try await AlarmManager.shared.schedule(id: id, configuration: configuration)
      alarmID = id
      NSLog("[GoalAlarm] countdown scheduled \(id) remaining=\(remaining); alarms now=\((try? AlarmManager.shared.alarms)?.count ?? -1)")
    } catch {
      NSLog("[GoalAlarm] countdown schedule failed: \(error)")
    }
  }

  func pauseCountdown() {
    guard let id = alarmID else { return }
    try? AlarmManager.shared.pause(id: id)
  }

  func resumeCountdown() {
    guard let id = alarmID else { return }
    try? AlarmManager.shared.resume(id: id)
  }

  // MARK: fixed-date alert alarm (far goals)

  func schedule(fireAt: Date, pursuitName: String, colorARGB: Int) async {
    guard fireAt > Date() else { return }
    guard await ensureAuthorized() else { return }
    await cancel()

    let alert = AlarmPresentation.Alert(
      title: LocalizedStringResource(stringLiteral: "\(pursuitName) — goal reached"),
      stopButton: AlarmButton(text: "Done", textColor: .white, systemImageName: "checkmark")
    )
    let attributes = AlarmAttributes<GoalMetadata>(
      presentation: AlarmPresentation(alert: alert),
      metadata: GoalMetadata(pursuitName: pursuitName, pursuitColorARGB: colorARGB),
      tintColor: Color(argb: colorARGB)
    )
    let id = UUID()
    let configuration = AlarmManager.AlarmConfiguration(
      schedule: .fixed(fireAt),
      attributes: attributes
    )
    do {
      _ = try await AlarmManager.shared.schedule(id: id, configuration: configuration)
      alarmID = id
    } catch {
      NSLog("[GoalAlarm] schedule failed: \(error)")
    }
  }

  // MARK: lifecycle

  // Cancels EVERY alarm this app owns — not just the one we're tracking — so
  // cold-start orphans (whose in-memory id was lost) can't linger as a second
  // AlarmKit Live Activity and collapse the Dynamic Island to minimal pills.
  func cancel() async {
    let alarms = (try? AlarmManager.shared.alarms) ?? []
    NSLog("[GoalAlarm] cancel(): clearing \(alarms.count) alarm(s)")
    for alarm in alarms {
      // An *alerting* (fired-but-not-dismissed) alarm is cleared by stop(); a
      // scheduled/countdown one by cancel(). Try both so a leftover alert from a
      // prior run can't linger as a second Live Activity and collapse the island.
      try? AlarmManager.shared.stop(id: alarm.id)
      try? AlarmManager.shared.cancel(id: alarm.id)
    }
    alarmID = nil
  }

  // End any leftover AlarmKit Live Activities. Swiping the fired alert UP
  // dismisses it WITHOUT stopping the alarm, leaving its activity orphaned —
  // and it's no longer in `AlarmManager.alarms`, so `cancel()` can't reach it.
  // A second concurrent activity collapses the next session's Dynamic Island,
  // so we end them via ActivityKit before scheduling a fresh countdown.
  private func endLeftoverActivities() async {
    let leftovers = Activity<AlarmAttributes<GoalMetadata>>.activities
    NSLog("[GoalAlarm] leftover AlarmKit activities: \(leftovers.count)")
    for activity in leftovers {
      await activity.end(nil, dismissalPolicy: .immediate)
    }
  }

  private func ensureAuthorized() async -> Bool {
    switch AlarmManager.shared.authorizationState {
    case .authorized:
      return true
    case .notDetermined:
      do {
        return try await AlarmManager.shared.requestAuthorization() == .authorized
      } catch {
        return false
      }
    case .denied:
      return false
    @unknown default:
      return false
    }
  }
}
#endif
