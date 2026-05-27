import SwiftData
import SwiftUI

@main
struct TenKHoursApp: App {
  var body: some Scene {
    WindowGroup {
      RootView()
    }
    .modelContainer(Persistence.makeContainer())
  }
}
