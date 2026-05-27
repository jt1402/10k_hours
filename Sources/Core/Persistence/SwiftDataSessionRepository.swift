import Foundation
import SwiftData

// Bridges the pure `SessionService` to SwiftData, mapping rows ↔ pure values.
// Synchronous: every call runs on the supplied context's actor (the main
// context). Durations cross the boundary as whole milliseconds.
final class SwiftDataSessionRepository: SessionRepository {
  private let context: ModelContext

  init(context: ModelContext) {
    self.context = context
  }

  func getActive() throws -> ActiveSession? {
    guard let row = try context.fetch(FetchDescriptor<ActiveSessionRow>()).first else {
      return nil
    }
    return ActiveSession(
      pursuitId: row.pursuitId,
      startedAt: row.startedAt,
      pausedTotal: Double(row.pausedTotalMs) / 1000,
      pauseStartedAt: row.pauseStartedAt
    )
  }

  func setActive(_ active: ActiveSession) throws {
    let pausedMs = Int((active.pausedTotal * 1000).rounded())
    if let row = try context.fetch(FetchDescriptor<ActiveSessionRow>()).first {
      row.pursuitId = active.pursuitId
      row.startedAt = active.startedAt
      row.pausedTotalMs = pausedMs
      row.pauseStartedAt = active.pauseStartedAt
    } else {
      context.insert(ActiveSessionRow(
        pursuitId: active.pursuitId,
        startedAt: active.startedAt,
        pausedTotalMs: pausedMs,
        pauseStartedAt: active.pauseStartedAt
      ))
    }
    try context.save()
  }

  func clearActive() throws {
    for row in try context.fetch(FetchDescriptor<ActiveSessionRow>()) {
      context.delete(row)
    }
    try context.save()
  }

  func insertCompleted(
    pursuitId: Int,
    startedAt: Date,
    endedAt: Date,
    duration: TimeInterval
  ) throws -> Session {
    let row = SessionRow(
      pursuitId: pursuitId,
      startedAt: startedAt,
      endedAt: endedAt,
      durationMs: Int((duration * 1000).rounded())
    )
    context.insert(row)
    try context.save()
    return Session(
      pursuitId: pursuitId,
      startedAt: startedAt,
      endedAt: endedAt,
      duration: duration
    )
  }
}
