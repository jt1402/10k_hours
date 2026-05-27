import SwiftUI
import WidgetKit

#if canImport(AlarmKit)
import AlarmKit

// The AlarmKit-owned Live Activity (iOS 26+). AlarmKit drives the content state
// (`AlarmPresentationState`) — the app does NOT push updates — and the OS
// transitions countdown → paused → alert automatically, so the Dynamic Island
// flips to the "alert/Finished" state live, even while the app is suspended.
//
// We only render: a countdown timer (counts down to fireDate), a paused label,
// and the finished/alert label. Tinted with the pursuit accent.
@available(iOS 26.0, *)
struct AlarmLiveActivity: Widget {
  var body: some WidgetConfiguration {
    ActivityConfiguration(for: AlarmAttributes<GoalMetadata>.self) { context in
      AlarmLockScreenView(state: context.state, attributes: context.attributes)
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    } dynamicIsland: { context in
      let accent = alarmAccent(context.attributes)
      let name = context.attributes.metadata?.pursuitName ?? ""
      return DynamicIsland {
        DynamicIslandExpandedRegion(.leading) {
          VStack(alignment: .leading, spacing: 2) {
            Text(name).font(.subheadline.weight(.semibold)).lineLimit(1)
            Text(alarmStatusText(context.state))
              .font(.caption2).foregroundStyle(.secondary)
          }
          .padding(.leading, 16)
          .frame(maxHeight: .infinity, alignment: .leading)
        }
        DynamicIslandExpandedRegion(.trailing) {
          alarmTrailing(context.state)
            .font(.system(size: 38, weight: .bold, design: .rounded))
            .monospacedDigit()
            .foregroundStyle(accent)
            .lineLimit(1)
            .minimumScaleFactor(0.4)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
        }
      } compactLeading: {
        Image(systemName: alarmIcon(context.state))
          .foregroundStyle(accent)
      } compactTrailing: {
        alarmTrailing(context.state)
          .font(.system(size: 14, weight: .semibold))
          .monospacedDigit()
          .foregroundStyle(accent)
          .frame(width: 52)
          .lineLimit(1)
      } minimal: {
        Image(systemName: alarmIcon(context.state)).foregroundStyle(accent)
      }
    }
  }
}

@available(iOS 26.0, *)
struct AlarmLockScreenView: View {
  let state: AlarmPresentationState
  let attributes: AlarmAttributes<GoalMetadata>

  var body: some View {
    let accent = alarmAccent(attributes)
    HStack(spacing: 10) {
      VStack(alignment: .leading, spacing: 2) {
        Text(attributes.metadata?.pursuitName ?? "")
          .font(.subheadline.weight(.semibold)).lineLimit(1)
        Text(alarmStatusText(state)).font(.caption2).foregroundStyle(.secondary)
      }
      Spacer(minLength: 8)
      alarmTrailing(state)
        .font(.system(size: 38, weight: .bold, design: .rounded))
        .monospacedDigit()
        .foregroundStyle(accent)
        .lineLimit(1)
        .minimumScaleFactor(0.4)
    }
  }
}

// MARK: - Mode helpers (AlarmPresentationState.mode: .countdown / .paused / .alerting)

@available(iOS 26.0, *)
@ViewBuilder
func alarmTrailing(_ state: AlarmPresentationState) -> some View {
  switch state.mode {
  case .countdown(let countdown):
    Text(timerInterval: Date.now...countdown.fireDate, countsDown: true)
      .multilineTextAlignment(.trailing)
  case .paused:
    Text("Paused")
  default:
    // .alerting (goal reached) and any future cases
    Text("Finished")
  }
}

@available(iOS 26.0, *)
func alarmStatusText(_ state: AlarmPresentationState) -> String {
  switch state.mode {
  case .countdown: return "Running"
  case .paused: return "Paused"
  default: return "Goal reached"
  }
}

@available(iOS 26.0, *)
func alarmIcon(_ state: AlarmPresentationState) -> String {
  switch state.mode {
  case .countdown: return "timer"
  case .paused: return "pause.fill"
  default: return "checkmark.circle.fill"
  }
}

@available(iOS 26.0, *)
func alarmAccent(_ attributes: AlarmAttributes<GoalMetadata>) -> Color {
  if let argb = attributes.metadata?.pursuitColorARGB {
    return colorFromARGB(argb)
  }
  return attributes.tintColor
}
#endif
