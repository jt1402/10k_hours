import Foundation
import SwiftData

// A pursuit being tracked toward its goal. SwiftData-backed; used directly by
// the UI via @Query. `id` is an app-assigned logical int (matches the Flutter
// schema and the `pursuitId` carried by sessions and the Live Activity).
@Model
final class Pursuit {
  @Attribute(.unique) var id: Int
  var name: String
  /// 32-bit ARGB accent color.
  var accentColor: Int
  /// Legacy goal in minutes (default 10,000 hours). Kept for back-compat; the
  /// timer reads `goalSeconds`, which prefers `targetSecondsExact` when set.
  var targetMinutes: Int
  /// Exact goal in seconds. Preferred when present — supports sub-minute targets
  /// (handy for testing). Optional so existing stores migrate automatically.
  var targetSecondsExact: Int?
  var createdAt: Date
  /// When cumulative covered duration first reached the goal. Gates the
  /// one-time celebration sheet and the "Completed" timer UI.
  var completedAt: Date?

  init(
    id: Int,
    name: String,
    accentColor: Int = AppConstants.defaultAccentColorARGB,
    targetMinutes: Int = AppConstants.defaultTargetMinutes,
    targetSecondsExact: Int? = nil,
    createdAt: Date,
    completedAt: Date? = nil
  ) {
    self.id = id
    self.name = name
    self.accentColor = accentColor
    self.targetMinutes = targetMinutes
    self.targetSecondsExact = targetSecondsExact
    self.createdAt = createdAt
    self.completedAt = completedAt
  }

  /// Effective goal in seconds — the single source of truth for the timer, ring,
  /// completion, and Live Activity. Falls back to `targetMinutes` for old rows.
  var goalSeconds: Int { targetSecondsExact ?? targetMinutes * 60 }
}
