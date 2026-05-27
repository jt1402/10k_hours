import Foundation

// Pure streak computation from counted sessions. Per-pursuit.
// Ported from sessions/domain/streak_service.dart.
//
// - currentDays: consecutive day-run anchored at *today* if today has a session,
//   otherwise at *yesterday* (giving the user the full day to keep it alive).
//   0 if neither today nor yesterday has a session.
// - longestDays: longest consecutive day-run anywhere in history.
//
// Sessions are bucketed by local calendar date using `calendar` (its timeZone).
struct StreakService {
  func compute(
    countedSessions: [Session],
    now: Date,
    calendar: Calendar = .current
  ) -> Streaks {
    let days = Set(countedSessions.map { calendar.startOfDay(for: $0.startedAt) })
    guard !days.isEmpty else { return .empty }

    let today = calendar.startOfDay(for: now)
    let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!

    var current = 0
    if days.contains(today) {
      current = countBack(from: today, in: days, calendar: calendar)
    } else if days.contains(yesterday) {
      current = countBack(from: yesterday, in: days, calendar: calendar)
    }

    return Streaks(currentDays: current, longestDays: longestRun(days, calendar: calendar))
  }

  private func countBack(from anchor: Date, in days: Set<Date>, calendar: Calendar) -> Int {
    var count = 0
    var d = anchor
    while days.contains(d) {
      count += 1
      d = calendar.date(byAdding: .day, value: -1, to: d)!
    }
    return count
  }

  private func longestRun(_ days: Set<Date>, calendar: Calendar) -> Int {
    let sorted = days.sorted()
    var best = 1
    var run = 1
    for i in 1..<sorted.count {
      let delta = calendar.dateComponents([.day], from: sorted[i - 1], to: sorted[i]).day ?? 0
      if delta == 1 {
        run += 1
        best = max(best, run)
      } else {
        run = 1
      }
    }
    return best
  }
}
