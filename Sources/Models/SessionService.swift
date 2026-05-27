import Foundation

// Lifecycle for the running timer: start / pause / resume / stop.
// Ported from sessions/domain/session_service.dart.
struct SessionService {
  let repo: SessionRepository
  var clock: Clock = SystemClock()

  func start(pursuitId: Int) throws -> ActiveSession {
    if try repo.getActive() != nil { throw SessionError.alreadyRunning }
    let active = ActiveSession(pursuitId: pursuitId, startedAt: clock.now())
    try repo.setActive(active)
    return active
  }

  func pause() throws -> ActiveSession {
    guard var active = try repo.getActive() else { throw SessionError.noActiveSession }
    if active.isPaused { return active }
    active.pauseStartedAt = clock.now()
    try repo.setActive(active)
    return active
  }

  func resume() throws -> ActiveSession {
    guard var active = try repo.getActive() else { throw SessionError.noActiveSession }
    guard active.isPaused, let pauseStart = active.pauseStartedAt else { return active }
    active.pausedTotal += clock.now().timeIntervalSince(pauseStart)
    active.pauseStartedAt = nil
    try repo.setActive(active)
    return active
  }

  /// `endAt` lets a caller record the session as ending at a specific moment
  /// rather than now — used by goal completion to bank only up to the target
  /// crossing instead of a background overshoot. Must not be after now.
  func stop(endAt: Date? = nil) throws -> StopResult {
    guard let active = try repo.getActive() else { throw SessionError.noActiveSession }
    let endedAt = endAt ?? clock.now()
    let duration = active.elapsed(at: endedAt)
    let session = try repo.insertCompleted(
      pursuitId: active.pursuitId,
      startedAt: active.startedAt,
      endedAt: endedAt,
      duration: duration
    )
    try repo.clearActive()
    return StopResult(
      session: session,
      countedTowardStats: duration >= AppConstants.sessionMinCountedDuration
    )
  }

  func currentElapsed(_ active: ActiveSession) -> TimeInterval {
    active.elapsed(at: clock.now())
  }
}
