import Foundation
import Testing

@testable import TenKHours

@Suite("StreakService.compute")
struct StreakServiceTests {
  let service = StreakService()

  // Fixed calendar/timezone so day-bucketing is deterministic regardless of
  // the machine running the tests.
  let utc: Calendar = {
    var c = Calendar(identifier: .gregorian)
    c.timeZone = TimeZone(identifier: "UTC")!
    return c
  }()

  // 2026-05-26 14:30 UTC, treated as "now".
  var now: Date { date(2026, 5, 26, 14, 30) }

  private func date(_ y: Int, _ mo: Int, _ d: Int, _ h: Int = 0, _ mi: Int = 0, calendar: Calendar? = nil) -> Date {
    var comps = DateComponents()
    comps.year = y; comps.month = mo; comps.day = d; comps.hour = h; comps.minute = mi
    return (calendar ?? utc).date(from: comps)!
  }

  /// A session starting `n` days before "now" at 10:00 UTC.
  private func daysBefore(_ n: Int) -> Date { date(2026, 5, 26 - n, 10) }

  private func session(_ startedAt: Date, hours: Double = 1) -> Session {
    Session(
      pursuitId: 1,
      startedAt: startedAt,
      endedAt: startedAt.addingTimeInterval(hours * 3600),
      duration: hours * 3600
    )
  }

  @Test("empty history returns 0/0")
  func emptyHistory() {
    #expect(service.compute(countedSessions: [], now: now, calendar: utc) == .empty)
  }

  @Test("single session today → 1/1")
  func singleToday() {
    let s = service.compute(countedSessions: [session(daysBefore(0))], now: now, calendar: utc)
    #expect(s == Streaks(currentDays: 1, longestDays: 1))
  }

  @Test("today + yesterday → 2/2")
  func todayAndYesterday() {
    let s = service.compute(
      countedSessions: [session(daysBefore(0)), session(daysBefore(1))],
      now: now, calendar: utc
    )
    #expect(s == Streaks(currentDays: 2, longestDays: 2))
  }

  @Test("streak anchored on yesterday when today has no session")
  func yesterdayAnchored() {
    let s = service.compute(
      countedSessions: [session(daysBefore(1)), session(daysBefore(2)), session(daysBefore(3))],
      now: now, calendar: utc
    )
    #expect(s.currentDays == 3)  // yesterday-anchored streak still alive
    #expect(s.longestDays == 3)
  }

  @Test("no session today or yesterday → current 0, longest preserved")
  func staleStreak() {
    let s = service.compute(
      countedSessions: [session(daysBefore(3)), session(daysBefore(4)), session(daysBefore(5))],
      now: now, calendar: utc
    )
    #expect(s.currentDays == 0)
    #expect(s.longestDays == 3)
  }

  @Test("gap inside history breaks the run")
  func gapBreaksRun() {
    let s = service.compute(
      countedSessions: [
        session(daysBefore(0)), session(daysBefore(1)),
        // gap at daysBefore(2)
        session(daysBefore(3)), session(daysBefore(4)), session(daysBefore(5)),
      ],
      now: now, calendar: utc
    )
    #expect(s.currentDays == 2)  // today + yesterday only
    #expect(s.longestDays == 3)  // older 3-day run is the longest
  }

  @Test("multiple sessions on same day still count as one day")
  func sameDayCollapses() {
    let s = service.compute(
      countedSessions: [
        session(date(2026, 5, 26, 8)),
        session(date(2026, 5, 26, 14)),
        session(date(2026, 5, 26, 21)),
        session(daysBefore(1)),
      ],
      now: now, calendar: utc
    )
    #expect(s == Streaks(currentDays: 2, longestDays: 2))
  }

  @Test("Korean timezone (+9): a 23:00 KST session stays in that local day")
  func koreanTimezone() {
    var seoul = Calendar(identifier: .gregorian)
    seoul.timeZone = TimeZone(identifier: "Asia/Seoul")!
    // 23:00 / 23:30 Seoul on 2026-05-26 (= 14:00 / 14:30 UTC same day).
    let nowKst = date(2026, 5, 26, 23, 30, calendar: seoul)
    let lateSession = session(date(2026, 5, 26, 23, 0, calendar: seoul))
    let s = service.compute(countedSessions: [lateSession], now: nowKst, calendar: seoul)
    #expect(s == Streaks(currentDays: 1, longestDays: 1))
  }
}
