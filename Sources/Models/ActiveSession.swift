import Foundation

// The single running/paused timer (pure domain value). Elapsed is *always*
// wall-clock timestamp math — never a tick counter — so it survives
// backgrounding, kill, DST, and reboot with no special handling.
// Ported from sessions/domain/active_session.dart.
struct ActiveSession: Equatable {
  var pursuitId: Int
  var startedAt: Date
  /// Total accumulated pause time from completed pause intervals, in seconds.
  var pausedTotal: TimeInterval = 0
  /// Set while a pause is in progress; nil when running.
  var pauseStartedAt: Date?

  var isPaused: Bool { pauseStartedAt != nil }

  /// elapsed = now - startedAt - pausedTotal - (now - pauseStartedAt if paused),
  /// clamped to ≥ 0 for clock-skew defensiveness.
  func elapsed(at now: Date) -> TimeInterval {
    let activePauseSoFar = pauseStartedAt.map { now.timeIntervalSince($0) } ?? 0
    let raw = now.timeIntervalSince(startedAt) - pausedTotal - activePauseSoFar
    return max(0, raw)
  }

  /// The instant this session should be recorded as ending so cumulative covered
  /// time lands exactly on `target`, never banking a background overshoot.
  /// `priorCounted` is the counted duration from *other* completed sessions for
  /// the pursuit. Returns nil when no clamp applies — paused, the target was
  /// already met before this session, or the crossing isn't yet in the past at
  /// `now` (caller should just use `now` then).
  func completionEndAt(priorCounted: TimeInterval, target: TimeInterval, now: Date) -> Date? {
    if isPaused { return nil }
    let remaining = target - priorCounted
    if remaining <= 0 { return nil }
    let crossing = startedAt.addingTimeInterval(pausedTotal + remaining)
    return crossing < now ? crossing : nil
  }
}
