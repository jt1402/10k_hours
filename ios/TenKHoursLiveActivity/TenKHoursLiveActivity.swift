import ActivityKit
import SwiftUI
import WidgetKit

@available(iOS 16.2, *)
struct TenKHoursLiveActivity: Widget {
  var body: some WidgetConfiguration {
    ActivityConfiguration(for: TenKHoursLiveActivityAttributes.self) { context in
      LockScreenView(context: context)
    } dynamicIsland: { context in
      let accent = colorFromARGB(context.attributes.pursuitColorARGB)
      return DynamicIsland {
        DynamicIslandExpandedRegion(.leading) {
          VStack(alignment: .leading, spacing: 2) {
            Text(context.attributes.pursuitName)
              .font(.subheadline.weight(.semibold))
              .lineLimit(1)
            Text(context.state.isPaused ? "Paused" : "Running")
              .font(.caption2)
              .foregroundStyle(.secondary)
          }
          .padding(.leading, 16)
          .frame(maxHeight: .infinity, alignment: .leading)
        }
        DynamicIslandExpandedRegion(.trailing) {
          timerLabel(state: context.state)
            .monospacedDigit()
            .font(.system(size: 38, weight: .bold, design: .rounded))
            .foregroundStyle(accent)
            .multilineTextAlignment(.trailing)
            .lineLimit(1)
            .minimumScaleFactor(0.4)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
        }
      } compactLeading: {
        Image(systemName: context.state.isPaused ? "pause.fill" : "timer")
          .font(.system(size: 16, weight: .semibold))
          .foregroundStyle(accent)
          .frame(width: 30)
      } compactTrailing: {
        Group {
          if context.state.isPaused {
            Text(formatCompactSeconds(context.state.pausedAtFreezeSeconds))
          } else {
            Text(
              timerInterval: context.state.effectiveStartedAt...context.state.effectiveStartedAt.addingTimeInterval(86400),
              countsDown: false,
              showsHours: false
            )
          }
        }
        .monospacedDigit()
        .font(.system(size: 14, weight: .semibold))
        .foregroundStyle(accent)
        .lineLimit(1)
        .frame(width: 50)
      } minimal: {
        Image(systemName: context.state.isPaused ? "pause.fill" : "timer")
          .foregroundStyle(accent)
          .frame(maxWidth: .infinity, alignment: .trailing)
      }
    }
  }

  @ViewBuilder
  private func timerLabel(
    state: TenKHoursLiveActivityAttributes.ContentState
  ) -> some View {
    if state.isPaused {
      Text(formatSeconds(state.pausedAtFreezeSeconds))
    } else {
      Text(
        timerInterval: state.effectiveStartedAt...state.effectiveStartedAt.addingTimeInterval(86400),
        countsDown: false,
        showsHours: true
      )
    }
  }
}

@available(iOS 16.2, *)
struct LockScreenView: View {
  let context: ActivityViewContext<TenKHoursLiveActivityAttributes>

  var body: some View {
    let accent = colorFromARGB(context.attributes.pursuitColorARGB)
    HStack(spacing: 10) {
      VStack(alignment: .leading, spacing: 2) {
        Text(context.attributes.pursuitName)
          .font(.subheadline.weight(.semibold))
          .lineLimit(1)
        Text(context.state.isPaused ? "Paused" : "Active session")
          .font(.caption2)
          .foregroundStyle(.secondary)
      }
      Spacer(minLength: 8)
      Group {
        if context.state.isPaused {
          Text(formatSeconds(context.state.pausedAtFreezeSeconds))
        } else {
          Text(context.state.effectiveStartedAt, style: .timer)
            .multilineTextAlignment(.trailing)
        }
      }
      .font(.system(size: 38, weight: .bold, design: .rounded))
      .monospacedDigit()
      .foregroundStyle(accent)
      .lineLimit(1)
      .minimumScaleFactor(0.4)
    }
    .padding(.horizontal, 16)
    .padding(.vertical, 14)
  }
}

func formatSeconds(_ s: Int) -> String {
  let h = s / 3600
  let m = (s % 3600) / 60
  let sec = s % 60
  return String(format: "%02d:%02d:%02d", h, m, sec)
}

func formatCompactSeconds(_ s: Int) -> String {
  let h = s / 3600
  let m = (s % 3600) / 60
  let sec = s % 60
  if h > 0 {
    return String(format: "%d:%02d:%02d", h, m, sec)
  }
  return String(format: "%02d:%02d", m, sec)
}

func colorFromARGB(_ argb: Int) -> Color {
  let a = Double((argb >> 24) & 0xFF) / 255.0
  let r = Double((argb >> 16) & 0xFF) / 255.0
  let g = Double((argb >> 8) & 0xFF) / 255.0
  let b = Double(argb & 0xFF) / 255.0
  return Color(.sRGB, red: r, green: g, blue: b, opacity: a)
}

// MARK: - Xcode previews
// Open this file in Xcode, hit Cmd+Option+Enter to show the canvas, then
// pick a preview from the bottom bar. Edits to view code re-render in ~1s
// with no simulator rebuild.

@available(iOS 17.0, *)
private let _previewAttrs = TenKHoursLiveActivityAttributes(
  pursuitName: "Programming",
  pursuitColorARGB: 0xFF4DD0E1
)

@available(iOS 17.0, *)
private func _previewState(elapsed: TimeInterval, paused: Bool = false) -> TenKHoursLiveActivityAttributes.ContentState {
  TenKHoursLiveActivityAttributes.ContentState(
    effectiveStartedAt: Date().addingTimeInterval(-elapsed),
    isPaused: paused,
    pausedAtFreezeSeconds: paused ? Int(elapsed) : 0
  )
}

@available(iOS 17.0, *)
#Preview("Compact", as: .dynamicIsland(.compact), using: _previewAttrs) {
  TenKHoursLiveActivity()
} contentStates: {
  _previewState(elapsed: 1218)   // 20:18
  _previewState(elapsed: 4530)   // 1:15:30
  _previewState(elapsed: 1218, paused: true)
}

@available(iOS 17.0, *)
#Preview("Expanded", as: .dynamicIsland(.expanded), using: _previewAttrs) {
  TenKHoursLiveActivity()
} contentStates: {
  _previewState(elapsed: 1218)
  _previewState(elapsed: 1218, paused: true)
}

@available(iOS 17.0, *)
#Preview("Minimal", as: .dynamicIsland(.minimal), using: _previewAttrs) {
  TenKHoursLiveActivity()
} contentStates: {
  _previewState(elapsed: 1218)
}

@available(iOS 17.0, *)
#Preview("Lock screen", as: .content, using: _previewAttrs) {
  TenKHoursLiveActivity()
} contentStates: {
  _previewState(elapsed: 1218)
  _previewState(elapsed: 4530)
  _previewState(elapsed: 1218, paused: true)
}
