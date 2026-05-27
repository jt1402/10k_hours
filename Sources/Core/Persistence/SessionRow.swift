import Foundation
import SwiftData

// Persisted completed-session row. Duration is stored in whole milliseconds
// (matching the Flutter `durationMs` column) to avoid float drift on disk.
// Sub-60s rows are kept for honest history but excluded from stats at read time.
@Model
final class SessionRow {
  var pursuitId: Int
  var startedAt: Date
  var endedAt: Date
  var durationMs: Int

  init(pursuitId: Int, startedAt: Date, endedAt: Date, durationMs: Int) {
    self.pursuitId = pursuitId
    self.startedAt = startedAt
    self.endedAt = endedAt
    self.durationMs = durationMs
  }

  var durationSeconds: TimeInterval { Double(durationMs) / 1000 }
}
