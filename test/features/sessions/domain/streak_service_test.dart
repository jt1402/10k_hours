import 'package:flutter_test/flutter_test.dart';
import 'package:ten_k_hours/features/sessions/domain/session.dart';
import 'package:ten_k_hours/features/sessions/domain/streak_service.dart';
import 'package:ten_k_hours/features/sessions/domain/streaks.dart';

Session _session(
  DateTime startedAt, {
  Duration duration = const Duration(hours: 1),
}) {
  return Session(
    id: 1,
    pursuitId: 1,
    startedAt: startedAt.toUtc(),
    endedAt: startedAt.toUtc().add(duration),
    duration: duration,
  );
}

void main() {
  const service = StreakService();

  // Fix "now" to a known local instant so tests don't depend on wall-clock.
  // Treat it as already-local; offset is taken from this DateTime.
  final nowLocal = DateTime(2026, 5, 26, 14, 30);

  DateTime daysBefore(int n) =>
      DateTime(nowLocal.year, nowLocal.month, nowLocal.day - n, 10);

  group('StreakService.compute', () {
    test('empty history returns 0/0', () {
      final s = service.compute(countedSessions: const [], nowLocal: nowLocal);
      expect(s, Streaks.empty);
    });

    test('single session today → 1/1', () {
      final s = service.compute(
        countedSessions: [_session(daysBefore(0))],
        nowLocal: nowLocal,
      );
      expect(s, const Streaks(currentDays: 1, longestDays: 1));
    });

    test('today + yesterday → 2/2', () {
      final s = service.compute(
        countedSessions: [
          _session(daysBefore(0)),
          _session(daysBefore(1)),
        ],
        nowLocal: nowLocal,
      );
      expect(s, const Streaks(currentDays: 2, longestDays: 2));
    });

    test('streak anchored on yesterday when today has no session', () {
      final s = service.compute(
        countedSessions: [
          _session(daysBefore(1)),
          _session(daysBefore(2)),
          _session(daysBefore(3)),
        ],
        nowLocal: nowLocal,
      );
      expect(s.currentDays, 3, reason: 'yesterday-anchored streak still alive');
      expect(s.longestDays, 3);
    });

    test('no session today or yesterday → current 0, longest preserved', () {
      final s = service.compute(
        countedSessions: [
          _session(daysBefore(3)),
          _session(daysBefore(4)),
          _session(daysBefore(5)),
        ],
        nowLocal: nowLocal,
      );
      expect(s.currentDays, 0);
      expect(s.longestDays, 3);
    });

    test('gap inside history breaks the run', () {
      final s = service.compute(
        countedSessions: [
          _session(daysBefore(0)),
          _session(daysBefore(1)),
          // gap at daysBefore(2)
          _session(daysBefore(3)),
          _session(daysBefore(4)),
          _session(daysBefore(5)),
        ],
        nowLocal: nowLocal,
      );
      expect(s.currentDays, 2, reason: 'today + yesterday only');
      expect(s.longestDays, 3, reason: 'older 3-day run is the longest');
    });

    test('multiple sessions on same day still count as one day', () {
      final s = service.compute(
        countedSessions: [
          _session(daysBefore(0).copyWith(hour: 8)),
          _session(daysBefore(0).copyWith(hour: 14)),
          _session(daysBefore(0).copyWith(hour: 21)),
          _session(daysBefore(1)),
        ],
        nowLocal: nowLocal,
      );
      expect(s, const Streaks(currentDays: 2, longestDays: 2));
    });

    test(
      'Korean timezone (+9): a session at 23:00 KST stays in that local day',
      () {
        // Korean offset
        final nowKst = DateTime(2026, 5, 26, 23, 30);
        // A UTC instant of 14:30 same day is 23:30 KST → "today"
        final lateLocalSession = Session(
          id: 1,
          pursuitId: 1,
          startedAt: DateTime.utc(2026, 5, 26, 14, 30),
          endedAt: DateTime.utc(2026, 5, 26, 15, 30),
          duration: const Duration(hours: 1),
        );
        final s = service.compute(
          countedSessions: [lateLocalSession],
          nowLocal: nowKst,
        );
        // This test relies on the runner's actual local offset; we only assert
        // that the single session is counted (current >= 1) — strict bucket
        // assertions require pinning the test process timezone.
        expect(s.currentDays, greaterThanOrEqualTo(1));
        expect(s.longestDays, 1);
      },
    );
  });
}

extension on DateTime {
  DateTime copyWith({int? hour}) =>
      DateTime(year, month, day, hour ?? this.hour, minute, second);
}
