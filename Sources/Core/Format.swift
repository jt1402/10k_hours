import Foundation

// Duration formatting used across the timer, completion sheet, switcher, and
// heatmap. Ported from the various `_formatHms` / `_formatDuration` helpers in
// the Flutter screens. All take seconds.
enum Format {
  /// "H:MM:SS" — the stat row (Covered / Remaining). Hours grouped past 1000.
  static func hms(_ seconds: TimeInterval) -> String {
    let total = Int(seconds)
    let h = total / 3600, m = (total % 3600) / 60, s = total % 60
    let hs = h >= 1000 ? h.grouped() : "\(h)"
    return "\(hs):\(pad(m)):\(pad(s))"
  }

  /// "HH:MM:SS" — the live current-session readout (always 2-digit hours).
  static func clockHms(_ seconds: TimeInterval) -> String {
    let total = Int(seconds)
    return "\(pad(total / 3600)):\(pad((total % 3600) / 60)):\(pad(total % 60))"
  }

  /// "Hh Mm" / "Mm Ss" — compact, for the completion grid.
  static func compact(_ seconds: TimeInterval) -> String {
    let total = Int(seconds)
    if total >= 3600 { return "\(total / 3600)h \((total % 3600) / 60)m" }
    return "\(total / 60)m \(total % 60)s"
  }

  /// "Hh Mm" / "Mm" / "less than a minute" — for switcher delete + heatmap day.
  static func coarse(_ seconds: TimeInterval) -> String {
    let total = Int(seconds)
    let h = total / 3600, m = (total % 3600) / 60
    if h > 0 { return m > 0 ? "\(h)h \(m)m" : "\(h)h" }
    if m > 0 { return "\(m)m" }
    return "less than a minute"
  }

  /// "10,000-hour" / "30-minute" / "45-second" / "1h 30m" target description.
  static func targetText(seconds: Int) -> String {
    if seconds < 60 { return "\(seconds)-second" }
    if seconds % 3600 == 0 { return "\((seconds / 3600).grouped())-hour" }
    if seconds < 3600 && seconds % 60 == 0 { return "\(seconds / 60)-minute" }
    let h = seconds / 3600, m = (seconds % 3600) / 60, s = seconds % 60
    if h > 0 { return "\(h)h \(m)m" }
    return s == 0 ? "\(m)m" : "\(m)m \(s)s"
  }

  private static func pad(_ n: Int) -> String { String(format: "%02d", n) }
}
