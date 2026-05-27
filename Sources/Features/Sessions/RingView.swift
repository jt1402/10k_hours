import SwiftUI

// Giant countdown ring, Canvas-drawn. Ported from the Flutter RingPainter +
// RingWidget: a full backdrop circle, an accent arc sweeping from 12 o'clock
// for `progress`, and the remaining time centered inside.
struct RingView: View {
  /// Cumulative covered time, in seconds.
  let elapsed: TimeInterval
  /// Goal in seconds.
  let targetSeconds: Int
  let accent: Color
  var completed: Bool = false
  var size: CGFloat = 340

  private let strokeWidth: CGFloat = 20

  private var targetSecondsTI: TimeInterval { TimeInterval(targetSeconds) }
  private var progress: Double {
    guard targetSecondsTI > 0 else { return 0 }
    return min(max(elapsed / targetSecondsTI, 0), 1)
  }
  private var remaining: TimeInterval { max(0, targetSecondsTI - elapsed) }
  private var remainingHours: Int { Int(remaining) / 3600 }

  var body: some View {
    ZStack {
      Canvas { ctx, size in
        let inset = strokeWidth / 2
        let rect = CGRect(x: inset, y: inset, width: size.width - strokeWidth, height: size.height - strokeWidth)
        ctx.stroke(
          Path(ellipseIn: rect),
          with: .color(Color(.systemGray5)),
          style: StrokeStyle(lineWidth: strokeWidth)
        )
        if progress > 0 {
          let center = CGPoint(x: size.width / 2, y: size.height / 2)
          let radius = (min(size.width, size.height) - strokeWidth) / 2
          var arc = Path()
          arc.addArc(
            center: center,
            radius: radius,
            startAngle: .degrees(-90),
            endAngle: .degrees(-90 + 360 * progress),
            clockwise: false
          )
          ctx.stroke(arc, with: .color(accent), style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round))
        }
      }
      .frame(width: size, height: size)

      if completed {
        VStack(spacing: 8) {
          Image(systemName: "checkmark.circle.fill")
            .font(.system(size: 96))
            .foregroundStyle(accent)
          Text("Completed")
            .font(.system(size: 16, weight: .semibold))
            .foregroundStyle(accent)
        }
      } else {
        VStack(spacing: 4) {
          Text(formatRemaining())
            .font(AppFont.ringNumber(size: remainingHours >= 1000 ? 72 : 88))
            .monospacedDigit()
            .contentTransition(.identity)            // don't animate digit changes
            .transaction { $0.animation = nil }      // don't inherit nav/sheet animations
            .foregroundStyle(.primary)
          Text(remainingLabel())
            .font(.system(size: 12))
            .foregroundStyle(.secondary)
        }
      }
    }
    .frame(width: size, height: size)
  }

  private func formatRemaining() -> String {
    if targetSeconds < 3600 {
      let m = Int(remaining) / 60
      let s = Int(remaining) % 60
      return String(format: "%d:%02d", m, s)
    }
    let totalMinutes = Int(remaining) / 60
    let hours = totalMinutes / 60
    let minutes = totalMinutes % 60
    if hours >= 100 { return hours.grouped() }
    return String(format: "%d:%02d", hours, minutes)
  }

  private func remainingLabel() -> String {
    if targetSeconds < 3600 { return "minutes : seconds left" }
    return remainingHours >= 100 ? "hours left" : "hours : minutes left"
  }
}

extension Int {
  /// Thousands-grouped string, e.g. 10000 → "10,000".
  func grouped() -> String {
    let f = NumberFormatter()
    f.numberStyle = .decimal
    return f.string(from: NSNumber(value: self)) ?? "\(self)"
  }
}
