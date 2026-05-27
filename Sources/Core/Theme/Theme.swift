import SwiftUI

// Accent + typography helpers. Mirrors the Flutter theme (Geist, tight tracking,
// tabular figures on numbers). Geist isn't bundled yet — `AppFont` centralises
// the font so swapping system → Geist later is a one-place change (see PROGRESS
// "Open decisions": add the Geist files + UIAppFonts, then update `base()`).
extension Color {
  /// Build a Color from a 32-bit ARGB int (the per-pursuit accent storage).
  init(argb: Int) {
    let a = Double((argb >> 24) & 0xFF) / 255.0
    let r = Double((argb >> 16) & 0xFF) / 255.0
    let g = Double((argb >> 8) & 0xFF) / 255.0
    let b = Double(argb & 0xFF) / 255.0
    self = Color(.sRGB, red: r, green: g, blue: b, opacity: a == 0 ? 1 : a)
  }

  /// The 32-bit ARGB int for this color (opaque), for persistence.
  func argb32() -> Int {
    #if canImport(UIKit)
    let ui = UIColor(self)
    var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
    ui.getRed(&r, green: &g, blue: &b, alpha: &a)
    let ri = Int((r * 255).rounded()), gi = Int((g * 255).rounded()), bi = Int((b * 255).rounded())
    return (0xFF << 24) | (ri << 16) | (gi << 8) | bi
    #else
    return AppConstants.defaultAccentColorARGB
    #endif
  }
}

enum AppFont {
  /// The big countdown number in the ring.
  static func ringNumber(size: CGFloat) -> Font {
    .system(size: size, weight: .semibold, design: .default)
  }

  static func statValue(size: CGFloat = 22) -> Font {
    .system(size: size, weight: .semibold)
  }
}

// The default accent palette offered in "Create pursuit". The Flutter build
// hard-coded teal; the data model already carries a per-pursuit accent, so we
// surface a small palette here (teal stays the default).
enum AccentPalette {
  static let colors: [Int] = [
    0xFF14_B8A6,  // teal (default)
    0xFF3B_82F6,  // blue
    0xFF8B_5CF6,  // violet
    0xFFEC_4899,  // pink
    0xFFF5_9E0B,  // amber
    0xFF22_C55E,  // green
    0xFFEF_4444,  // red
  ]
}
