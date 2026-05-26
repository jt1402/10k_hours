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
              .font(.headline)
              .lineLimit(1)
            Text(context.state.isPaused ? "Paused" : "Running")
              .font(.caption)
              .foregroundStyle(.secondary)
          }
          .padding(.leading, 4)
        }
        DynamicIslandExpandedRegion(.trailing) {
          timerLabel(state: context.state)
            .monospacedDigit()
            .font(.system(size: 28, weight: .semibold, design: .rounded))
            .foregroundStyle(accent)
            .padding(.trailing, 4)
        }
        DynamicIslandExpandedRegion(.bottom) {
          Text("Tap to open · long-press in app to stop")
            .font(.caption2)
            .foregroundStyle(.tertiary)
        }
      } compactLeading: {
        Image(systemName: "timer")
          .foregroundStyle(accent)
      } compactTrailing: {
        timerLabel(state: context.state)
          .monospacedDigit()
          .font(.system(size: 13, weight: .medium))
          .foregroundStyle(accent)
      } minimal: {
        Image(systemName: "timer")
          .foregroundStyle(accent)
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
      Text(state.effectiveStartedAt, style: .timer)
    }
  }
}

@available(iOS 16.2, *)
struct LockScreenView: View {
  let context: ActivityViewContext<TenKHoursLiveActivityAttributes>

  var body: some View {
    let accent = colorFromARGB(context.attributes.pursuitColorARGB)
    HStack(spacing: 16) {
      VStack(alignment: .leading, spacing: 4) {
        Text(context.attributes.pursuitName)
          .font(.headline)
          .lineLimit(1)
        Text(context.state.isPaused ? "Paused" : "Active session")
          .font(.caption)
          .foregroundStyle(.secondary)
      }
      Spacer()
      Group {
        if context.state.isPaused {
          Text(formatSeconds(context.state.pausedAtFreezeSeconds))
        } else {
          Text(context.state.effectiveStartedAt, style: .timer)
        }
      }
      .font(.system(size: 32, weight: .semibold, design: .rounded))
      .monospacedDigit()
      .foregroundStyle(accent)
    }
    .padding()
  }
}

func formatSeconds(_ s: Int) -> String {
  let h = s / 3600
  let m = (s % 3600) / 60
  let sec = s % 60
  return String(format: "%02d:%02d:%02d", h, m, sec)
}

func colorFromARGB(_ argb: Int) -> Color {
  let a = Double((argb >> 24) & 0xFF) / 255.0
  let r = Double((argb >> 16) & 0xFF) / 255.0
  let g = Double((argb >> 8) & 0xFF) / 255.0
  let b = Double(argb & 0xFF) / 255.0
  return Color(.sRGB, red: r, green: g, blue: b, opacity: a)
}
