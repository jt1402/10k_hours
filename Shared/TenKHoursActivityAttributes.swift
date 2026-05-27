import ActivityKit
import Foundation

// Shared between the app and the widget extension. The widget renders
// ContentState into the lock-screen and Dynamic Island; the app pushes updates
// via Activity.update(...). Ported from the Flutter build's attributes.
public struct TenKHoursActivityAttributes: ActivityAttributes {
  public struct ContentState: Codable, Hashable {
    // The instant such that `now - effectiveStartedAt = elapsed`. Lets
    // SwiftUI's Text(timerInterval:) tick locally with no updates.
    public var effectiveStartedAt: Date
    public var isPaused: Bool
    // When paused, the frozen elapsed seconds (for static display).
    public var pausedAtFreezeSeconds: Int
    // Optional pre-formatted text (adaptive H:MM / Nh formats that
    // timerInterval can't produce). When set, shown instead of the ticker.
    public var displayText: String?
    // Wall-clock instant the target is reached. Bounds the auto-ticking timer
    // so it freezes at the goal instead of overshooting while backgrounded;
    // also used as the activity's staleDate.
    public var targetEndAt: Date?
    // Set on the final content when the app ends the activity, so the
    // lingering lock-screen card shows "Finished".
    public var isFinished: Bool

    public init(
      effectiveStartedAt: Date,
      isPaused: Bool = false,
      pausedAtFreezeSeconds: Int = 0,
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
