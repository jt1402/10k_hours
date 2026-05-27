import Foundation
import Testing

@testable import TenKHours

private let t0 = Date(timeIntervalSinceReferenceDate: 0)
private func mins(_ m: Double) -> TimeInterval { m * 60 }

@Suite("ActiveSession.elapsed")
struct ActiveSessionElapsedTests {
  @Test("returns zero immediately at start")
  func zeroAtStart() {
    let s = ActiveSession(pursuitId: 1, startedAt: t0)
    #expect(s.elapsed(at: t0) == 0)
  }

  @Test("grows with wall-clock time when running")
  func growsWhileRunning() {
    let s = ActiveSession(pursuitId: 1, startedAt: t0)
    #expect(s.elapsed(at: t0.addingTimeInterval(mins(10))) == mins(10))
  }

  @Test("subtracts pausedTotal once accumulated")
  func subtractsPausedTotal() {
    let s = ActiveSession(pursuitId: 1, startedAt: t0, pausedTotal: mins(3))
    #expect(s.elapsed(at: t0.addingTimeInterval(mins(10))) == mins(7))
  }

  @Test("subtracts active pause-in-progress on top of pausedTotal")
  func subtractsActivePause() {
    // started at 0, paused-total 2 already, then paused at 5, asked at 10.
    // elapsed = 10 - 2 (prior pause) - 5 (active pause) = 3 minutes.
    let s = ActiveSession(
      pursuitId: 1,
      startedAt: t0,
      pausedTotal: mins(2),
      pauseStartedAt: t0.addingTimeInterval(mins(5))
    )
    #expect(s.elapsed(at: t0.addingTimeInterval(mins(10))) == mins(3))
  }

  @Test("clamps to zero if math goes negative (clock skew defensiveness)")
  func clampsNegative() {
    let s = ActiveSession(pursuitId: 1, startedAt: t0, pausedTotal: 100 * 3600)
    #expect(s.elapsed(at: t0.addingTimeInterval(mins(1))) == 0)
  }

  @Test("is unaffected by DST/timezone — diffs are absolute")
  func dstUnaffected() {
    let s = ActiveSession(pursuitId: 1, startedAt: t0)
    #expect(s.elapsed(at: t0.addingTimeInterval(3 * 3600)) == 3 * 3600)
  }

  @Test("isPaused reflects pauseStartedAt presence")
  func isPausedReflectsState() {
    var s = ActiveSession(pursuitId: 1, startedAt: t0)
    #expect(s.isPaused == false)
    s.pauseStartedAt = t0
    #expect(s.isPaused == true)
  }
}

@Suite("ActiveSession.completionEndAt")
struct ActiveSessionCompletionTests {
  @Test("backgrounded overshoot clamps to the crossing, not now")
  func overshootClamps() {
    // 1-minute goal, app reopened at 4m35s. Only the first minute is banked.
    let s = ActiveSession(pursuitId: 1, startedAt: t0)
    let now = t0.addingTimeInterval(mins(4) + 35)
    let endAt = s.completionEndAt(priorCounted: 0, target: mins(1), now: now)
    #expect(endAt == t0.addingTimeInterval(mins(1)))
    #expect(s.elapsed(at: endAt!) == mins(1))
  }

  @Test("accounts for counted time from prior sessions")
  func accountsForPrior() {
    // 10-min goal, 7 already banked → this session only owes 3 more.
    let s = ActiveSession(pursuitId: 1, startedAt: t0)
    let now = t0.addingTimeInterval(mins(30))
    let endAt = s.completionEndAt(priorCounted: mins(7), target: mins(10), now: now)
    #expect(s.elapsed(at: endAt!) == mins(3))
  }

  @Test("shifts the crossing later by accumulated pause time")
  func shiftsByPause() {
    let s = ActiveSession(pursuitId: 1, startedAt: t0, pausedTotal: mins(2))
    let now = t0.addingTimeInterval(mins(10))
    let endAt = s.completionEndAt(priorCounted: 0, target: mins(1), now: now)
    #expect(endAt == t0.addingTimeInterval(mins(3)))
    #expect(s.elapsed(at: endAt!) == mins(1))
  }

  @Test("returns nil while paused (caller falls back to now)")
  func nilWhilePaused() {
    let s = ActiveSession(
      pursuitId: 1,
      startedAt: t0,
      pauseStartedAt: t0.addingTimeInterval(30)
    )
    #expect(s.completionEndAt(priorCounted: 0, target: mins(1), now: t0.addingTimeInterval(mins(5))) == nil)
  }

  @Test("returns nil when target already met by prior sessions")
  func nilWhenAlreadyMet() {
    let s = ActiveSession(pursuitId: 1, startedAt: t0)
    #expect(s.completionEndAt(priorCounted: mins(2), target: mins(1), now: t0.addingTimeInterval(mins(5))) == nil)
  }

  @Test("returns nil when the crossing is not yet in the past")
  func nilWhenNotYetCrossed() {
    // Foreground tick just before the boundary — no clamp needed.
    let s = ActiveSession(pursuitId: 1, startedAt: t0)
    #expect(s.completionEndAt(priorCounted: 0, target: mins(1), now: t0.addingTimeInterval(59)) == nil)
  }
}
