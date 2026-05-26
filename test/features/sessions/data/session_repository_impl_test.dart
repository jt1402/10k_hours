import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart' show SqliteException;
import 'package:ten_k_hours/core/db/app_database.dart';
import 'package:ten_k_hours/features/pursuits/data/pursuit_repository_impl.dart';
import 'package:ten_k_hours/features/sessions/data/session_repository_impl.dart';
import 'package:ten_k_hours/features/sessions/domain/active_session.dart';

void main() {
  late AppDatabase db;
  late DriftSessionRepository repo;
  late int pursuitId;

  setUp(() async {
    db = AppDatabase.memory();
    repo = DriftSessionRepository(db);
    final p = await DriftPursuitRepository(
      db,
    ).create(name: 'P', accentColor: 0xFF14B8A6);
    pursuitId = p.id;
  });

  tearDown(() async {
    await db.close();
  });

  group('active session', () {
    test('setActive then getActive returns the same active', () async {
      final now = DateTime.utc(2026, 5, 26, 9);
      await repo.setActive(
        ActiveSession(pursuitId: pursuitId, startedAt: now),
      );
      final active = await repo.getActive();
      expect(active, isNotNull);
      expect(active!.pursuitId, pursuitId);
      expect(active.startedAt, now);
      expect(active.pausedTotal, Duration.zero);
    });

    test('setActive twice replaces the row (singleton)', () async {
      final t0 = DateTime.utc(2026, 5, 26, 9);
      await repo.setActive(ActiveSession(pursuitId: pursuitId, startedAt: t0));
      await repo.setActive(
        ActiveSession(
          pursuitId: pursuitId,
          startedAt: t0.add(const Duration(minutes: 5)),
          pausedTotal: const Duration(seconds: 30),
        ),
      );
      final active = await repo.getActive();
      expect(active!.startedAt, t0.add(const Duration(minutes: 5)));
      expect(active.pausedTotal, const Duration(seconds: 30));
    });

    test('clearActive deletes the row', () async {
      await repo.setActive(
        ActiveSession(pursuitId: pursuitId, startedAt: DateTime.utc(2026)),
      );
      await repo.clearActive();
      expect(await repo.getActive(), isNull);
    });

    test('CHECK (id = 1) prevents a second active_session row', () async {
      await repo.setActive(
        ActiveSession(pursuitId: pursuitId, startedAt: DateTime.utc(2026)),
      );
      expect(
        () => db
            .into(db.activeSession)
            .insert(
              ActiveSessionCompanion.insert(
                id: const Value(2),
                pursuitId: pursuitId,
                startedAt: DateTime.utc(2026),
              ),
            ),
        throwsA(isA<SqliteException>()),
      );
    });
  });

  group('insertCompleted and queries', () {
    test('insertCompleted persists; watchAll emits it', () async {
      final t0 = DateTime.utc(2026, 5, 26, 9);
      final session = await repo.insertCompleted(
        pursuitId: pursuitId,
        startedAt: t0,
        endedAt: t0.add(const Duration(minutes: 25)),
        duration: const Duration(minutes: 25),
      );
      expect(session.id, isNotNull);
      final all = await repo.watchAll(pursuitId).first;
      expect(all, hasLength(1));
      expect(all.first.duration, const Duration(minutes: 25));
    });

    test('watchForStats excludes sessions under 60s', () async {
      final t0 = DateTime.utc(2026, 5, 26, 9);
      await repo.insertCompleted(
        pursuitId: pursuitId,
        startedAt: t0,
        endedAt: t0.add(const Duration(seconds: 30)),
        duration: const Duration(seconds: 30),
      );
      await repo.insertCompleted(
        pursuitId: pursuitId,
        startedAt: t0.add(const Duration(minutes: 5)),
        endedAt: t0.add(const Duration(minutes: 6)),
        duration: const Duration(minutes: 1),
      );
      final all = await repo.watchAll(pursuitId).first;
      final stats = await repo.watchForStats(pursuitId).first;
      expect(all, hasLength(2));
      expect(stats, hasLength(1));
      expect(stats.first.duration, const Duration(minutes: 1));
    });

    test('totalCountedDurationFor sums only counted sessions', () async {
      final t0 = DateTime.utc(2026, 5, 26, 9);
      await repo.insertCompleted(
        pursuitId: pursuitId,
        startedAt: t0,
        endedAt: t0.add(const Duration(seconds: 30)),
        duration: const Duration(seconds: 30),
      );
      await repo.insertCompleted(
        pursuitId: pursuitId,
        startedAt: t0.add(const Duration(minutes: 5)),
        endedAt: t0.add(const Duration(minutes: 7)),
        duration: const Duration(minutes: 2),
      );
      await repo.insertCompleted(
        pursuitId: pursuitId,
        startedAt: t0.add(const Duration(minutes: 10)),
        endedAt: t0.add(const Duration(minutes: 13)),
        duration: const Duration(minutes: 3),
      );
      final total = await repo.totalCountedDurationFor(pursuitId);
      expect(total, const Duration(minutes: 5));
    });

    test('totalCountedDurationFor returns zero with no sessions', () async {
      expect(await repo.totalCountedDurationFor(pursuitId), Duration.zero);
    });
  });
}
