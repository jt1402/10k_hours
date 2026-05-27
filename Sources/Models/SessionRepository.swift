import Foundation

enum SessionError: Error, Equatable {
  case alreadyRunning
  case noActiveSession
}

struct StopResult: Equatable {
  let session: Session
  let countedTowardStats: Bool
}

// The slice of persistence `SessionService` needs. Kept minimal so the service
// is unit-testable with an in-memory fake; SwiftData-backed reads for the UI
// (lists, stats, heatmap) go through @Query directly, not this protocol.
protocol SessionRepository {
  func getActive() throws -> ActiveSession?
  func setActive(_ active: ActiveSession) throws
  func clearActive() throws

  func insertCompleted(
    pursuitId: Int,
    startedAt: Date,
    endedAt: Date,
    duration: TimeInterval
  ) throws -> Session
}
