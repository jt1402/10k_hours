import 'package:flutter_test/flutter_test.dart';
import 'package:ten_k_hours/core/time/clock.dart';
import 'package:ten_k_hours/features/sessions/domain/session_service.dart';

import '../../../support/fake_session_repository.dart';

void main() {
  late FakeSessionRepository repo;
  late FakeClock clock;
  late SessionService service;

  final t0 = DateTime.utc(2026, 1, 1, 12);

  setUp(() {
    repo = FakeSessionRepository();
    clock = FakeClock(t0);
    service = SessionService(repo: repo, clock: clock);
  });

  group('start', () {
    test('creates an active session for the pursuit', () async {
      final active = await service.start(7);
      expect(active.pursuitId, 7);
      expect(active.startedAt, t0);
      expect(active.isPaused, isFalse);
      expect(await repo.getActive(), isNotNull);
    });

    test('throws if a session is already running', () async {
      await service.start(7);
      expect(service.start(8), throwsA(isA<SessionAlreadyRunningError>()));
    });
  });

  group('pause / resume', () {
    test('pause records pauseStartedAt at clock time', () async {
      await service.start(1);
      clock.advance(const Duration(minutes: 5));
      final paused = await service.pause();
      expect(paused.isPaused, isTrue);
      expect(paused.pauseStartedAt, t0.add(const Duration(minutes: 5)));
    });

    test('resume accumulates pausedTotal and clears pauseStartedAt', () async {
      await service.start(1);
      clock.advance(const Duration(minutes: 5));
      await service.pause();
      clock.advance(const Duration(minutes: 3));
      final resumed = await service.resume();
      expect(resumed.isPaused, isFalse);
      expect(resumed.pausedTotal, const Duration(minutes: 3));
    });

    test('pause is a no-op when already paused', () async {
      await service.start(1);
      clock.advance(const Duration(minutes: 1));
      final firstPause = await service.pause();
      clock.advance(const Duration(minutes: 2));
      final secondPause = await service.pause();
      expect(secondPause.pauseStartedAt, firstPause.pauseStartedAt);
    });

    test('throws if no active session', () async {
      expect(service.pause(), throwsA(isA<NoActiveSessionError>()));
      expect(service.resume(), throwsA(isA<NoActiveSessionError>()));
    });
  });

  group('stop', () {
    test('persists a completed session and clears active', () async {
      await service.start(7);
      clock.advance(const Duration(minutes: 30));
      final result = await service.stop();
      expect(result.session.duration, const Duration(minutes: 30));
      expect(result.session.pursuitId, 7);
      expect(result.countedTowardStats, isTrue);
      expect(await repo.getActive(), isNull);
      expect(repo.inserted, hasLength(1));
    });

    test('records duration net of pauses', () async {
      await service.start(1);
      clock.advance(const Duration(minutes: 10));
      await service.pause();
      clock.advance(const Duration(minutes: 5));
      await service.resume();
      clock.advance(const Duration(minutes: 7));
      final result = await service.stop();
      expect(result.session.duration, const Duration(minutes: 17));
    });

    test('countedTowardStats is false when under 60s', () async {
      await service.start(1);
      clock.advance(const Duration(seconds: 30));
      final result = await service.stop();
      expect(result.session.duration, const Duration(seconds: 30));
      expect(result.countedTowardStats, isFalse);
      expect(
        repo.inserted,
        hasLength(1),
        reason: 'raw row still persisted for honest history',
      );
    });

    test('countedTowardStats is true at exactly 60s', () async {
      await service.start(1);
      clock.advance(const Duration(seconds: 60));
      final result = await service.stop();
      expect(result.countedTowardStats, isTrue);
    });

    test('throws if no active session', () async {
      expect(service.stop(), throwsA(isA<NoActiveSessionError>()));
    });

    test('stopping while paused freezes duration at pause point', () async {
      await service.start(1);
      clock.advance(const Duration(minutes: 8));
      await service.pause();
      clock.advance(const Duration(minutes: 30));
      final result = await service.stop();
      expect(result.session.duration, const Duration(minutes: 8));
    });
  });
}
