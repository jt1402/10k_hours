import SwiftData
import SwiftUI

enum Route: Hashable {
  case create
  case heatmap(pursuitId: Int)
}

// App root: routes into the empty state or the current pursuit's timer, and
// owns the NavigationStack + which pursuit is shown. Mirrors the Flutter
// HomeScreen + go_router wiring. The shown pursuit defaults to the one with an
// active session, else the user's selection, else the first pursuit.
struct RootView: View {
  @Query(sort: \Pursuit.createdAt) private var pursuits: [Pursuit]
  @Query private var activeRows: [ActiveSessionRow]

  @State private var path: [Route] = []
  @State private var selectedPursuitId: Int?

  private var shownPursuitId: Int? {
    if let active = activeRows.first?.pursuitId, pursuits.contains(where: { $0.id == active }) {
      return active
    }
    if let selected = selectedPursuitId, pursuits.contains(where: { $0.id == selected }) {
      return selected
    }
    return pursuits.first?.id
  }

  var body: some View {
    NavigationStack(path: $path) {
      Group {
        if pursuits.isEmpty {
          EmptyStateView(onCreate: { path.append(.create) })
        } else if let id = shownPursuitId {
          TimerScreen(
            pursuitId: id,
            onSelectPursuit: { selectedPursuitId = $0 },
            onCreatePursuit: { path.append(.create) }
          )
          .id(id)
        }
      }
      .navigationDestination(for: Route.self) { route in
        switch route {
        case .create:
          CreatePursuitView(onCreated: { newId in
            selectedPursuitId = newId
            path.removeAll()
          })
        case .heatmap(let pursuitId):
          HeatmapScreen(pursuitId: pursuitId)
        }
      }
    }
  }
}
