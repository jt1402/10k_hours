import SwiftData
import SwiftUI

// Activity calendar: a paged monthly calendar with large, accent-tinted,
// finger-friendly day cells. Replaces the old 53×7 micro-grid (which was a nice
// glance but miserable to tap). Tap any past/today cell for that day's total.
struct HeatmapScreen: View {
  let pursuitId: Int

  @Environment(\.modelContext) private var context
  @Query private var pursuits: [Pursuit]
  @Query private var sessions: [SessionRow]

  @State private var monthAnchor = Calendar.current.startOfMonth(for: Date())
  @State private var dayDetail: DayDetail?

  init(pursuitId: Int) {
    self.pursuitId = pursuitId
    _pursuits = Query(filter: #Predicate<Pursuit> { $0.id == pursuitId })
    _sessions = Query(filter: #Predicate<SessionRow> { $0.pursuitId == pursuitId })
  }

  private let cal = Calendar.current
  private var pursuit: Pursuit? { pursuits.first }
  private var accent: Color { Color(argb: pursuit?.accentColor ?? AppConstants.defaultAccentColorARGB) }

  // Local-date → counted seconds.
  private var daily: [Date: TimeInterval] {
    var map: [Date: TimeInterval] = [:]
    for s in sessions where s.durationMs >= SessionStats.minCountedMs {
      map[cal.startOfDay(for: s.startedAt), default: 0] += s.durationSeconds
    }
    return map
  }

  var body: some View {
    Group {
      if let pursuit { content(pursuit) } else {
        ContentUnavailableView("Pursuit not found", systemImage: "questionmark.circle")
      }
    }
    .navigationTitle("Activity")
    .navigationBarTitleDisplayMode(.inline)
    .sheet(item: $dayDetail) { DayDetailSheet(detail: $0).presentationDetents([.height(180)]) }
  }

  @ViewBuilder
  private func content(_ pursuit: Pursuit) -> some View {
    let daily = self.daily
    ScrollView {
      VStack(alignment: .leading, spacing: 24) {
        VStack(alignment: .leading, spacing: 4) {
          Text(pursuit.name).font(.system(size: 22, weight: .semibold))
          Text("Tap a day to see details").font(.footnote).foregroundStyle(.secondary)
        }

        monthCard(daily: daily)
        legend
        footer(daily: daily)
      }
      .padding(.horizontal, 16)
      .padding(.vertical, 8)
    }
  }

  // MARK: month calendar

  private func monthCard(daily: [Date: TimeInterval]) -> some View {
    VStack(spacing: 14) {
      header
      weekdayRow
      grid(daily: daily)
    }
  }

  private var header: some View {
    HStack {
      navButton(systemName: "chevron.left") { shiftMonth(-1) }
        .disabled(!canGoBack)
      Spacer()
      Text(monthTitle).font(.system(size: 18, weight: .semibold))
      Spacer()
      navButton(systemName: "chevron.right") { shiftMonth(1) }
        .disabled(!canGoForward)
    }
  }

  private func navButton(systemName: String, _ action: @escaping () -> Void) -> some View {
    Button(action: action) {
      Image(systemName: systemName).font(.system(size: 16, weight: .semibold))
        .frame(width: 44, height: 44)
    }
    .tint(.primary)
  }

  private var weekdayRow: some View {
    HStack(spacing: 6) {
      ForEach(weekdaySymbols, id: \.self) { sym in
        Text(sym).font(.system(size: 12, weight: .medium)).foregroundStyle(.secondary)
          .frame(maxWidth: .infinity)
      }
    }
  }

  private func grid(daily: [Date: TimeInterval]) -> some View {
    let today = cal.startOfDay(for: Date())
    let cells = monthCells
    return LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: 7), spacing: 6) {
      ForEach(Array(cells.enumerated()), id: \.offset) { _, day in
        if let day {
          let seconds = daily[day] ?? 0
          dayCell(day: day, seconds: seconds, isToday: day == today, isFuture: day > today)
        } else {
          Color.clear.frame(height: 46)
        }
      }
    }
  }

  private func dayCell(day: Date, seconds: TimeInterval, isToday: Bool, isFuture: Bool) -> some View {
    let dayNum = cal.component(.day, from: day)
    let intense = Int(seconds) / 60 >= 120
    return Button {
      guard !isFuture else { return }
      dayDetail = DayDetail(day: day, seconds: seconds)
    } label: {
      Text("\(dayNum)")
        .font(.system(size: 16, weight: isToday ? .bold : .regular))
        .foregroundStyle(isFuture ? Color.secondary.opacity(0.4) : (intense ? .white : .primary))
        .frame(maxWidth: .infinity)
        .frame(height: 46)
        .background(
          RoundedRectangle(cornerRadius: 10)
            .fill(isFuture ? Color(.systemGray6).opacity(0.5) : color(for: seconds))
        )
        .overlay(
          RoundedRectangle(cornerRadius: 10)
            .strokeBorder(accent, lineWidth: isToday ? 2 : 0)
        )
    }
    .buttonStyle(.plain)
    .disabled(isFuture)
  }

