import ActivityKit
import SwiftUI
import WidgetKit

struct TenKHoursLiveActivity: Widget {
  var body: some WidgetConfiguration {
    ActivityConfiguration(for: TenKHoursActivityAttributes.self) { context in
      LockScreenView(context: context)
    } dynamicIsland: { context in
      let accent = colorFromARGB(context.attributes.pursuitColorARGB)
      let finished = context.isStale || context.state.isFinished
      return DynamicIsland {
        DynamicIslandExpandedRegion(.leading) {
          VStack(alignment: .leading, spacing: 2) {
            Text(context.attributes.pursuitName)
              .font(.subheadline.weight(.semibold))
              .lineLimit(1)
            Text(finished ? "Finished" : (context.state.isPaused ? "Paused" : "Running"))
              .font(.caption2)
              .foregroundStyle(.secondary)
          }
          .padding(.leading, 16)
          .frame(maxHeight: .infinity, alignment: .leading)
        }
        DynamicIslandExpandedRegion(.trailing) {
          timerLabel(state: context.state, finished: finished)
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
          if finished {
            Image(systemName: "checkmark.circle.fill")
          } else if context.state.isPaused {
            Text(formatCompactSeconds(context.state.pausedAtFreezeSeconds))
          } else if let text = context.state.displayText, !text.isEmpty {
            Text(text)
          } else {
            Text(
              timerInterval: context.state.effectiveStartedAt...timerUpperBound(context.state),
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
        Image(systemName: finished ? "checkmark.circle.fill" : (context.state.isPaused ? "pause.fill" : "timer"))
          .foregroundStyle(accent)
          .frame(maxWidth: .infinity, alignment: .trailing)
      }
    }
  }

  @ViewBuilder
  private func timerLabel(
    state: TenKHoursActivityAttributes.ContentState,
    finished: Bool
  ) -> some View {
    if finished {
      Text("Finished")
    } else if state.isPaused {
      Text(formatSeconds(state.pausedAtFreezeSeconds))
    } else if let text = state.displayText, !text.isEmpty {
      Text(text)
    } else {
      Text(
        timerInterval: state.effectiveStartedAt...timerUpperBound(state),
        countsDown: false,
        showsHours: true
      )
    }
  }
}

struct LockScreenView: View {
  let context: ActivityViewContext<TenKHoursActivityAttributes>

  var body: some View {
    let accent = colorFromARGB(context.attributes.pursuitColorARGB)
    let finished = context.isStale || context.state.isFinished
    HStack(spacing: 10) {
      VStack(alignment: .leading, spacing: 2) {
        Text(context.attributes.pursuitName)
          .font(.subheadline.weight(.semibold))
          .lineLimit(1)
        Text(finished ? "Goal reached" : (context.state.isPaused ? "Paused" : "Active session"))
          .font(.caption2)
          .foregroundStyle(.secondary)
      }
      Spacer(minLength: 8)
      Group {
        if finished {
          HStack(spacing: 6) {
            Image(systemName: "checkmark.circle.fill")
            Text("Finished")
          }
        } else if context.state.isPaused {
          Text(formatSeconds(context.state.pausedAtFreezeSeconds))
        } else if let text = context.state.displayText, !text.isEmpty {
          Text(text)
            .multilineTextAlignment(.trailing)
        } else {
          Text(
            timerInterval: context.state.effectiveStartedAt...timerUpperBound(context.state),
            countsDown: false,
            showsHours: true
          )
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

// Upper bound for the auto-ticking timer: freeze at the goal when a target is
// set, otherwise tick effectively forever.
func timerUpperBound(_ state: TenKHoursActivityAttributes.ContentState) -> Date {
  state.targetEndAt ?? state.effectiveStartedAt.addingTimeInterval(86400 * 365)
}

func formatSeconds(_ s: Int) -> String {
  let h = s / 3600
  let m = (s % 3600) / 60
  let sec = s % 60
  if h >= 1000 { return "\(h)h" }
  return String(format: "%02d:%02d:%02d", h, m, sec)
}

func formatCompactSeconds(_ s: Int) -> String {
  let h = s / 3600
  let m = (s % 3600) / 60
  let sec = s % 60
  if h >= 100 { return "\(h)h" }
  if h > 0 { return String(format: "%d:%02d", h, m) }
  return String(format: "%02d:%02d", m, sec)
}

func colorFromARGB(_ argb: Int) -> Color {
  let a = Double((argb >> 24) & 0xFF) / 255.0
  let r = Double((argb >> 16) & 0xFF) / 255.0
  let g = Double((argb >> 8) & 0xFF) / 255.0
  let b = Double(argb & 0xFF) / 255.0
  return Color(.sRGB, red: r, green: g, blue: b, opacity: a)
}
