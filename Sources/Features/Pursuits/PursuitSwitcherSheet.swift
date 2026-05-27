import SwiftData
import SwiftUI

// Bottom-sheet pursuit switcher: accent dot, name, target, check on current;
// swipe-to-delete (confirmed); "New pursuit". Switching is blocked while a
// session runs on a different pursuit. Ported from the Flutter switcher sheet.
struct PursuitSwitcherSheet: View {
  let currentPursuitId: Int
  var onSelect: (Int) -> Void
  var onCreate: () -> Void

  @Environment(\.modelContext) private var context
  @Environment(\.dismiss) private var dismiss
  @Query(sort: \Pursuit.createdAt) private var pursuits: [Pursuit]
  @Query private var activeRows: [ActiveSessionRow]

  @State private var pendingDelete: Pursuit?
  @State private var blockedMessage: String?

  private var activePursuitId: Int? { activeRows.first?.pursuitId }

  var body: some View {
    NavigationStack {
      List {
        if let activePursuitId, let p = pursuits.first(where: { $0.id == activePursuitId }) {
          Label("Stop the session on \(p.name) before switching.", systemImage: "info.circle")
            .font(.footnote).foregroundStyle(.secondary)
        }
        ForEach(pursuits) { pursuit in
          row(pursuit)
        }
        Button { dismiss(); onCreate() } label: {
          Label("New pursuit", systemImage: "plus")
        }
      }
      .navigationTitle("Switch pursuit")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar { ToolbarItem(placement: .topBarTrailing) { Button("Done") { dismiss() } } }
    }
    .presentationDetents([.medium, .large])
    .alert("Delete pursuit?", isPresented: Binding(get: { pendingDelete != nil }, set: { if !$0 { pendingDelete = nil } })) {
      Button("Cancel", role: .cancel) {}
      Button("Delete", role: .destructive) { if let p = pendingDelete { confirmDelete(p) } }
    } message: {
      if let p = pendingDelete { Text(deleteMessage(p)) }
    }
    .alert("Can't do that yet", isPresented: Binding(get: { blockedMessage != nil }, set: { if !$0 { blockedMessage = nil } })) {
      Button("OK", role: .cancel) {}
    } message: {
      if let m = blockedMessage { Text(m) }
    }
  }

  @ViewBuilder
  private func row(_ pursuit: Pursuit) -> some View {
    let isCurrent = pursuit.id == currentPursuitId
    let switchDisabled = activePursuitId != nil && activePursuitId != pursuit.id
    Button {
      guard !switchDisabled else { return }
      dismiss()
      if !isCurrent { onSelect(pursuit.id) }
    } label: {
      HStack(spacing: 12) {
        Circle().fill(Color(argb: pursuit.accentColor)).frame(width: 24, height: 24)
        VStack(alignment: .leading, spacing: 2) {
          Text(pursuit.name).foregroundStyle(.primary)
          Text(targetLabel(pursuit.goalSeconds)).font(.footnote).foregroundStyle(.secondary)
        }
        Spacer()
        if isCurrent { Image(systemName: "checkmark").foregroundStyle(.tint) }
      }
    }
    .disabled(switchDisabled)
    .swipeActions(edge: .trailing) {
      Button(role: .destructive) { requestDelete(pursuit) } label: { Label("Delete", systemImage: "trash") }
    }
  }

  private func targetLabel(_ seconds: Int) -> String { "\(Format.targetText(seconds: seconds)) target" }

  private func requestDelete(_ pursuit: Pursuit) {
    if activePursuitId == pursuit.id {
      blockedMessage = "Stop the current session before deleting."
      return
    }
    pendingDelete = pursuit
  }

  private func deleteMessage(_ pursuit: Pursuit) -> String {
    let count = SessionStats.totalCount(pursuitId: pursuit.id, context: context)
    if count == 0 { return "\(pursuit.name) has no recorded sessions. This cannot be undone." }
    let total = SessionStats.totalCounted(pursuitId: pursuit.id, context: context)
    return "\(count) session\(count == 1 ? "" : "s") (\(Format.coarse(total)) of practice) will be permanently deleted. This cannot be undone."
  }

  private func confirmDelete(_ pursuit: Pursuit) {
    let wasCurrent = pursuit.id == currentPursuitId
    PursuitStore(context: context).delete(pursuit.id)
    pendingDelete = nil
    if wasCurrent { dismiss() }
  }
}
