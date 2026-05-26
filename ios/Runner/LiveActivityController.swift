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
    guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }
    // Single-activity invariant: end any previous activity first.
    if let existing = activity {
      Task { await existing.end(nil, dismissalPolicy: .immediate) }
      activity = nil
    }
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
    } catch {
      NSLog("LiveActivityController.start failed: \(error)")
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
