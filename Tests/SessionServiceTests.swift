import Foundation
import Testing

@testable import TenKHours

private let t0 = Date(timeIntervalSinceReferenceDate: 0)
private func mins(_ m: Double) -> TimeInterval { m * 60 }

private func makeService() -> (FakeSessionRepository, FakeClock, SessionService) {
  let repo = FakeSessionRepository()
  let clock = FakeClock(t0)
  return (repo, clock, SessionService(repo: repo, clock: clock))
}

@Suite("SessionService.start")
struct SessionServiceStartTests {
  @Test("creates an active session for the pursuit")
  func createsActive() throws {
    let (repo, _, service) = makeService()
    let active = try service.start(pursuitId: 7)
    #expect(active.pursuitId == 7)
    #expect(active.startedAt == t0)
    #expect(active.isPaused == false)
    #expect(try repo.getActive() != nil)
  }

  @Test("throws if a session is already running")
  func throwsWhenRunning() throws {
    let (_, _, service) = makeService()
    _ = try service.start(pursuitId: 7)
    #expect(throws: SessionError.alreadyRunning) {
      try service.start(pursuitId: 8)
    }
  }
}

@Suite("SessionService.pause / resume")
struct SessionServicePauseResumeTests {
  @Test("pause records pauseStartedAt at clock time")
  func pauseRecordsTime() throws {
    let (_, clock, service) = makeService()
    _ = try service.start(pursuitId: 1)
    clock.advance(mins(5))
    let paused = try service.pause()
    #expect(paused.isPaused == true)
    #expect(paused.pauseStartedAt == t0.addingTimeInterval(mins(5)))
  }

  @Test("resume accumulates pausedTotal and clears pauseStartedAt")
  func resumeAccumulates() throws {
    let (_, clock, service) = makeService()
    _ = try service.start(pursuitId: 1)
    clock.advance(mins(5))
    _ = try service.pause()
    clock.advance(mins(3))
    let resumed = try service.resume()
    #expect(resumed.isPaused == false)
    #expect(resumed.pausedTotal == mins(3))
  }

  @Test("pause is a no-op when already paused")
  func pauseNoOpWhenPaused() throws {
    let (_, clock, service) = makeService()
    _ = try service.start(pursuitId: 1)
    clock.advance(mins(1))
    let firstPause = try service.pause()
    clock.advance(mins(2))
    let secondPause = try service.pause()
    #expect(secondPause.pauseStartedAt == firstPause.pauseStartedAt)
  }

  @Test("throws if no active session")
  func throwsWithoutActive() {
    let (_, _, service) = makeService()
    #expect(throws: SessionError.noActiveSession) { try service.pause() }
    #expect(throws: SessionError.noActiveSession) { try service.resume() }
  }
}

@Suite("SessionService.stop")
struct SessionServiceStopTests {
  @Test("persists a completed session and clears active")
  func persistsAndClears() throws {
    let (repo, clock, service) = makeService()
    _ = try service.start(pursuitId: 7)
    clock.advance(mins(30))
    let result = try service.stop()
    #expect(result.session.duration == mins(30))
    #expect(result.session.pursuitId == 7)
    #expect(result.countedTowardStats == true)
    #expect(try repo.getActive() == nil)
    #expect(repo.inserted.count == 1)
  }

  @Test("records duration net of pauses")
  func netOfPauses() throws {
    let (_, clock, service) = makeService()
    _ = try service.start(pursuitId: 1)
    clock.advance(mins(10))
    _ = try service.pause()
    clock.advance(mins(5))
    _ = try service.resume()
    clock.advance(mins(7))
    let result = try service.stop()
    #expect(result.session.duration == mins(17))
  }

  @Test("countedTowardStats is false when under 60s")
  func notCountedUnder60() throws {
    let (repo, clock, service) = makeService()
    _ = try service.start(pursuitId: 1)
    clock.advance(30)
    let result = try service.stop()
    #expect(result.session.duration == 30)
    #expect(result.countedTowardStats == false)
    #expect(repo.inserted.count == 1)  // raw row still persisted for honest history
  }

  @Test("countedTowardStats is true at exactly 60s")
  func countedAt60() throws {
    let (_, clock, service) = makeService()
    _ = try service.start(pursuitId: 1)
    clock.advance(60)
    let result = try service.stop()
    #expect(result.countedTowardStats == true)
  }

  @Test("throws if no active session")
  func throwsWithoutActive() {
    let (_, _, service) = makeService()
    #expect(throws: SessionError.noActiveSession) { try service.stop() }
  }

  @Test("stopping while paused freezes duration at pause point")
  func freezesWhilePaused() throws {
    let (_, clock, service) = makeService()
    _ = try service.start(pursuitId: 1)
    clock.advance(mins(8))
    _ = try service.pause()
    clock.advance(mins(30))
    let result = try service.stop()
    #expect(result.session.duration == mins(8))
  }
}
