import 'dart:io';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ten_k_hours/core/constants.dart';
import 'package:ten_k_hours/core/db/app_database.dart';
import 'package:ten_k_hours/core/db/database_provider.dart';
import 'package:ten_k_hours/features/pursuits/data/pursuit_providers.dart';
import 'package:ten_k_hours/features/sessions/data/session_providers.dart';

// Container-level integration test that exercises the full session lifecycle
// across a simulated app restart. Disposing the ProviderContainer + creating a
// fresh one against the same on-disk Drift file is the test-friendly analogue
// of an OS-level process kill: every provider, every Drift connection, every
// in-memory cache gets thrown away. The UI flow itself is covered by manual
// verification on the iOS simulator (see Slice 1 checkpoint).
void main() {
  late Directory tempDir;
  late File dbFile;

  setUp(() async {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    tempDir = await Directory.systemTemp.createTemp('ten_k_lifecycle_');
    dbFile = File('${tempDir.path}/test.sqlite');
  });

  tearDown(() {
    if (dbFile.existsSync()) dbFile.deleteSync();
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  ProviderContainer makeContainer() => ProviderContainer(
    overrides: [
      appDatabaseProvider.overrideWith((ref) {
        final db = AppDatabase.fromExecutor(NativeDatabase(dbFile));
        ref.onDispose(db.close);
        return db;
      }),
    ],
  );

  test('active session persists across a ProviderContainer restart', () async {
    // ───── First "app run" ─────
    var container = makeContainer();
    final pursuit = await container
        .read(pursuitRepositoryProvider)
        .create(name: 'Guitar', accentColor: 0xFF14B8A6);

    final service = container.read(sessionServiceProvider);
    final firstActive = await service.start(pursuit.id);
    expect(firstActive.pursuitId, pursuit.id);

    // Sanity: a row exists in active_session
    final firstReadBack = await container
        .read(sessionRepositoryProvider)
        .getActive();
    expect(firstReadBack, isNotNull);
    expect(firstReadBack!.pursuitId, pursuit.id);

    // ───── Simulated app restart ─────
    container.dispose();
    container = makeContainer();

    final resumed = await container.read(sessionRepositoryProvider).getActive();
    expect(
      resumed,
      isNotNull,
      reason: 'active session must survive a full ProviderContainer dispose',
    );
    expect(resumed!.pursuitId, pursuit.id);
    // Drift stores DateTime as Unix epoch seconds, so sub-second precision is
    // truncated on the round-trip. Use a 1s tolerance window.
    expect(
      resumed.startedAt
          .difference(firstActive.startedAt.toUtc())
          .abs()
          .inMilliseconds,
      lessThan(1000),
      reason: 'startedAt should round-trip through SQLite within a second',
    );

    // ───── Continue the session: pause, resume, stop ─────
    final servicePostRestart = container.read(sessionServiceProvider);
    await servicePostRestart.pause();
    final paused = await container.read(sessionRepositoryProvider).getActive();
    expect(paused!.isPaused, isTrue);

    await servicePostRestart.resume();
    final resumedAfterPause = await container
        .read(sessionRepositoryProvider)
        .getActive();
    expect(resumedAfterPause!.isPaused, isFalse);
    expect(
      resumedAfterPause.pausedTotal,
      greaterThanOrEqualTo(Duration.zero),
    );

    final stopResult = await servicePostRestart.stop();
    expect(stopResult.session.pursuitId, pursuit.id);

    final cleared = await container.read(sessionRepositoryProvider).getActive();
    expect(
      cleared,
      isNull,
      reason: 'stopping the session must clear the active_session row',
    );

    container.dispose();
  });

  test(
    'sub-60s session is persisted but excluded from totalCountedDurationFor',
    () async {
      final container = makeContainer();
      addTearDown(container.dispose);

      final pursuit = await container
          .read(pursuitRepositoryProvider)
          .create(name: 'Sprint', accentColor: 0xFF14B8A6);

      final repo = container.read(sessionRepositoryProvider);
      final now = DateTime.now().toUtc();

      // Sub-threshold session
      await repo.insertCompleted(
        pursuitId: pursuit.id,
        startedAt: now,
        endedAt: now.add(const Duration(seconds: 30)),
        duration: const Duration(seconds: 30),
      );
      // Above-threshold session
      await repo.insertCompleted(
        pursuitId: pursuit.id,
        startedAt: now.add(const Duration(minutes: 5)),
        endedAt: now.add(const Duration(minutes: 10)),
        duration: const Duration(minutes: 5),
      );

      final all = await repo.watchAll(pursuit.id).first;
      expect(
        all,
        hasLength(2),
        reason: 'raw history retains every session, including misfires',
      );

      final total = await repo.totalCountedDurationFor(pursuit.id);
      expect(
        total,
        const Duration(minutes: 5),
        reason:
            'totalCountedDurationFor must filter sessions under '
            '${kSessionMinCountedDuration.inSeconds}s',
      );
    },
  );
}
