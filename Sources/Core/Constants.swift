import Foundation

// App-wide domain constants. Ported from the Flutter build's core/constants.dart.
enum AppConstants {
  /// Default pursuit target: 10,000 hours, stored as minutes (supports sub-hour targets).
  static let defaultTargetMinutes = 600_000

  /// Sessions shorter than this are persisted for honest history but excluded
  /// from stats / streaks / totals at read time.
  static let sessionMinCountedDuration: TimeInterval = 60

  /// Teal. Stored as a 32-bit ARGB int so it round-trips through the Live
  /// Activity attributes unchanged.
  static let defaultAccentColorARGB = 0xFF14_B8A6

  /// Dual-mode threshold: when the time remaining to the goal is at or under
  /// this, the AlarmKit-owned countdown Live Activity is used (so the Dynamic
  /// Island flips to "Finished" live, even suspended). Larger remaining keeps
  /// the custom count-up Live Activity. Conservative vs. AlarmKit's max
  /// countdown duration; if a schedule is rejected we fall back to custom.
  static let alarmKitCountdownMaxSeconds: TimeInterval = 12 * 3600
}
