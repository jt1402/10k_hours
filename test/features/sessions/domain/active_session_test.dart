import 'package:flutter_test/flutter_test.dart';
import 'package:ten_k_hours/features/sessions/domain/active_session.dart';

void main() {
  group('ActiveSession.elapsedAt', () {
    final t0 = DateTime.utc(2026, 1, 1, 12);

    test('returns zero immediately at start', () {
      final s = ActiveSession(pursuitId: 1, startedAt: t0);
      expect(s.elapsedAt(t0), Duration.zero);
    });

    test('grows with wall-clock time when running', () {
      final s = ActiveSession(pursuitId: 1, startedAt: t0);
      expect(
        s.elapsedAt(t0.add(const Duration(minutes: 10))),
        const Duration(minutes: 10),
      );
    });

    test('subtracts pausedTotal once accumulated', () {
      final s = ActiveSession(
        pursuitId: 1,
        startedAt: t0,
        pausedTotal: const Duration(minutes: 3),
      );
      expect(
        s.elapsedAt(t0.add(const Duration(minutes: 10))),
        const Duration(minutes: 7),
      );
    });

    test('subtracts active pause-in-progress on top of pausedTotal', () {
      final s = ActiveSession(
        pursuitId: 1,
        startedAt: t0,
        pausedTotal: const Duration(minutes: 2),
        pauseStartedAt: t0.add(const Duration(minutes: 5)),
      );
      // started at 0, paused-total 2 already, then paused at 5, asked at 10.
      // elapsed = 10 - 2 (prior pause) - 5 (active pause) = 3 minutes.
      expect(
        s.elapsedAt(t0.add(const Duration(minutes: 10))),
        const Duration(minutes: 3),
      );
    });

    test('clamps to zero if math goes negative (clock skew defensiveness)', () {
      final s = ActiveSession(
        pursuitId: 1,
        startedAt: t0,
        pausedTotal: const Duration(hours: 100),
      );
      expect(s.elapsedAt(t0.add(const Duration(minutes: 1))), Duration.zero);
    });

    test('is unaffected by DST/timezone — diffs are absolute', () {
      // 2am spring-forward day; wall-clock jump is irrelevant because
      // DateTime.difference operates on absolute instants.
      final start = DateTime.utc(2026, 3, 8, 1, 30);
      final end = DateTime.utc(2026, 3, 8, 4, 30);
      final s = ActiveSession(pursuitId: 1, startedAt: start);
      expect(s.elapsedAt(end), const Duration(hours: 3));
    });

    test('isPaused reflects pauseStartedAt presence', () {
      final running = ActiveSession(pursuitId: 1, startedAt: t0);
      expect(running.isPaused, isFalse);
      final paused = running.copyWith(pauseStartedAt: t0);
      expect(paused.isPaused, isTrue);
    });
  });

  group('ActiveSession.completionEndAt', () {
    final t0 = DateTime.utc(2026, 1, 1, 12);
    const oneMin = Duration(minutes: 1);

    test('backgrounded overshoot clamps to the crossing, not now', () {
      // The reported bug: 1-minute goal, app reopened at 4m35s. Only the
      // first minute should be banked.
      final s = ActiveSession(pursuitId: 1, startedAt: t0);
      final now = t0.add(const Duration(minutes: 4, seconds: 35));
      final endAt = s.completionEndAt(
        priorCounted: Duration.zero,
        target: oneMin,
        now: now,
      );
      expect(endAt, t0.add(oneMin));
      // The recorded session duration (what stop() banks) is exactly target.
      expect(s.elapsedAt(endAt!), oneMin);
    });

    test('accounts for counted time from prior sessions', () {
      // 10-min goal, 7 already banked → this session only owes 3 more.
      final s = ActiveSession(pursuitId: 1, startedAt: t0);
      final now = t0.add(const Duration(minutes: 30));
      final endAt = s.completionEndAt(
        priorCounted: const Duration(minutes: 7),
        target: const Duration(minutes: 10),
        now: now,
      );
      expect(s.elapsedAt(endAt!), const Duration(minutes: 3));
    });

    test('shifts the crossing later by accumulated pause time', () {
      final s = ActiveSession(
        pursuitId: 1,
        startedAt: t0,
        pausedTotal: const Duration(minutes: 2),
      );
      final now = t0.add(const Duration(minutes: 10));
      final endAt = s.completionEndAt(
        priorCounted: Duration.zero,
        target: oneMin,
        now: now,
      );
      // Crossing wall-clock is start + pausedTotal + remaining; banked
      // duration is still exactly the target.
      expect(endAt, t0.add(const Duration(minutes: 3)));
      expect(s.elapsedAt(endAt!), oneMin);
    });

    test('returns null while paused (caller falls back to now)', () {
      final s = ActiveSession(
        pursuitId: 1,
        startedAt: t0,
        pauseStartedAt: t0.add(const Duration(seconds: 30)),
      );
      expect(
        s.completionEndAt(
          priorCounted: Duration.zero,
          target: oneMin,
          now: t0.add(const Duration(minutes: 5)),
        ),
        isNull,
      );
    });

    test('returns null when target already met by prior sessions', () {
      final s = ActiveSession(pursuitId: 1, startedAt: t0);
      expect(
        s.completionEndAt(
          priorCounted: const Duration(minutes: 2),
          target: oneMin,
          now: t0.add(const Duration(minutes: 5)),
        ),
        isNull,
      );
    });

    test('returns null when the crossing is not yet in the past', () {
      // Foreground tick detecting just before the boundary — no clamp needed.
      final s = ActiveSession(pursuitId: 1, startedAt: t0);
      expect(
        s.completionEndAt(
          priorCounted: Duration.zero,
          target: oneMin,
          now: t0.add(const Duration(seconds: 59)),
        ),
        isNull,
      );
    });
  });
}
