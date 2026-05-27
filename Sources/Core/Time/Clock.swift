import Foundation

// Injectable clock so domain logic is testable with a frozen / advanceable now.
// SystemClock in prod, FakeClock in tests. Ported from core/time/clock.dart.
protocol Clock {
  func now() -> Date
}

struct SystemClock: Clock {
  func now() -> Date { Date() }
}

final class FakeClock: Clock {
  private var current: Date

  init(_ now: Date) { current = now }

  func now() -> Date { current }

  func advance(_ delta: TimeInterval) { current = current.addingTimeInterval(delta) }

  func setTo(_ instant: Date) { current = instant }
}
