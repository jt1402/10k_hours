import Foundation
import SwiftData

// Central ModelContainer factory. `inMemory` is used by previews and tests.
enum Persistence {
  static func makeContainer(inMemory: Bool = false) -> ModelContainer {
    let config = ModelConfiguration(isStoredInMemoryOnly: inMemory)
    do {
      return try ModelContainer(
        for: Pursuit.self, SessionRow.self, ActiveSessionRow.self,
        configurations: config
      )
    } catch {
      fatalError("Failed to create ModelContainer: \(error)")
    }
  }
}
