import 'package:drift/drift.dart';
import 'package:ten_k_hours/core/constants.dart';
import 'package:ten_k_hours/core/db/app_database.dart';
import 'package:ten_k_hours/features/sessions/domain/active_session.dart';
import 'package:ten_k_hours/features/sessions/domain/session.dart';
import 'package:ten_k_hours/features/sessions/domain/session_repository.dart';

class DriftSessionRepository implements SessionRepository {
  DriftSessionRepository(this._db);

  final AppDatabase _db;

  static final int _minCountedMs = kSessionMinCountedDuration.inMilliseconds;

  @override
  Future<ActiveSession?> getActive() async {
    final row = await _db.select(_db.activeSession).getSingleOrNull();
    return row == null ? null : _activeToDomain(row);
  }

  @override
  Stream<ActiveSession?> watchActive() {
    return _db
        .select(_db.activeSession)
        .watchSingleOrNull()
        .map((row) => row == null ? null : _activeToDomain(row));
  }

  @override
  Future<void> setActive(ActiveSession active) async {
    await _db.transaction(() async {
      await _db.delete(_db.activeSession).go();
      await _db
          .into(_db.activeSession)
          .insert(
            ActiveSessionCompanion.insert(
              pursuitId: active.pursuitId,
              startedAt: active.startedAt,
              pausedTotalMs: Value(active.pausedTotal.inMilliseconds),
              pauseStartedAt: Value(active.pauseStartedAt),
            ),
          );
    });
  }

  @override
  Future<void> clearActive() async {
    await _db.delete(_db.activeSession).go();
  }

  @override
  Future<Session> insertCompleted({
    required int pursuitId,
    required DateTime startedAt,
    required DateTime endedAt,
    required Duration duration,
  }) async {
    final row = await _db
        .into(_db.sessions)
        .insertReturning(
          SessionsCompanion.insert(
            pursuitId: pursuitId,
            startedAt: startedAt,
            endedAt: endedAt,
            durationMs: duration.inMilliseconds,
          ),
        );
    return _sessionToDomain(row);
  }

  @override
  Stream<List<Session>> watchAll(int pursuitId) {
    final query = _db.select(_db.sessions)
      ..where((t) => t.pursuitId.equals(pursuitId))
      ..orderBy([(t) => OrderingTerm.desc(t.startedAt)]);
    return query.watch().map((rows) => rows.map(_sessionToDomain).toList());
  }

  @override
  Stream<List<Session>> watchForStats(int pursuitId) {
    final query = _db.select(_db.sessions)
      ..where(
        (t) =>
            t.pursuitId.equals(pursuitId) &
            t.durationMs.isBiggerOrEqualValue(_minCountedMs),
      )
      ..orderBy([(t) => OrderingTerm.desc(t.startedAt)]);
    return query.watch().map((rows) => rows.map(_sessionToDomain).toList());
  }

  @override
  Future<Duration> totalCountedDurationFor(int pursuitId) async {
    final sum = _db.sessions.durationMs.sum();
    final query = _db.selectOnly(_db.sessions)
      ..addColumns([sum])
      ..where(
        _db.sessions.pursuitId.equals(pursuitId) &
            _db.sessions.durationMs.isBiggerOrEqualValue(_minCountedMs),
      );
    final row = await query.getSingle();
    final total = row.read(sum) ?? 0;
    return Duration(milliseconds: total);
  }

  @override
  Stream<Map<DateTime, Duration>> watchDailyTotals(int pursuitId) {
    return _db
        .customSelect(
          "SELECT date(started_at, 'unixepoch', 'localtime') AS day, "
          'SUM(duration_ms) AS total_ms FROM sessions '
          'WHERE pursuit_id = ? AND duration_ms >= ? '
          'GROUP BY day',
          variables: [
            Variable.withInt(pursuitId),
            Variable.withInt(_minCountedMs),
          ],
          readsFrom: {_db.sessions},
        )
        .watch()
        .map((rows) {
          final map = <DateTime, Duration>{};
          for (final row in rows) {
            final dayStr = row.read<String>('day');
            final totalMs = row.read<int>('total_ms');
            final parts = dayStr.split('-');
            final date = DateTime(
              int.parse(parts[0]),
              int.parse(parts[1]),
              int.parse(parts[2]),
            );
            map[date] = Duration(milliseconds: totalMs);
          }
          return map;
        });
  }

  ActiveSession _activeToDomain(ActiveSessionRow row) => ActiveSession(
    pursuitId: row.pursuitId,
    startedAt: row.startedAt.toUtc(),
    pausedTotal: Duration(milliseconds: row.pausedTotalMs),
    pauseStartedAt: row.pauseStartedAt?.toUtc(),
  );

  Session _sessionToDomain(SessionRow row) => Session(
    id: row.id,
    pursuitId: row.pursuitId,
    startedAt: row.startedAt.toUtc(),
    endedAt: row.endedAt.toUtc(),
    duration: Duration(milliseconds: row.durationMs),
  );
}
