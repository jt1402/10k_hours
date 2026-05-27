import Foundation
@testable import TenKHours

// In-memory SessionRepository for unit tests. Mirrors the Flutter
// FakeSessionRepository: holds one active session and an append-only log of
// inserted completed sessions.
final class FakeSessionRepository: SessionRepository {
  private(set) var active: ActiveSession?
  private(set) var inserted: [Session] = []
  private var nextId = 1

  func getActive() throws -> ActiveSession? { active }

  func setActive(_ active: ActiveSession) throws { self.active = active }

  func clearActive() throws { active = nil }

  func insertCompleted(
    pursuitId: Int,
    startedAt: Date,
    endedAt: Date,
    duration: TimeInterval
  ) throws -> Session {
    let session = Session(
      id: nextId,
      pursuitId: pursuitId,
      startedAt: startedAt,
      endedAt: endedAt,
      duration: duration
    )
    nextId += 1
    inserted.append(session)
    return session
  }
}
