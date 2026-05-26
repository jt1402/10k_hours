import 'package:ten_k_hours/core/constants.dart';
import 'package:ten_k_hours/core/time/clock.dart';
import 'package:ten_k_hours/features/sessions/domain/active_session.dart';
import 'package:ten_k_hours/features/sessions/domain/session.dart';
import 'package:ten_k_hours/features/sessions/domain/session_repository.dart';

class SessionAlreadyRunningError implements Exception {
  const SessionAlreadyRunningError();
}

class NoActiveSessionError implements Exception {
  const NoActiveSessionError();
}

class StopResult {
  const StopResult({required this.session, required this.countedTowardStats});
  final Session session;
  final bool countedTowardStats;
}

class SessionService {
  SessionService({
    required this.repo,
    this.clock = const SystemClock(),
  });

  final SessionRepository repo;
  final Clock clock;

  Future<ActiveSession> start(int pursuitId) async {
    final existing = await repo.getActive();
    if (existing != null) throw const SessionAlreadyRunningError();
    final active = ActiveSession(pursuitId: pursuitId, startedAt: clock.now());
    await repo.setActive(active);
    return active;
  }

  Future<ActiveSession> pause() async {
    final active = await repo.getActive();
    if (active == null) throw const NoActiveSessionError();
    if (active.isPaused) return active;
    final paused = active.copyWith(pauseStartedAt: clock.now());
    await repo.setActive(paused);
    return paused;
  }

  Future<ActiveSession> resume() async {
    final active = await repo.getActive();
    if (active == null) throw const NoActiveSessionError();
    if (!active.isPaused) return active;
    final addedPause = clock.now().difference(active.pauseStartedAt!);
    final resumed = active.copyWith(
      pausedTotal: active.pausedTotal + addedPause,
      pauseStartedAt: null,
    );
    await repo.setActive(resumed);
    return resumed;
  }

  Future<StopResult> stop() async {
    final active = await repo.getActive();
    if (active == null) throw const NoActiveSessionError();
    final endedAt = clock.now();
    final duration = active.elapsedAt(endedAt);
    final session = await repo.insertCompleted(
      pursuitId: active.pursuitId,
      startedAt: active.startedAt,
      endedAt: endedAt,
      duration: duration,
    );
    await repo.clearActive();
    return StopResult(
      session: session,
      countedTowardStats: duration >= kSessionMinCountedDuration,
    );
  }

  Duration currentElapsed(ActiveSession active) =>
      active.elapsedAt(clock.now());
}