  // MARK: legend + footer

  private var legend: some View {
    HStack(spacing: 4) {
      Text("Less").font(.footnote).foregroundStyle(.secondary)
      ForEach([Color(.systemGray6), accent.opacity(0.25), accent.opacity(0.5), accent.opacity(0.75), accent], id: \.self) { c in
        RoundedRectangle(cornerRadius: 4).fill(c).frame(width: 16, height: 16)
      }
      Text("More").font(.footnote).foregroundStyle(.secondary)
    }
  }

  private func footer(daily: [Date: TimeInterval]) -> some View {
    let total = daily.values.reduce(0, +)
    return HStack {
      footStat(String(format: "%.1f", total / 3600), "hours logged")
      Spacer()
      footStat("\(daily.count)", "days active")
      Spacer()
      footStat("\(longestRun(Set(daily.keys)))", "longest run")
    }
  }

  private func footStat(_ value: String, _ label: String) -> some View {
    VStack(alignment: .leading, spacing: 2) {
      Text(value).font(.system(size: 22, weight: .semibold))
      Text(label).font(.footnote).foregroundStyle(.secondary)
    }
  }

  // MARK: month math

  private var monthTitle: String {
    let f = DateFormatter()
    f.dateFormat = "LLLL yyyy"
    return f.string(from: monthAnchor)
  }

  /// Monday-first weekday symbols.
  private var weekdaySymbols: [String] { ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"] }

  /// Day Dates for the displayed month, with leading nils for blank cells
  /// (Monday-first), so a 7-column grid lays out like a real calendar.
  private var monthCells: [Date?] {
    guard let range = cal.range(of: .day, in: .month, for: monthAnchor) else { return [] }
    let weekday = cal.component(.weekday, from: monthAnchor)  // Sun=1…Sat=7
    let leading = (weekday + 5) % 7  // days since Monday
    var cells: [Date?] = Array(repeating: nil, count: leading)
    for d in range {
      cells.append(cal.date(byAdding: .day, value: d - 1, to: monthAnchor))
    }
    return cells
  }

  private var canGoBack: Bool {
    // Allow paging back to the pursuit's creation month.
    guard let created = pursuit.map({ cal.startOfMonth(for: $0.createdAt) }) else { return true }
    return monthAnchor > created
  }

  private var canGoForward: Bool {
    monthAnchor < cal.startOfMonth(for: Date())
  }

  private func shiftMonth(_ delta: Int) {
    if let next = cal.date(byAdding: .month, value: delta, to: monthAnchor) {
      withAnimation(.easeInOut(duration: 0.15)) { monthAnchor = next }
    }
  }

  private func color(for seconds: TimeInterval) -> Color {
    let minutes = Int(seconds) / 60
    if minutes == 0 { return Color(.systemGray6) }
    if minutes < 30 { return accent.opacity(0.25) }
    if minutes < 60 { return accent.opacity(0.5) }
    if minutes < 120 { return accent.opacity(0.75) }
    return accent
  }

  private func longestRun(_ days: Set<Date>) -> Int {
    guard !days.isEmpty else { return 0 }
    let sorted = days.sorted()
    var best = 1, run = 1
    for i in 1..<sorted.count {
      let delta = cal.dateComponents([.day], from: sorted[i - 1], to: sorted[i]).day ?? 0
      if delta == 1 { run += 1; best = max(best, run) } else { run = 1 }
    }
    return best
  }
}

extension Calendar {
  func startOfMonth(for date: Date) -> Date {
    self.date(from: dateComponents([.year, .month], from: date)) ?? startOfDay(for: date)
  }
}

struct DayDetail: Identifiable {
  let day: Date
  let seconds: TimeInterval
  var id: Date { day }
}

private struct DayDetailSheet: View {
  let detail: DayDetail

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text(detail.day.formatted(.dateTime.weekday(.wide).month(.wide).day().year()))
        .font(.system(size: 16, weight: .medium))
      Text(detail.seconds == 0 ? "No counted sessions on this day." : "\(Format.coarse(detail.seconds)) of focused work")
        .font(.system(size: 16)).foregroundStyle(.secondary)
      Spacer()
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(24)
  }
}
