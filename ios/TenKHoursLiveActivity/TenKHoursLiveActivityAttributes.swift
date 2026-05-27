import ActivityKit
import Foundation

// Shared between the main app and the Widget Extension target.
// The widget consumes ContentState to render the lock-screen and Dynamic
// Island views. The main app pushes updates via Activity.update(...).
public struct TenKHoursLiveActivityAttributes: ActivityAttributes {
  public struct ContentState: Codable, Hashable {
    // The instant such that `now - effectiveStartedAt = elapsed`.
    // This lets SwiftUI's Text(timerInterval:) tick locally with no updates.
    public var effectiveStartedAt: Date
    public var isPaused: Bool
    // When paused, the frozen elapsed seconds (used for static display).
    public var pausedAtFreezeSeconds: Int
    // Optional pre-formatted text. When set (non-nil), the widget displays
    // this instead of the auto-ticking Text(timerInterval:). Pushed from Dart
    // for adaptive formats (H:MM, Nh) that timerInterval can't produce.
    public var displayText: String?
    // The wall-clock instant the pursuit's target is reached. When set, the
    // auto-ticking Text(timerInterval:) is bounded to this date so it freezes
    // at the goal instead of overshooting while the app is backgrounded. It is
    // also used as the activity's staleDate, so the widget can flip to the
    // "Finished" state via context.isStale with no update/push.
    public var targetEndAt: Date?
    // Explicitly marks the activity as completed. Set in the final content when
    // the app ends the activity on reopen, so the lingering lock-screen card
    // shows "Finished" even though it is no longer stale.
    public var isFinished: Bool

    public init(
      effectiveStartedAt: Date,
      isPaused: Bool,
      pausedAtFreezeSeconds: Int,
      displayText: String? = nil,
      targetEndAt: Date? = nil,
      isFinished: Bool = false
    ) {
      self.effectiveStartedAt = effectiveStartedAt
      self.isPaused = isPaused
      self.pausedAtFreezeSeconds = pausedAtFreezeSeconds
      self.displayText = displayText
      self.targetEndAt = targetEndAt
      self.isFinished = isFinished
    }
  }

  public var pursuitName: String
  public var pursuitColorARGB: Int

  public init(pursuitName: String, pursuitColorARGB: Int) {
    self.pursuitName = pursuitName
    self.pursuitColorARGB = pursuitColorARGB
  }
}
