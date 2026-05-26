import 'package:ten_k_hours/features/sessions/domain/active_session.dart';
import 'package:ten_k_hours/features/sessions/domain/session.dart';

abstract class SessionRepository {
  Future<ActiveSession?> getActive();
  Stream<ActiveSession?> watchActive();

  Future<void> setActive(ActiveSession active);
  Future<void> clearActive();

  Future<Session> insertCompleted({
    required int pursuitId,
    required DateTime startedAt,
    required DateTime endedAt,
    required Duration duration,
  });

  Stream<List<Session>> watchAll(int pursuitId);
  Stream<List<Session>> watchForStats(int pursuitId);

  Future<Duration> totalCountedDurationFor(int pursuitId);

  Stream<Map<DateTime, Duration>> watchDailyTotals(int pursuitId);
}
