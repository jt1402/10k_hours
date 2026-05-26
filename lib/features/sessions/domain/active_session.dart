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
}
