import SwiftData
import SwiftUI

// The timer screen: countdown ring, stat row, streak strip, status line, and a
// top bar with a tappable pursuit-name pill (→ switcher) + calendar (→ heatmap).
// Ported from the Flutter TimerScreen. Tap = start/pause/resume, long-press = stop.
struct TimerScreen: View {
  let pursuitId: Int
  var onSelectPursuit: (Int) -> Void
  var onCreatePursuit: () -> Void

  @Environment(\.modelContext) private var context
  @Environment(\.scenePhase) private var scenePhase

  @Query private var pursuits: [Pursuit]
  @Query private var sessions: [SessionRow]
  @Query private var activeRows: [ActiveSessionRow]

  @State private var engine: SessionEngine?
  @State private var showSwitcher = false
  @State private var showCompletion = false
  @State private var toast: String?

  init(pursuitId: Int, onSelectPursuit: @escaping (Int) -> Void, onCreatePursuit: @escaping () -> Void) {
    self.pursuitId = pursuitId
    self.onSelectPursuit = onSelectPursuit
    self.onCreatePursuit = onCreatePursuit
    _pursuits = Query(filter: #Predicate<Pursuit> { $0.id == pursuitId })
    _sessions = Query(filter: #Predicate<SessionRow> { $0.pursuitId == pursuitId })
    _activeRows = Query()
  }

  private var pursuit: Pursuit? { pursuits.first }
  private var now: Date { engine?.now ?? Date() }

  private var activeForThis: ActiveSession? {
    guard let row = activeRows.first, row.pursuitId == pursuitId else { return nil }
    return ActiveSession(
      pursuitId: row.pursuitId,
      startedAt: row.startedAt,
      pausedTotal: Double(row.pausedTotalMs) / 1000,
      pauseStartedAt: row.pauseStartedAt
    )
  }

  private var countedSessions: [Session] {
    sessions
      .filter { $0.durationMs >= SessionStats.minCountedMs }
      .map { Session(pursuitId: $0.pursuitId, startedAt: $0.startedAt, endedAt: $0.endedAt, duration: $0.durationSeconds) }
  }
  private var totalCounted: TimeInterval { countedSessions.reduce(0) { $0 + $1.duration } }
  private var currentElapsed: TimeInterval { activeForThis?.elapsed(at: now) ?? 0 }
  private var displayElapsed: TimeInterval { totalCounted + currentElapsed }
  private var streaks: Streaks { StreakService().compute(countedSessions: countedSessions, now: now) }

  var body: some View {
    Group {
      if let pursuit {
        content(pursuit)
      } else {
        ContentUnavailableView("Pursuit not found", systemImage: "questionmark.circle")
      }
    }
    .navigationTitle("")
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItem(placement: .principal) {
        if let pursuit {
          Button { showSwitcher = true } label: {
            HStack(spacing: 4) {
              Text(pursuit.name).font(.system(size: 17, weight: .semibold)).lineLimit(1)
              Image(systemName: "chevron.down").font(.system(size: 12, weight: .semibold)).foregroundStyle(.secondary)
            }
          }
          .tint(.primary)
        }
      }
      ToolbarItem(placement: .topBarTrailing) {
        NavigationLink(value: Route.heatmap(pursuitId: pursuitId)) {
          Image(systemName: "calendar")
        }
      }
    }
    .onAppear {
      if engine == nil { engine = SessionEngine(pursuitId: pursuitId, context: context) }
      // Always refresh (also when returning from the heatmap/sheets): restarts
      // the ticker and re-stamps `now` so the ring doesn't freeze or jump.
      engine?.onAppear()
    }
    .onDisappear { engine?.onDisappear() }
    .onChange(of: scenePhase) { _, phase in if phase == .active { engine?.onScenePhaseActive() } }
    .onChange(of: engine?.pendingCompletionPursuitId) { _, v in if v != nil { showCompletion = true } }
    .onChange(of: showCompletion) { _, shown in if !shown { Task { await engine?.acknowledgeCompletion() } } }
    .sheet(isPresented: $showSwitcher) {
      PursuitSwitcherSheet(
        currentPursuitId: pursuitId,
        onSelect: { showSwitcher = false; onSelectPursuit($0) },
        onCreate: { showSwitcher = false; onCreatePursuit() }
      )
    }
    .sheet(isPresented: $showCompletion) {
      if let pursuit { PursuitCompletionSheet(pursuit: pursuit) }
    }
  }

  @ViewBuilder
  private func content(_ pursuit: Pursuit) -> some View {
    let accent = Color(argb: pursuit.accentColor)
    let isCompleted = pursuit.completedAt != nil

    VStack(spacing: 0) {
      Spacer(minLength: 0)
      VStack(spacing: 36) {
        RingView(elapsed: displayElapsed, targetSeconds: pursuit.goalSeconds, accent: accent, completed: isCompleted)
          .contentShape(Circle())
          .onTapGesture { if !isCompleted { Task { await engine?.primaryTap() } } }
          .onLongPressGesture(minimumDuration: 0.4) { if !isCompleted { Task { await stop() } } }
        statRow(covered: displayElapsed, targetSeconds: pursuit.goalSeconds)
          .padding(.horizontal, 24)
      }
      Spacer(minLength: 0)
      footer(pursuit: pursuit, accent: accent, isCompleted: isCompleted)
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
    }
    .overlay(alignment: .bottom) { toastView }
  }

  @ViewBuilder
  private func footer(pursuit: Pursuit, accent: Color, isCompleted: Bool) -> some View {
    let status = isCompleted
      ? "Goal reached — this pursuit is complete"
      : activeForThis == nil ? "tap to start"
      : activeForThis!.isPaused ? "paused — tap to resume, hold to stop"
      : "running — tap to pause, hold to stop"

    VStack(spacing: 12) {
      if isCompleted {
        Button { showCompletion = true } label: {
          Label("Results", systemImage: "trophy.fill")
            .font(.system(size: 15, weight: .semibold))
            .padding(.horizontal, 20).padding(.vertical, 12)
        }
        .buttonStyle(.borderedProminent)
        .tint(accent)
      } else if streaks.currentDays > 0 || streaks.longestDays > 0 {
        streakStrip(accent: accent)
      }

      // Always render the live readout (invisible when idle) so the footer
      // height stays constant — starting a session no longer shifts the ring.
      Text(activeForThis != nil ? Format.clockHms(currentElapsed) : " ")
        .font(.system(size: 20, weight: .medium))
        .monospacedDigit()
        .opacity(activeForThis != nil ? 1 : 0)
      Text(status).font(.system(size: 14)).foregroundStyle(.secondary)
    }
  }

  private func streakStrip(accent: Color) -> some View {
    HStack(spacing: 6) {
      Image(systemName: "flame.fill")
        .font(.system(size: 16))
        .foregroundStyle(streaks.currentDays > 0 ? accent : Color.secondary)
      Text("\(streaks.currentDays) day streak").font(.system(size: 14, weight: .medium))
      if streaks.longestDays > streaks.currentDays {
        Text("· longest \(streaks.longestDays)").font(.system(size: 12)).foregroundStyle(.secondary)
      }
    }
  }

  private func statRow(covered: TimeInterval, targetSeconds: Int) -> some View {
    let remaining = max(0, TimeInterval(targetSeconds) - covered)
    return HStack {
      statCell(label: "COVERED", value: Format.hms(covered), align: .leading)
      Rectangle().fill(Color(.separator)).frame(width: 1, height: 32)
      statCell(label: "REMAINING", value: Format.hms(remaining), align: .trailing)
    }
  }

  private func statCell(label: String, value: String, align: HorizontalAlignment) -> some View {
    VStack(alignment: align, spacing: 4) {
      Text(label).font(.system(size: 13, weight: .medium)).tracking(0.8).foregroundStyle(.secondary)
      Text(value).font(AppFont.statValue()).monospacedDigit()
    }
    .frame(maxWidth: .infinity, alignment: align == .leading ? .leading : .trailing)
  }

  @ViewBuilder
  private var toastView: some View {
    if let toast {
      Text(toast)
        .font(.system(size: 14))
        .foregroundStyle(.white)
        .padding(.horizontal, 16).padding(.vertical, 10)
        .background(Capsule().fill(Color(.darkGray)))
        .padding(.bottom, 90)
        .transition(.opacity)
    }
  }

  private func stop() async {
    let counted = await engine?.stop() ?? true
    if !counted { showToast("Session too short to count (under 1 min)") }
  }

  private func showToast(_ message: String) {
    withAnimation { toast = message }
    Task {
      try? await Task.sleep(for: .seconds(3))
      withAnimation { toast = nil }
    }
  }
}
