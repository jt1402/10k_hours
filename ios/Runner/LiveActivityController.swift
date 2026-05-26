import ActivityKit
import Foundation

@available(iOS 16.2, *)
final class LiveActivityController {
  static let shared = LiveActivityController()

  private var activity: Activity<TenKHoursLiveActivityAttributes>?

  func start(
    pursuitName: String,
    pursuitColorARGB: Int,
    effectiveStartedAt: Date
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
    let attrs = TenKHoursLiveActivityAttributes(
      pursuitName: pursuitName,
      pursuitColorARGB: pursuitColorARGB
    )
    let state = TenKHoursLiveActivityAttributes.ContentState(
      effectiveStartedAt: effectiveStartedAt,
      isPaused: false,
      pausedAtFreezeSeconds: 0
    )
    let content = ActivityContent(state: state, staleDate: nil)
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
    pausedAtFreezeSeconds: Int
  ) async {
    guard let activity = activity else { return }
    let state = TenKHoursLiveActivityAttributes.ContentState(
      effectiveStartedAt: effectiveStartedAt,
      isPaused: isPaused,
      pausedAtFreezeSeconds: pausedAtFreezeSeconds
    )
    let content = ActivityContent(state: state, staleDate: nil)
    await activity.update(content)
  }

  func end() async {
    guard let activity = activity else { return }
    await activity.end(nil, dismissalPolicy: .immediate)
    self.activity = nil
  }
}
