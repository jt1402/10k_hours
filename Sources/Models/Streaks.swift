import Foundation

// Per-pursuit streak result. Ported from sessions/domain/streaks.dart.
struct Streaks: Equatable {
  let currentDays: Int
  let longestDays: Int

  static let empty = Streaks(currentDays: 0, longestDays: 0)
}
