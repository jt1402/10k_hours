import Foundation
import SwiftData

// Pursuit CRUD over a ModelContext. Reads (lists) use @Query in views; this
// covers the writes + the few point lookups the engine needs.
@MainActor
struct PursuitStore {
  let context: ModelContext

  /// App-assigned monotonic id (Flutter used an autoincrement int; SwiftData
  /// has no autoincrement, so we take max + 1).
  func nextId() -> Int {
    var desc = FetchDescriptor<Pursuit>(sortBy: [SortDescriptor(\.id, order: .reverse)])
    desc.fetchLimit = 1
    let maxId = (try? context.fetch(desc).first?.id) ?? 0
    return maxId + 1
  }

  @discardableResult
  func create(name: String, accentColor: Int, targetSeconds: Int) -> Pursuit {
    let pursuit = Pursuit(
      id: nextId(),
      name: name,
      accentColor: accentColor,
      targetMinutes: targetSeconds / 60,
      targetSecondsExact: targetSeconds,
      createdAt: Date()
    )
    context.insert(pursuit)
    try? context.save()
    return pursuit
  }

  func byId(_ id: Int) -> Pursuit? {
    var desc = FetchDescriptor<Pursuit>(predicate: #Predicate { $0.id == id })
    desc.fetchLimit = 1
    return try? context.fetch(desc).first
  }

  func markCompleted(_ id: Int, at: Date) {
    guard let pursuit = byId(id) else { return }
    pursuit.completedAt = at
    try? context.save()
  }

  func delete(_ id: Int) {
    guard let pursuit = byId(id) else { return }
    // Sessions reference pursuitId by value (no SwiftData relationship), so
    // clear them explicitly, then the pursuit + any active row for it.
    let sessions = (try? context.fetch(
      FetchDescriptor<SessionRow>(predicate: #Predicate { $0.pursuitId == id })
    )) ?? []
    for s in sessions { context.delete(s) }
    let actives = (try? context.fetch(
      FetchDescriptor<ActiveSessionRow>(predicate: #Predicate { $0.pursuitId == id })
    )) ?? []
    for a in actives { context.delete(a) }
    context.delete(pursuit)
    try? context.save()
  }
}

// Read-side stats over completed sessions. The ≥60s counted-duration rule is
// applied here (sub-60s rows persist for honest history but don't count).
@MainActor
enum SessionStats {
  static let minCountedMs = Int(AppConstants.sessionMinCountedDuration * 1000)

  static func countedRows(pursuitId: Int, context: ModelContext) -> [SessionRow] {
    let floor = minCountedMs
    let desc = FetchDescriptor<SessionRow>(
      predicate: #Predicate { $0.pursuitId == pursuitId && $0.durationMs >= floor }
    )
    return (try? context.fetch(desc)) ?? []
  }

  /// Total counted seconds for the pursuit.
  static func totalCounted(pursuitId: Int, context: ModelContext) -> TimeInterval {
    countedRows(pursuitId: pursuitId, context: context)
      .reduce(0) { $0 + $1.durationSeconds }
  }

  /// Count of ALL recorded sessions (matches the Flutter `countFor`, which
  /// counts raw rows including sub-60s).
  static func totalCount(pursuitId: Int, context: ModelContext) -> Int {
    let desc = FetchDescriptor<SessionRow>(
      predicate: #Predicate { $0.pursuitId == pursuitId }
    )
    return (try? context.fetchCount(desc)) ?? 0
  }

  /// Counted sessions as pure-domain `Session` values (for StreakService).
  static func countedSessions(pursuitId: Int, context: ModelContext) -> [Session] {
    countedRows(pursuitId: pursuitId, context: context).map {
      Session(
        pursuitId: $0.pursuitId,
        startedAt: $0.startedAt,
        endedAt: $0.endedAt,
        duration: $0.durationSeconds
      )
    }
  }
}
