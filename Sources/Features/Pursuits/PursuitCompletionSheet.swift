import SwiftData
import SwiftUI

// "You did it." celebration + stats grid. Ported from the Flutter completion
// sheet. Not dismissible by swipe (matches the Flutter isDismissible: false).
struct PursuitCompletionSheet: View {
  let pursuit: Pursuit

  @Environment(\.modelContext) private var context
  @Environment(\.dismiss) private var dismiss

  private var accent: Color { Color(argb: pursuit.accentColor) }

  private struct Stats {
    var total: TimeInterval; var sessions: Int; var days: Int
    var longestStreak: Int; var avg: TimeInterval
  }

  private var stats: Stats {
    let total = SessionStats.totalCounted(pursuitId: pursuit.id, context: context)
    let count = SessionStats.totalCount(pursuitId: pursuit.id, context: context)
    let completed = pursuit.completedAt ?? Date()
    let days = Calendar.current.dateComponents([.day], from: pursuit.createdAt, to: completed).day.map { $0 + 1 } ?? 1
    let avg = count > 0 ? total / Double(count) : 0
    let longest = StreakService().compute(
      countedSessions: SessionStats.countedSessions(pursuitId: pursuit.id, context: context),
      now: Date()
    ).longestDays
    return Stats(total: total, sessions: count, days: max(1, days), longestStreak: longest, avg: avg)
  }

  var body: some View {
    let s = stats
    VStack(spacing: 0) {
      ZStack {
        Circle().fill(accent.opacity(0.15)).frame(width: 96, height: 96)
        Image(systemName: "party.popper.fill").font(.system(size: 44)).foregroundStyle(accent)
      }
      .padding(.top, 32)

      Text("You did it.").font(.system(size: 28, weight: .bold)).padding(.top, 20)
      Text("You reached your \(Format.targetText(seconds: pursuit.goalSeconds)) goal on \(pursuit.name).")
        .font(.system(size: 16)).foregroundStyle(.secondary)
        .multilineTextAlignment(.center).padding(.top, 8).padding(.horizontal, 24)

      grid(s).padding(.top, 28).padding(.horizontal, 24)

      Spacer(minLength: 24)
      Button { dismiss() } label: { Text("Done").frame(maxWidth: .infinity).padding(.vertical, 6) }
        .buttonStyle(.borderedProminent)
        .padding(.horizontal, 24).padding(.bottom, 24)
    }
    .interactiveDismissDisabled()
  }

  private func grid(_ s: Stats) -> some View {
    let cells: [(String, String)] = [
      ("TOTAL TIME", Format.compact(s.total)),
      ("SESSIONS", "\(s.sessions)"),
      ("DAYS", "\(s.days)"),
      ("LONGEST STREAK", "\(s.longestStreak)d"),
      ("AVG SESSION", Format.compact(s.avg)),
    ]
    return LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
      ForEach(cells, id: \.0) { cell in
        VStack(alignment: .leading, spacing: 4) {
          Text(cell.0).font(.system(size: 11, weight: .medium)).tracking(0.6).foregroundStyle(.secondary)
          Text(cell.1).font(.system(size: 16, weight: .bold)).monospacedDigit()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 12).fill(accent.opacity(0.08)))
      }
    }
  }
}
