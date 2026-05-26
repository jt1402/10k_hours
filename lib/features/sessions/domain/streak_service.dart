import 'package:ten_k_hours/features/sessions/domain/session.dart';
import 'package:ten_k_hours/features/sessions/domain/streaks.dart';

class StreakService {
  const StreakService();

  // Compute per-pursuit streaks from counted sessions.
  //
  // - currentDays: consecutive day-run anchored at *today* if today has a
  //   session, otherwise anchored at *yesterday* (giving the user the full
  //   day to keep the streak alive). 0 if neither today nor yesterday has
  //   a session.
  // - longestDays: longest consecutive day-run anywhere in history.
  //
  // Session start times are domain-layer UTC; we project them to local
  // calendar dates using `nowLocal`'s timezone offset.
  Streaks compute({
    required Iterable<Session> countedSessions,
    required DateTime nowLocal,
  }) {
    final days = countedSessions
        .map((s) => _localDateOf(s.startedAt, nowLocal.timeZoneOffset))
        .toSet();
    if (days.isEmpty) return Streaks.empty;

    final today = _dateOnly(nowLocal);
    final yesterday = today.subtract(const Duration(days: 1));

    var current = 0;
    if (days.contains(today)) {
      current = _countBackFrom(today, days);
    } else if (days.contains(yesterday)) {
      current = _countBackFrom(yesterday, days);
    }

    return Streaks(currentDays: current, longestDays: _longestRun(days));
  }

  DateTime _localDateOf(DateTime instant, Duration offset) {
    final shifted = instant.toUtc().add(offset);
    return DateTime.utc(shifted.year, shifted.month, shifted.day);
  }

  DateTime _dateOnly(DateTime local) =>
      DateTime.utc(local.year, local.month, local.day);

  int _countBackFrom(DateTime anchor, Set<DateTime> days) {
    var count = 0;
    var d = anchor;
    while (days.contains(d)) {
      count++;
      d = d.subtract(const Duration(days: 1));
    }
    return count;
  }

  int _longestRun(Set<DateTime> days) {
    final sorted = days.toList()..sort();
    var best = 1;
    var run = 1;
    for (var i = 1; i < sorted.length; i++) {
      final delta = sorted[i].difference(sorted[i - 1]).inDays;
      if (delta == 1) {
        run++;
        if (run > best) best = run;
      } else {
        run = 1;
      }
    }
    return best;
  }
}
