import Foundation
import SwiftData

// The persisted running/paused timer. There is at most one row at any time
// (the repository enforces the singleton by clearing before inserting).
@Model
final class ActiveSessionRow {
  var pursuitId: Int
  var startedAt: Date
  var pausedTotalMs: Int
  var pauseStartedAt: Date?

  init(pursuitId: Int, startedAt: Date, pausedTotalMs: Int = 0, pauseStartedAt: Date? = nil) {
    self.pursuitId = pursuitId
    self.startedAt = startedAt
    self.pausedTotalMs = pausedTotalMs
    self.pauseStartedAt = pauseStartedAt
  }
}
