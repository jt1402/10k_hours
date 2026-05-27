import 'package:freezed_annotation/freezed_annotation.dart';

part 'active_session.freezed.dart';

@freezed
abstract class ActiveSession with _$ActiveSession {
  const factory ActiveSession({
    required int pursuitId,
    required DateTime startedAt,
    @Default(Duration.zero) Duration pausedTotal,
    DateTime? pauseStartedAt,
  }) = _ActiveSession;

  const ActiveSession._();

  bool get isPaused => pauseStartedAt != null;

  Duration elapsedAt(DateTime now) {
    final activePauseSoFar = pauseStartedAt == null
        ? Duration.zero
        : now.difference(pauseStartedAt!);
    final raw = now.difference(startedAt) - pausedTotal - activePauseSoFar;
    return raw.isNegative ? Duration.zero : raw;
  }

  // The instant this session should be recorded as ending so cumulative
  // covered time lands exactly on [target], never banking a background
  // overshoot. [priorCounted] is the counted duration from *other* completed
  // sessions for the pursuit. Returns null when no clamp applies — paused, the
  // target was already met before this session, or the crossing isn't in the
  // past at [now] (caller should just use [now] then).
  DateTime? completionEndAt({
    required Duration priorCounted,
    required Duration target,
    required DateTime now,
  }) {
    if (isPaused) return null;
    final remaining = target - priorCounted;
    if (remaining <= Duration.zero) return null;
    final crossing = startedAt.add(pausedTotal).add(remaining);
    return crossing.isBefore(now) ? crossing : null;
  }
}
