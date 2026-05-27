import Foundation

// A completed session record (the pure domain value). The SwiftData-backed row
// is `SessionRow`; the repository maps between them. `id` is cosmetic in the
// pure layer — identity for UI lists comes from the SwiftData model.
struct Session: Equatable, Identifiable {
  var id: Int = 0
  var pursuitId: Int
  var startedAt: Date
  var endedAt: Date
  /// Net counted time (wall-clock minus pauses), in seconds.
  var duration: TimeInterval
}
